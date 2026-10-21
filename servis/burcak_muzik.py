#!/usr/bin/env python3
"""Burçak müzik servisi: çalan şarkının türünü, temposunu ve video olup olmadığını JSON satırlarıyla bildirir.

Tür sırası: 1) çaların xesam:genre bilgisi, 2) sanatçı adıyla MusicBrainz etiketleri (önbellekli,
saniyede en fazla bir istek; internete yalnızca sanatçı adı gider), 3) yoksa boş bırakılır ve
Burçak tempoya göre seçer. Tempo, varsayılan ses çıkışının (monitor) zarfından tahmin edilir;
ses hiçbir yere yazılmaz.
"""
import array
import json
import os
import re
import subprocess
import sys
import threading
import time
import urllib.parse
import urllib.request
from pathlib import Path

CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "burcak" / "genres.json"
VIDEO_PLAYERS = ("mpv", "vlc", "celluloid", "totem", "smplayer")
VIDEO_URL = re.compile(r"(^|//)(www\.)?(youtube\.com/watch|youtu\.be/|netflix\.com|primevideo\.com|disneyplus\.com|"
                       r"twitch\.tv|blutv\.com|exxen\.com|puhutv\.com|gain\.tv|tabii\.com)", re.I)
RATE, FRAME = 8000, 184          # ~43 zarf örneği/saniye

state = {"playing": False, "player": "", "artist": "", "title": "", "genre": "", "genreSource": "", "bpm": 0, "video": False}
lock = threading.Lock()


def emit():
    with lock:
        print(json.dumps(state, ensure_ascii=False), flush=True)


def load_cache():
    try:
        return json.loads(CACHE.read_text())
    except (OSError, ValueError):
        return {}


cache = load_cache()
last_request = 0.0


def lookup_genre(artist):
    """MusicBrainz'den sanatçının en çok oy alan etiketleri (ör. 'heavy metal, thrash metal')."""
    global last_request
    key = artist.strip().lower()
    if not key:
        return ""
    if key in cache:
        return cache[key]
    wait = 1.1 - (time.monotonic() - last_request)
    if wait > 0:
        time.sleep(wait)
    last_request = time.monotonic()
    url = "https://musicbrainz.org/ws/2/artist/?" + urllib.parse.urlencode({"query": f'artist:"{artist}"', "fmt": "json", "limit": 1})
    req = urllib.request.Request(url, headers={"User-Agent": "VioletBurcak/1.0 (kisisel masaustu eslikcisi)"})
    try:
        with urllib.request.urlopen(req, timeout=8) as r:
            data = json.load(r)
        artists = data.get("artists") or []
        tags = sorted((artists[0].get("tags") or []) if artists else [], key=lambda t: -t.get("count", 0))
        genre = ", ".join(t["name"] for t in tags[:4])
    except Exception:
        return ""                 # ağ yoksa önbelleğe yazma, sonra tekrar dene
    cache[key] = genre
    try:
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=1))
    except OSError:
        pass
    return genre


def on_metadata(line):
    parts = (line.rstrip("\n").split("\t") + [""] * 6)[:6]
    player, status, artist, title, genre, url = parts
    playing = status == "Playing"
    video = player.split(".")[0].lower() in VIDEO_PLAYERS or bool(VIDEO_URL.search(url or ""))
    changed_track = (artist, title) != (state["artist"], state["title"])
    with lock:
        state.update(playing=playing, player=player, artist=artist, title=title, video=video)
        if changed_track:
            state.update(genre=genre, genreSource="calar" if genre else "", bpm=0)
    emit()
    if changed_track and not genre and artist and not video:
        def resolve(a=artist):
            g = lookup_genre(a)
            with lock:
                if state["artist"] != a:
                    return
                state.update(genre=g, genreSource="musicbrainz" if g else "")
            emit()
        threading.Thread(target=resolve, daemon=True).start()


def follow_players():
    fmt = "{{playerName}}\t{{status}}\t{{xesam:artist}}\t{{xesam:title}}\t{{xesam:genre}}\t{{xesam:url}}"
    while True:
        try:
            p = subprocess.Popen(["playerctl", "--follow", "metadata", "--format", fmt], stdout=subprocess.PIPE, text=True,
                                 stderr=subprocess.DEVNULL)
            for line in p.stdout:
                on_metadata(line)
            p.wait()
        except OSError:
            pass
        with lock:
            state.update(playing=False)
        emit()
        time.sleep(3)


def estimate_bpm(env):
    """Zarfın pozitif türevinin özilintisi; 70–180 BPM aralığında en güçlü periyot."""
    onset = [max(0.0, env[i] - env[i - 1]) for i in range(1, len(env))]
    mean = sum(onset) / max(1, len(onset))
    onset = [o - mean for o in onset]
    fps = RATE / FRAME
    def score(bpm):
        lag = fps * 60 / bpm
        l0 = int(lag)
        frac = lag - l0
        return sum(onset[i] * (onset[i + l0] * (1 - frac) + onset[i + l0 + 1] * frac) for i in range(len(onset) - l0 - 1))
    scores = {bpm: score(bpm) for bpm in range(70, 181, 2)}
    best_bpm = max(scores, key=scores.get)
    if scores[best_bpm] <= 0:
        return 0
    # Oktav hatası: iki katı tempo neredeyse aynı güçteyse hızlı olanı seç
    double = min(scores, key=lambda b: abs(b - best_bpm * 2))
    if abs(double - best_bpm * 2) <= 2 and scores[double] >= .7 * scores[best_bpm]:
        best_bpm = double
    return best_bpm


def follow_tempo():
    while True:
        if not state["playing"] or state["video"]:
            time.sleep(2)
            continue
        try:
            p = subprocess.Popen(["parec", "--device=@DEFAULT_MONITOR@", "--format=s16le", f"--rate={RATE}", "--channels=1",
                                  "--latency-msec=100"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            env = []
            while state["playing"] and not state["video"]:
                chunk = p.stdout.read(FRAME * 2)
                if not chunk or len(chunk) < FRAME * 2:
                    break
                samples = array.array("h", chunk)
                env.append(sum(abs(s) for s in samples) / FRAME)
                if len(env) >= int(RATE / FRAME * 8):        # 8 saniyelik pencere
                    bpm = estimate_bpm(env) if max(env) > 300 else 0
                    env = env[len(env) // 2:]
                    if bpm:
                        with lock:
                            old = state["bpm"]
                            state["bpm"] = bpm if not old else round(old * .6 + bpm * .4)
                        emit()
            p.terminate()
            p.wait(timeout=2)
        except (OSError, subprocess.TimeoutExpired):
            time.sleep(5)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "tur":         # elle deneme: burcak-muzik tur "Sanatçı"
        print(lookup_genre(" ".join(sys.argv[2:])))
        sys.exit(0)
    emit()
    threading.Thread(target=follow_tempo, daemon=True).start()
    follow_players()

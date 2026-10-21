import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "BurcakMoves.js" as Moves
import "BurcakLines.js" as Lines

// Burçak: ekranda serbestçe gezen vektör eşlikçi. Zeminde ve pencere üst kenarlarında yürür, tırmanır,
// düşer, taşınır; çalışma alanına, müziğin türüne ve videoya göre davranır. Pencere ekran boyu, yalnızca
// Burçak ve menüsü tıklama alır (mask).
PanelWindow {
    id: pet
    required property var controller
    screen: controller.panelScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore; focusable: false; color: "transparent"
    WlrLayershell.layer: watchingFullscreen ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.namespace: "violet-burcak"
    visible: Theme.petEnabled && !controller.burcakHidden && !controller.privateMode
    mask: Region { item: hit; Region { item: menu } }

    // ——— Boyut ve konum (px: ayak ortası, py: ayak hizası; ekran yerel koordinat)
    readonly property real sc: .64
    readonly property real bw: 200 * sc
    readonly property real bh: 260 * sc
    property real px: 160
    property real py: -1
    property real vy: 0
    property real facing: 1
    property string mode: "zemin"          // zemin | dusus | tirman | surukle
    property var surface: null             // {id, x0, x1, y}
    property real targetX: 160
    property bool running: false
    property var climb: null               // {id, x, top}
    property real busyUntil: 0             // tepki animasyonu sürerken karar verme

    // ——— Bağlam
    readonly property real groundY: height - (dockUp ? 92 : 6)
    readonly property bool dockUp: !screen || controller.dockShown[screen.name] !== false
    readonly property string group: controller.outputGroup(screen)
    readonly property var windows: (controller.state.windows || []).filter(w => String(w.group) === group && w.width > 0)
    readonly property var focusedWindow: windows.find(w => w.activated) || null
    readonly property string app: focusedWindow ? String(focusedWindow.appId || "").toLowerCase() : ""
    readonly property string title: focusedWindow ? String(focusedWindow.title || "") : ""
    // Müzik servisi yoksa yalnızca çalma durumu bilinir.
    property var music: ({playing: !!controller.state.playing, genre: "", bpm: 0, video: false})
    readonly property bool playing: !!music.playing
    readonly property bool video: playing && (music.video || /mpv|vlc|celluloid/.test(app) || /youtube|netflix|twitch|prime video|disney/i.test(title) && !/music/i.test(title))
    readonly property var videoWindow: video ? (windows.find(w => /mpv|vlc|celluloid|firefox|chrom/.test(String(w.appId).toLowerCase()) && w.activated) || focusedWindow) : null
    readonly property bool watchingFullscreen: video && !!videoWindow && !!videoWindow.fullscreen
    readonly property bool sleeping: idle.isIdle && !awake
    property bool awake: false
    readonly property string activity: sleeping ? "uyku" : video ? "film" : playing ? "dans" : group === "1" ? "kod"
        : group === "3" ? "hukuk" : group === "4" ? "okuma" : (group === "2" || /firefox|chrom/.test(app)) ? "web" : "serbest"
    readonly property string danceCat: genreToDance(music.genre, music.bpm)
    property string outfit: Theme.outfitAt(new Date())

    // ——— Animasyon durumu
    property string reaction: ""
    property string danceMove: "omuz_titret"
    property string remark: ""
    property bool talking: false
    property bool blushing: false
    property bool blinking: false
    property bool menuOpen: false
    property var knownIds: []

    function genreToDance(genre, bpm) {
        const g = String(genre || "").toLowerCase();
        if (/metal|thrash|death|grindcore|metalcore/.test(g)) return "metal";
        if (/soft rock|ballad|balad|soft|slow/.test(g)) return "soft";
        if (/rock|punk|grunge|alternative|indie rock/.test(g)) return "rock";
        if (/hip.?hop|rap|trap|drill/.test(g)) return "rap";
        if (/electro|house|techno|trance|edm|dubstep|drum and bass|dance/.test(g)) return "elektronik";
        if (/classical|klasik|acoustic|akustik|ambient|piano|jazz|lo.?fi|new age|orchestral/.test(g)) return "sakin";
        if (/arabesk|arabesque|fantezi/.test(g)) return "arabesk";
        if (/türkü|turku|turkish folk|halk|folk/.test(g)) return "halk";
        if (/pop|r&b|k-pop|latin|reggaeton/.test(g)) return "pop";
        // Tür bilinmiyorsa tempoya göre tahmin
        return bpm >= 140 ? "elektronik" : bpm >= 118 ? "pop" : bpm > 0 && bpm < 85 ? "sakin" : "pop";
    }
    function pick(list) { return list[Math.floor(Math.random() * list.length)]; }
    function say(cat, ms, blushAfter) {
        remark = Lines.pick(cat); talking = true; talkTimer.restart();
        remarkTimer.interval = ms || 4800; remarkTimer.restart();
        if (blushAfter) blushTimer.restart();
    }
    function react(name, cat, blushAfter) {
        if (!Moves.moves[name]) return;
        reaction = name; busyUntil = Date.now() + Moves.durationOf(Moves.moves[name], music.bpm) + 150;
        reactionEnd.interval = Math.max(400, busyUntil - Date.now()); reactionEnd.restart();
        if (cat) say(cat, 4500, blushAfter);
    }
    function platforms() {
        const sx = screen ? screen.x : 0, sy = screen ? screen.y : 0;
        const list = [{id: "zemin", x0: 0, x1: width, y: groundY, bottom: height}];
        for (const w of windows)
            if (!w.fullscreen && w.y - sy > 80) list.push({id: w.id, x0: w.x - sx, x1: w.x - sx + w.width, y: w.y - sy, bottom: w.y - sy + w.height});
        return list;
    }
    function findSurface(id) { return platforms().find(p => p.id === id) || null; }
    property bool fellFromWindow: false
    function startFall(cat) { mode = "dusus"; surface = null; vy = 0; climb = null; fellFromWindow = cat === "dustu"; if (cat) say(cat, 3500, false); }
    function land(p) {
        surface = p; py = p.y; vy = 0; mode = "zemin"; climb = null;
        react("inis", fellFromWindow && Math.random() < .5 ? "dustu" : "", false);
        fellFromWindow = false;
    }
    function clampX(x) { return Math.max(surface ? surface.x0 + bw * .3 : 20, Math.min(surface ? surface.x1 - bw * .3 : width - 20, x)); }
    function chooseNext() {
        if (!surface || Date.now() < busyUntil || mode !== "zemin") return;
        const roam = ["web", "serbest"].indexOf(activity) >= 0;
        const r = Math.random();
        if (!roam) { if (r < .12) targetX = clampX(px + (Math.random() - .5) * 160); return; }
        const wins = platforms().filter(p => p.id !== "zemin" && p.id !== surface.id);
        if (r < .45) { targetX = clampX(surface.x0 + 30 + Math.random() * (surface.x1 - surface.x0 - 60)); running = Math.random() < .2; }
        else if (r < .62 && wins.length && surface.id === "zemin") {
            // Yere değen bir pencerenin yan kenarına git ve tırman
            const w = pick(wins);
            if (w.bottom >= surface.y - 40) { const left = Math.random() < .5; climb = {id: w.id, x: left ? w.x0 : w.x1}; targetX = clampX(climb.x); running = false; }
        }
        else if (r < .72 && surface.id !== "zemin") { targetX = Math.random() < .5 ? surface.x0 - 30 : surface.x1 + 30; running = true; }
        else if (r < .8) react(pick(Moves.byCat("bosta")), "", false);
        else if (r < .84) { butterflyComponent.createObject(stage); react("kelebek_kovala", "kelebek", false); }
    }

    // ——— Fizik ve yürüme
    FrameAnimation {
        running: pet.visible
        onTriggered: {
            const dt = Math.min(frameTime, .05);
            if (pet.py < 0) { pet.py = pet.groundY; pet.surface = pet.findSurface("zemin"); }
            if (pet.mode === "surukle") return;
            if (pet.activity === "film") {
                // Videonun alt ortasına uzanır (tam ekranda ekranın altına)
                const w = pet.videoWindow, sx = pet.screen ? pet.screen.x : 0, sy = pet.screen ? pet.screen.y : 0;
                const tx = w && !w.fullscreen ? w.x - sx + w.width / 2 : pet.width / 2;
                const ty = w && !w.fullscreen ? Math.min(pet.groundY, w.y - sy + w.height - 6) : pet.height - 8;
                pet.px += (tx - pet.px) * Math.min(1, dt * 3); pet.py += (ty - pet.py) * Math.min(1, dt * 3);
                pet.targetX = pet.px; pet.mode = "zemin"; pet.surface = null; return;
            }
            if (!pet.surface && pet.mode === "zemin") pet.startFall("");
            if (pet.mode === "dusus") {
                const before = pet.py;
                pet.vy = Math.min(1400, pet.vy + 1800 * dt);
                pet.py += pet.vy * dt;
                const hits = pet.platforms().filter(p => p.y >= before - 1 && p.y <= pet.py && pet.px > p.x0 + 8 && pet.px < p.x1 - 8);
                if (hits.length) pet.land(hits.reduce((a, b) => a.y < b.y ? a : b));
                else if (pet.py > pet.height + 50) { pet.py = pet.groundY; pet.land(pet.findSurface("zemin")); }
                return;
            }
            if (pet.mode === "tirman") {
                const c = pet.findSurface(pet.climb ? pet.climb.id : -1);
                if (!c) { pet.climb = null; pet.startFall("dustu"); return; }
                pet.py -= 70 * dt;
                if (pet.py <= c.y) {
                    pet.px = Math.abs(pet.climb.x - c.x0) < 2 ? c.x0 + pet.bw * .35 : c.x1 - pet.bw * .35;
                    pet.climb = null; pet.land(c); pet.targetX = pet.px; pet.say("tirmanma", 4000, false);
                }
                return;
            }
            // Zeminde: yüzey hâlâ var mı, taşındı mı?
            const s = pet.findSurface(pet.surface.id);
            if (!s) { pet.startFall(pet.surface.id !== "zemin" ? "dustu" : ""); return; }
            if (Math.abs(s.y - pet.py) > 2 || s.x0 !== pet.surface.x0) {
                const shift = s.x0 - pet.surface.x0;
                if (Math.abs(s.y - pet.py) > 24 && Math.random() < .3) pet.say("tasiniyor", 3000, false);
                pet.px += shift; pet.targetX += shift; pet.py = s.y;
            }
            pet.surface = s;
            if (pet.px < s.x0 - 4 || pet.px > s.x1 + 4) { pet.startFall(s.id !== "zemin" ? "dustu" : ""); return; }
            if (Date.now() < pet.busyUntil) return;
            const d = pet.targetX - pet.px;
            if (Math.abs(d) > 3) {
                pet.facing = d < 0 ? -1 : 1;
                pet.px += Math.sign(d) * Math.min(Math.abs(d), (pet.running ? 150 : 70) * dt);
            } else if (pet.climb && pet.surface.id === "zemin" && Math.abs(pet.px - pet.climb.x) < 8) {
                pet.mode = "tirman";
            }
        }
    }

    // Hangi hareket oynasın
    property string idleMove: "nefes"
    property string filmFrame: "izle_arka"
    property string hukukFrame: "not_aliyor"
    readonly property string chosenMove: {
        if (mode === "surukle") return "tasiniyor";
        if (mode === "dusus") return "dusus";
        if (mode === "tirman") return "tirman";
        if (reaction !== "") return reaction;
        if (activity === "film") return filmFrame;
        if (activity === "uyku") return "uyuklama";
        if (Math.abs(targetX - px) > 3) return running ? "kos" : "yuru";
        if (activity === "dans") return danceMove;
        if (activity === "kod") return "yaziyor";
        if (activity === "okuma") return "okuyor";
        if (activity === "hukuk") return hukukFrame;
        if (surface && surface.id !== "zemin" && idleMove === "nefes") return "kenarda_otur";
        return idleMove;
    }
    Timer { interval: 9000; running: pet.visible; repeat: true
        onTriggered: {
            pet.idleMove = Math.random() < .5 ? "nefes" : pet.pick(["nefes", "etrafa_bak", "sallanma", "mirildanma", "ayak_vurma", "tirnak_bak", "sac_burgu"]);
            pet.filmFrame = Math.random() < .4 ? "izle_misir" : "izle_arka";
            pet.hukukFrame = pet.pick(["not_aliyor", "tokmak", "okuyor", "dusunuyor"]);
        } }
    // Dans: türe göre kategoriden her ~10 saniyede yeni figür
    Timer { interval: 10000; running: pet.visible && pet.activity === "dans"; repeat: true; triggeredOnStart: true
        onTriggered: pet.danceMove = pet.pick(Moves.byCat(pet.danceCat)) }
    onDanceCatChanged: if (activity === "dans") { danceMove = pick(Moves.byCat(danceCat)); say(danceCat, 4000, false); }
    onActivityChanged: {
        if (!visible) return;
        const cat = {kod: "kod", hukuk: "hukuk", okuma: "okuma", film: "film", dans: danceCat, web: "web", uyku: "uyku"}[activity];
        if (cat) Qt.callLater(() => say(cat, 4500, false));
    }

    // ——— Kararlar ve konuşmalar
    Timer { interval: 3200; running: pet.visible && !pet.sleeping; repeat: true; onTriggered: pet.chooseNext() }
    Timer {
        interval: 1000; running: pet.visible && !pet.sleeping; repeat: true
        property int countdown: 30
        onTriggered: {
            if (--countdown > 0) return;
            countdown = 30 + Math.floor(Math.random() * 45);
            const a = pet.activity, r = Math.random();
            if (a === "web") {
                if (r < .3) pet.react("ofleme", "web", false);
                else if (r < .65) pet.react("kahkaha", "saka", true);
                else pet.react("merhaba_el", "ilgi", true);
            } else if (a === "film") { if (!pet.watchingFullscreen) pet.say("film", 4000, false); }
            else if (a === "dans") pet.say(pet.danceCat, 3500, false);
            else if (a === "serbest") pet.react(pet.pick(["kikirdama", "basparmak", "sac_burgu"]), pet.pick(["saka", "ilgi"]), true);
            else pet.say(a, 4000, false);
        }
    }
    Timer { id: reactionEnd; onTriggered: pet.reaction = "" }
    Timer { id: talkTimer; interval: 1400; onTriggered: pet.talking = false }
    Timer { id: remarkTimer; onTriggered: pet.remark = "" }
    Timer { id: blushTimer; interval: 1500; onTriggered: { pet.blushing = true; blushEnd.restart(); } }
    Timer { id: blushEnd; interval: 6000; onTriggered: pet.blushing = false }
    Timer { interval: 3600; running: pet.visible; repeat: true
        onTriggered: { pet.blinking = true; blinkEnd.restart(); interval = 2500 + Math.random() * 3500; } }
    Timer { id: blinkEnd; interval: 150; onTriggered: pet.blinking = false }
    property bool mouthFlap: false
    Timer { interval: 160; running: pet.talking; repeat: true; onTriggered: pet.mouthFlap = !pet.mouthFlap }
    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            const o = Theme.outfitAt(new Date());
            if (o !== pet.outfit && pet.visible) pet.say(o === "pijama" ? "gece" : o === "gunduz" ? "sabah" : "aksam", 5000, false);
            pet.outfit = o;
        } }
    IdleMonitor { id: idle; timeout: 300; respectInhibitors: true
        onIsIdleChanged: if (!isIdle && pet.visible) { pet.awake = false; pet.react("gerinme", "uyku", false); } }
    Timer { id: awakeEnd; interval: 60000; onTriggered: pet.awake = false }

    // ——— Olaylar: yeni pencere (ezildim), şarkı, pil, bildirim, çağırma
    property string lastMedia: ""
    property bool batteryWarned: false
    Connections {
        target: pet.controller
        function onStateChanged() {
            const st = pet.controller.state;
            if (st.playing && st.media && st.media !== pet.lastMedia && pet.lastMedia !== "") { pet.say("sarki", 3500, false); pet.hearts(3); }
            if (st.media) pet.lastMedia = st.media;
            if (typeof st.battery === "number" && st.battery <= 20 && !st.charging && !pet.batteryWarned) { pet.batteryWarned = true; pet.react("sasirma_zipla", "pil", false); }
            if (st.charging || (typeof st.battery === "number" && st.battery > 25)) pet.batteryWarned = false;
        }
        function onBurcakSummonSerialChanged() {
            pet.awake = true; awakeEnd.restart();
            pet.px = Math.max(30, Math.min(pet.width - 30, pet.controller.burcakSummonX - (pet.screen ? pet.screen.x : 0)));
            pet.targetX = pet.px; pet.startFall("");
            pet.react("sevinc_zipla", "selam", true); pet.hearts(3);
        }
    }
    Timer {
        id: squashedOut; interval: 1700; property var windowId: -1
        onTriggered: { const s = pet.findSurface(windowId); if (s && pet.activity !== "film") { pet.px = Math.max(s.x0 + 40, Math.min(s.x1 - 40, pet.px)); pet.targetX = pet.px; pet.land(s); } }
    }
    // Müzik servisi: tür, tempo, video (JSON satırları)
    Process {
        id: musicService; command: ["burcak-muzik"]; running: pet.visible
        stdout: SplitParser { onRead: line => { try { pet.music = JSON.parse(line); } catch (e) {} } }
        onExited: musicRetry.restart()
    }
    Timer { id: musicRetry; interval: 5000; onTriggered: if (pet.visible) musicService.running = true }
    property int notices: -1
    Process {
        id: notifyPoll; command: ["makoctl", "list", "-j"]
        stdout: StdioCollector { onStreamFinished: {
            try { const v = JSON.parse(text), n = Array.isArray(v) ? v.length : (v.data && v.data[0] ? v.data[0].length : 0);
                  if (pet.notices >= 0 && n > pet.notices && !pet.sleeping) pet.react("sasirma_zipla", "bildirim", false);
                  pet.notices = n; } catch (e) {} } }
    }
    Timer { interval: 6000; repeat: true; running: pet.visible; onTriggered: if (!notifyPoll.running) notifyPoll.running = true }
    // Yeni açılan pencere Burçak'ın üstüne düşerse: ezilir, sonra pencerenin tepesine çıkar
    function checkWindows() {
        const sx = screen ? screen.x : 0, sy = screen ? screen.y : 0, mid = py - bh * .5;
        for (const w of windows) {
            if (knownIds.indexOf(w.id) >= 0 || w.fullscreen || activity === "film") continue;
            const lx = w.x - sx, ly = w.y - sy;
            if (px > lx && px < lx + w.width && mid > ly && mid < ly + w.height) {
                react("ezildim", "ezildim", false);
                squashedOut.windowId = w.id; squashedOut.restart();
            }
        }
        knownIds = windows.map(w => w.id);
    }
    onWindowsChanged: checkWindows()
    Component.onCompleted: { knownIds = windows.map(w => w.id); say("selam", 4000, true); }

    // ——— Sahne
    Item {
        id: stage
        x: pet.px - pet.bw / 2; y: pet.py - pet.bh
        width: pet.bw; height: pet.bh
        BurcakActor {
            id: actor
            scale: pet.sc; transformOrigin: Item.TopLeft
            move: pet.chosenMove
            bpm: pet.music.bpm || 110
            outfit: pet.outfit
            eyesOverride: pet.blinking ? "goz_kirp" : ""
            mouthOverride: pet.talking && pet.mouthFlap ? "o" : ""
            blushOverride: pet.blushing
            transform: Scale { origin.x: 100; xScale: actor.backView ? 1 : pet.facing }
        }
        // Uyku: Zzz
        Text {
            id: zzz; visible: pet.sleeping; text: "z Z z"; color: "#c5b4ff"; font.pixelSize: 16; x: pet.bw * .7
            NumberAnimation on y { from: 20; to: -20; duration: 2600; loops: Animation.Infinite; running: zzz.visible }
            NumberAnimation on opacity { from: 1; to: .1; duration: 2600; loops: Animation.Infinite; running: zzz.visible }
        }
        // Konuşma balonu
        Rectangle {
            visible: pet.remark !== "" && !pet.watchingFullscreen
            width: Math.min(280, bubble.implicitWidth + 26); height: bubble.implicitHeight + 16
            x: Math.max(-stage.x + 8, Math.min(pet.width - stage.x - width - 8, (pet.bw - width) / 2)); y: -height - 6
            radius: 16; color: "#f2211b2d"; border.color: Theme.border
            Text { id: bubble; anchors.centerIn: parent; width: Math.min(254, implicitWidth); text: pet.remark; color: Theme.pale
                font.family: Theme.sans; font.pixelSize: 12; wrapMode: Text.WordWrap; textFormat: Text.PlainText }
        }
    }
    function hearts(n) { for (let i = 0; i < n; i++) heartComponent.createObject(stage, {x: pet.bw * .55 + i * 14, delay: i * 200}); }

    // Tıklama/taşıma alanı (yalnızca gövde)
    Item {
        id: hit
        x: stage.x + pet.bw * .2; y: stage.y + pet.bh * .1; width: pet.bw * .6; height: pet.bh * .9
        DragHandler {
            id: drag; target: null
            onActiveChanged: {
                if (active) { pet.mode = "surukle"; pet.surface = null; pet.menuOpen = false; pet.say("tasiniyor", 3000, false); }
                else pet.startFall("");
            }
            onCentroidChanged: if (active) { pet.px = centroid.scenePosition.x; pet.py = centroid.scenePosition.y + pet.bh * .45; pet.targetX = pet.px; }
        }
        TapHandler {
            onTapped: {
                if (pet.sleeping) { pet.awake = true; awakeEnd.restart(); pet.react("gerinme", "selam", false); return; }
                pet.menuOpen = !pet.menuOpen; if (pet.menuOpen) menuClose.restart();
            }
        }
    }
    Timer { id: menuClose; interval: 7000; onTriggered: pet.menuOpen = false }
    Row {
        id: menu
        visible: pet.menuOpen
        width: visible ? implicitWidth : 0; height: visible ? implicitHeight : 0
        x: Math.max(8, Math.min(pet.width - implicitWidth - 8, pet.px - implicitWidth / 2)); y: Math.max(8, stage.y - 60)
        spacing: 6
        Pill { label: pet.playing ? "❚❚" : "▶"; implicitHeight: 34; onClicked: { pet.controller.command(["playerctl", "play-pause"]); pet.menuOpen = false; } }
        Pill { label: "Merkez"; implicitHeight: 34; onClicked: { pet.controller.selectOutput(pet.screen); pet.controller.modernTab = "dashboard"; pet.controller.toggle("modern"); pet.menuOpen = false; } }
        Pill { label: "Şaka yap"; implicitHeight: 34; onClicked: { pet.menuOpen = false; pet.react("kahkaha", "saka", true); } }
        Pill { label: "Dans et"; implicitHeight: 34; onClicked: { pet.menuOpen = false; pet.react(pet.pick(Moves.byCat(pet.danceCat)), pet.danceCat, false); } }
        Pill { label: "Saklan"; implicitHeight: 34; onClicked: { pet.menuOpen = false; pet.controller.burcakHidden = true; } }
    }

    Component {
        id: heartComponent
        Text {
            id: heart; property int delay: 0
            text: "♥"; color: "#ff7fa8"; font.pixelSize: 18; y: 20; opacity: 0
            SequentialAnimation { running: true
                PauseAnimation { duration: heart.delay }
                ParallelAnimation {
                    NumberAnimation { target: heart; property: "y"; from: 20; to: -40; duration: 1600; easing.type: Easing.OutQuad }
                    SequentialAnimation { NumberAnimation { target: heart; property: "opacity"; to: 1; duration: 200 }
                        NumberAnimation { target: heart; property: "opacity"; to: 0; duration: 1400 } } }
                ScriptAction { script: heart.destroy() } }
        }
    }
    Component {
        id: butterflyComponent
        Item {
            id: fly; property real t: 0
            width: 22; height: 18
            x: pet.bw / 2 + Math.cos(t * 6.3) * 110 - 11; y: pet.bh * .3 + Math.sin(t * 12.6) * 40
            Rectangle { x: 0; y: 0; width: 10; height: 9; radius: 5; color: "#ff8fc8"; rotation: -20; scale: .6 + Math.abs(Math.sin(fly.t * 80)) * .4 }
            Rectangle { x: 12; y: 0; width: 10; height: 9; radius: 5; color: "#ff8fc8"; rotation: 20; scale: .6 + Math.abs(Math.sin(fly.t * 80)) * .4 }
            Rectangle { x: 10; y: 2; width: 3; height: 13; radius: 1.5; color: "#4a2a5e" }
            NumberAnimation on t { from: 0; to: 1; duration: 9000; onFinished: fly.destroy() }
        }
    }
}

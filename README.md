# Burçak

Violet masaüstündeki vektör eşlikçi Burçak'ın kaynakları. Hiçbir görsel dosya yoktur:
Burçak tamamen QML ile çizilir (`BurcakFigure.qml` önden, `BurcakBack.qml` arkadan).

## Stüdyo

```
qs -p ~/Projeler/burcak/qml/shell.qml
```

Soldaki listeden hareket seç; boşluk tuşu oynatır ya da durdurur, ↑↓ hareketler arasında
gezer, M aynalar. Durdurunca "Evre" kaydırıcısı hareketi kare kare gösterir. Dosyalardan
birini kaydettiğinde stüdyo kendiliğinden yenilenir. Stüdyo masaüstü tercihlerine yazmaz.

## Dosyalar

| Dosya | İçerik |
|---|---|
| `qml/BurcakMoves.js` | 100 hareket. Her hareket, `t ∈ [0,1)` döngü evresinden bir poz döndüren fonksiyondur. |
| `qml/BurcakFigure.qml` | Önden çizim: iskelet (omuz/dirsek/bacak açıları), yüz, kıyafetler, eşyalar. |
| `qml/BurcakBack.qml` | Arkadan çizim (video izleme pozları, `view: "arka"`). |
| `qml/BurcakShapes.js` | Kıvırcık saç ve bukle yolları (tohumlu, her seferinde aynı saç). |
| `qml/BurcakActor.qml` | Hareketi kare kare oynatır, hareketler arasında 0,25 sn yumuşak geçiş yapar. |
| `qml/Burcak.qml` | Masaüstündeki davranış: yürüme, tırmanma, düşme, sürüklenme, müzik/video tepkileri, menü. |
| `qml/BurcakLines.js` | 179 diyalog satırı (kategori → satırlar). |
| `qml/CompanionSettings.qml` | Ayarlar paneli (kıyafet saatleri vb.). |
| `qml/Theme.qml` | Stüdyo için sade tema. Masaüstündekinin yerine geçmez. |
| `servis/burcak_muzik.py` | Müzik türü (çalar → MusicBrainz) ve tempo (BPM) servisi. |
| `nix/burcak.nix` | Masaüstünde servisin Nix tanımı (yalnız başvuru için). |
| `referans/` | Çizim için referans fotoğraflar. |

## Yeni hareket eklemek

`BurcakMoves.js` içinde:

```js
add("el_salla", "tepki", {dur: 1200}, t => P({
    armRShoulder: -150 + s(t, 2) * 20,   // sağ kol havada, sallanıyor
    armRElbow: -20,
    bob: hop(t, 2) * 3,                   // hafif zıplama
    eyes: "mutlu", mouth: "sirit"
}));
```

- `P({...})`: temel duruştan (`BASE`) başlar, verdiğin alanları değiştirir. `mix(UP, {...})` ve
  `mix(DOWN, {...})` ile kolları havada ya da yanda başlatabilirsin.
- Yardımcılar: `s(t,f,ph)` sinüs, `c(t,f,ph)` kosinüs, `hop(t,f)` 0→1→0 zıplama, `step(t,n)` adım.
- Seçenekler: `dur` (ms), dans için `beats` (süre BPM'den hesaplanır), `loop: false` (bir kez
  oynar), `view: "arka"` (arkadan çizim; o zaman `legL, legR, headTilt, hairSway, breathe, reach` kullanılır).
- Poz alanları: `bob, headTilt, hairSway, armLShoulder, armLElbow, armRShoulder, armRElbow,
  legL, legR, bodyTilt, squashX, squashY, dx` (sayı); `eyes` (acik, mutlu, kapali, asagi,
  goz_kirp, sasir), `mouth` (gulum, sirit, o, of, dudak), `blush`, `prop` (laptop, kitap, misir),
  `hand` (mikrofon, mendil, tokmak, kasik, cakmak).

Kategori adı yeni bir şeyse stüdyoda kendiliğinden yeni bir filtre düğmesi olarak çıkar.
Danslar `genreDance` eşlemesiyle müzik türüne bağlanır.

## Masaüstüne geri koymak

Bu klasör masaüstünden bağımsızdır. Bitirdiğin dosyaları Violet deposunda
`source/etc/nixos/home/fatih/desktop/shell/` altına koy; `Theme.qml` ve `shell.qml`
dosyalarını kopyalama (masaüstünün kendi dosyaları var).

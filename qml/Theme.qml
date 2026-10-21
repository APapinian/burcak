pragma Singleton
import QtQuick
import Quickshell
// Stüdyo için sade Theme: Violet masaüstündeki Theme.qml ile aynı adlar, ama hiçbir
// tercih dosyasına yazmaz (gerçek masaüstü ayarlarını bozmaz).
Singleton {
    id: theme
    readonly property color background: "#100f18"
    readonly property color surface: "#17151f"
    readonly property color raised: "#251f32"
    readonly property color border: "#463c57"
    readonly property color accent: "#c5b4ff"
    readonly property color pale: "#ece4f8"
    readonly property color muted: "#aaa1ba"
    readonly property color dim: "#736982"
    readonly property color ink: "#251a42"
    readonly property string sans: "Rubik"
    readonly property string serif: "DejaVu Serif"
    property bool reducedMotion: false
    property bool petEnabled: true
    property string dockAutoHide: "smart"
    property string saveStatus: ""
    property string burcakMorning: "07:00"
    property string burcakEvening: "18:00"
    property string burcakNight: "22:00"
    readonly property var penRingCatalog: [{id:"burcak",name:"Burçak",mark:"♡",internal:"burcak"}]
    property var penRingItems: ["burcak"]
    function ringEntry(id) { return penRingCatalog.find(e=>e.id===id) || null; }
    function duration(ms) { return reducedMotion ? 0 : ms; }
    function minutesOf(v) { const p=v.split(":"); return Number(p[0])*60+Number(p[1]); }
    function outfitAt(date) {
        const now=date.getHours()*60+date.getMinutes(), m=minutesOf(burcakMorning), e=minutesOf(burcakEvening), n=minutesOf(burcakNight);
        const within=(a,b)=>a<=b ? now>=a && now<b : now>=a || now<b;
        return within(m,e) ? "gunduz" : within(e,n) ? "siyah" : "pijama";
    }
    function shiftTime(key, minutes) {
        const v=(minutesOf(theme[key])+minutes+1440)%1440;
        theme[key]=String(Math.floor(v/60)).padStart(2,"0")+":"+String(v%60).padStart(2,"0");
    }
}

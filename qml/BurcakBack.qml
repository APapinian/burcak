import QtQuick
import QtQuick.Shapes
import "BurcakShapes.js" as S

// Burçak — arkadan, yüzüstü uzanmış video izliyor. İzleyiciye yakın taraf (alt) büyük, uzak taraf (üst) küçük.
Item {
    id: back
    width: 260; height: 210
    property string outfit: "gunduz"
    property real legL: 0          // diz etrafında dönüş (ayak sallama)
    property real legR: 0
    property real headTilt: 0
    property real hairSway: 0
    property real breathe: 0
    property bool popcorn: true
    property real reach: 0         // 0..1: mısıra uzanan sağ kol

    readonly property color hair: "#2a1814"
    readonly property var cloth: ({
        gunduz: {top: "#f1e9ff", shade: "#d6c7f3", pants: "#a9bce8", sole: "#f6c2d3"},
        siyah: {top: "#36313f", shade: "#25212c", pants: "#2b2732", sole: "#d9a5b8"},
        pijama: {top: "#ffc9de", shade: "#f5a5c6", pants: "#ffc9de", sole: "#ffe8f1"}
    })[outfit] || ({top: "#f1e9ff", shade: "#d6c7f3", pants: "#a9bce8", sole: "#f6c2d3"})

    component Fill: ShapePath { strokeColor: "transparent" }
    component Line: ShapePath { fillColor: "transparent"; capStyle: ShapePath.RoundCap }

    // Yer gölgesi
    Rectangle { x: 40; y: 176; width: 180; height: 26; radius: 13; color: "#000000"; opacity: .18 }

    // Bacaklar: dizler yerde (yakında), ayaklar havada; diz noktası etrafında sallanır.
    component Leg: Item {
        id: leg
        property real swing: 0
        width: 0; height: 0; rotation: swing; transformOrigin: Item.TopLeft
        Rectangle { x: -14; y: -64; width: 28; height: 70; radius: 14; color: back.cloth.pants
            border.color: Qt.darker(back.cloth.pants, 1.12); border.width: 1.5 }
        Rectangle { x: -15; y: -82; width: 30; height: 24; radius: 12; color: back.cloth.sole
            border.color: Qt.darker(back.cloth.sole, 1.15); border.width: 1.5
            Rectangle { x: 7; y: 5; width: 16; height: 3; radius: 1.5; color: Qt.darker(back.cloth.sole, 1.1) } }
    }

    // Gövde (hoodie sırtı) — uzağa doğru daralır
    Shape {
        anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
        transform: Scale { origin.x: 130; origin.y: 190; yScale: 1 + back.breathe * .02 }
        Fill {
            fillGradient: LinearGradient { x1: 0; y1: 96; x2: 0; y2: 196
                GradientStop { position: 0; color: back.cloth.shade } GradientStop { position: 1; color: back.cloth.top } }
            PathSvg { path: "M 92 104 Q 130 92 168 104 Q 196 150 192 186 Q 130 200 68 186 Q 64 150 92 104 Z" }
        }
        Line { strokeColor: Qt.darker(back.cloth.shade, 1.12); strokeWidth: 1.8; PathSvg { path: "M 130 110 Q 132 150 130 188 M 96 120 Q 130 112 164 120" } }
    }
    // Dirsekler yerde, kollar başa doğru (elleri çenesinde)
    Rectangle { x: 54; y: 84; width: 40; height: 26; radius: 13; color: back.cloth.top; rotation: -24
        border.color: Qt.darker(back.cloth.shade, 1.15); border.width: 1.5 }
    Item {
        x: 172; y: 92; width: 0; height: 0
        rotation: 24 - back.reach * 50; transformOrigin: Item.TopLeft
        Rectangle { x: -6; y: -12; width: 40 + back.reach * 22; height: 26; radius: 13; color: back.cloth.top
            border.color: Qt.darker(back.cloth.shade, 1.15); border.width: 1.5 }
        Rectangle { visible: back.reach > .3; x: 32 + back.reach * 22; y: -10; width: 16; height: 15; radius: 7; color: "#fff1ea" }
    }

    // Baş ve devasa kıvırcık saç (en uzakta)
    Item {
        anchors.fill: parent
        transform: Rotation { origin.x: 130; origin.y: 104; angle: back.headTilt + back.hairSway }
        Shape {
            anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
            Fill { fillColor: back.hair; PathSvg { path: S.curlyBlob(130, 66, 66, 52, 30, 8, 77) } }
            Line { strokeColor: Qt.rgba(0.08, 0.04, 0.03, .55); strokeWidth: 2; PathSvg { path: S.curlField(130, 70, 58, 44, 30, 81, 4, 8) } }
            Line { strokeColor: Qt.rgba(0.42, 0.28, 0.22, .55); strokeWidth: 1.3; PathSvg { path: S.curlField(130, 64, 60, 46, 24, 83, 3, 7) } }
            Fill { fillColor: "#f2d49c"; PathSvg { path: "M 118 22 L 121 10 L 126 18 L 130 7 L 134 18 L 139 10 L 142 22 Z" } }
        }
        Item {
            x: 160; y: 30; width: 26; height: 20; rotation: -14
            Rectangle { x: 0; y: 0; width: 12; height: 10; radius: 6; color: "#ff8fc8"; rotation: -20 }
            Rectangle { x: 14; y: 0; width: 12; height: 10; radius: 6; color: "#ff8fc8"; rotation: 20 }
            Rectangle { x: 2; y: 9; width: 9; height: 8; radius: 4; color: "#c86cff"; rotation: 20 }
            Rectangle { x: 15; y: 9; width: 9; height: 8; radius: 4; color: "#c86cff"; rotation: -20 }
            Rectangle { x: 11; y: 2; width: 4; height: 15; radius: 2; color: "#4a2a5e" }
        }
    }

    // Bacaklar en önde: izleyiciye en yakın parça (dizler kalçada, ayaklar havada sırtın önünde)
    Leg { x: 108; y: 196; swing: -10 + back.legL }
    Leg { x: 152; y: 196; swing: 10 + back.legR }

    // Patlamış mısır kasesi
    Item {
        visible: back.popcorn
        x: 206; y: 140; width: 50; height: 44
        Repeater {
            model: [[6, 8], [16, 2], [26, 6], [36, 3], [12, 14], [30, 12], [21, 10]]
            Rectangle { required property var modelData; x: modelData[0]; y: modelData[1]; width: 12; height: 11; radius: 6; color: "#fff3c4"; border.color: "#f0d98a" }
        }
        Shape {
            anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
            Fill { fillColor: "#ff6f8f"; PathSvg { path: "M 2 18 L 48 18 L 42 44 L 8 44 Z" } }
            Fill { fillColor: "#ffffff"; PathSvg { path: "M 12 18 L 18 18 L 16 44 L 12 44 Z M 28 18 L 34 18 L 34 44 L 30 44 Z" } }
        }
    }
}

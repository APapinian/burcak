import QtQuick
import QtQuick.Shapes
import "BurcakShapes.js" as S

// Burçak — önden görünüş, vektör çizim. 200×260 birimlik tuval; parçalar ayrı döner (iskelet).
Item {
    id: fig
    width: 200; height: 260
    property string outfit: "gunduz"          // gunduz | siyah | pijama
    property string eyes: "acik"              // acik | mutlu | kapali | asagi | goz_kirp | sasir
    property string mouth: "gulum"            // gulum | sirit | o | of | dudak
    property bool blush: false
    property real headTilt: 0
    property real bob: 0
    property real hairSway: 0
    property real armLShoulder: -18
    property real armLElbow: -48
    property real armRShoulder: 18
    property real armRElbow: 48
    property real legL: 0
    property real legR: 0
    property real bodyTilt: 0
    property real squashX: 1
    property real squashY: 1
    property real dx: 0
    property string prop: ""        // önde tutulan: laptop | kitap | misir
    property string hand: ""        // sağ elde: mikrofon | mendil | tokmak | kasik | cakmak

    readonly property color hair: "#2a1814"
    readonly property color hairMid: "#3a231b"
    readonly property color hairHi: "#5c3b2e"
    readonly property color skin: "#fff1ea"
    readonly property color skinShade: "#f4d6c9"
    readonly property var cloth: ({
        gunduz: {top: "#f1e9ff", shade: "#d6c7f3", pants: "#a9bce8", shoe: "#6a5a86", dots: false},
        siyah: {top: "#36313f", shade: "#25212c", pants: "#2b2732", shoe: "#4c4458", dots: false},
        pijama: {top: "#ffc9de", shade: "#f5a5c6", pants: "#ffc9de", shoe: "#ffe8f1", dots: true}
    })[outfit] || ({top: "#f1e9ff", shade: "#d6c7f3", pants: "#a9bce8", shoe: "#6a5a86", dots: false})

    component Fill: ShapePath { strokeColor: "transparent"; fillRule: ShapePath.WindingFill }
    component Line: ShapePath { fillColor: "transparent"; capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin }

    Item {
        id: rig
        width: 200; height: 260
        transform: [
            Scale { origin.x: 100; origin.y: 250; xScale: fig.squashX; yScale: fig.squashY },
            Rotation { origin.x: 100; origin.y: 248; angle: fig.bodyTilt },
            Translate { x: fig.dx; y: -fig.bob }
        ]

        // 1. Arka saç bulutu (omuzlara ve bele dökülen hacim)
        Item {
            anchors.fill: parent
            transform: Rotation { origin.x: 100; origin.y: 70; angle: fig.hairSway }
            Shape {
                anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                Fill { fillColor: fig.hair; PathSvg { path: S.curlyBlob(100, 112, 90, 106, 36, 10, 7) } }
                Line { strokeColor: Qt.rgba(0.08, 0.04, 0.03, .55); strokeWidth: 2; PathSvg { path: S.curlField(100, 128, 80, 86, 40, 21, 5, 9) } }
                Line { strokeColor: Qt.rgba(0.42, 0.28, 0.22, .55); strokeWidth: 1.3; PathSvg { path: S.curlField(100, 120, 84, 92, 30, 5, 4, 8) } }
            }
        }

        // 2. Bacaklar ve ayakkabılar
        Item {
            x: 78; y: 214; width: 20; height: 34
            transform: Rotation { origin.x: 10; origin.y: 0; angle: fig.legL }
            Rectangle { width: 20; height: 26; radius: 8; color: fig.cloth.pants }
            Rectangle { x: -3; y: 22; width: 25; height: 12; radius: 6; color: fig.cloth.shoe }
        }
        Item {
            x: 102; y: 214; width: 20; height: 34
            transform: Rotation { origin.x: 10; origin.y: 0; angle: fig.legR }
            Rectangle { width: 20; height: 26; radius: 8; color: fig.cloth.pants }
            Rectangle { x: -2; y: 22; width: 25; height: 12; radius: 6; color: fig.cloth.shoe }
        }

        // 3. Bol hoodie gövde
        Shape {
            anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
            Fill {
                fillGradient: LinearGradient { x1: 0; y1: 140; x2: 0; y2: 228
                    GradientStop { position: 0; color: fig.cloth.top } GradientStop { position: 1; color: fig.cloth.shade } }
                PathSvg { path: "M 74 140 Q 100 150 126 140 Q 150 146 158 168 Q 166 196 162 222 Q 100 236 38 222 Q 34 196 42 168 Q 50 146 74 140 Z" }
            }
            Line { strokeColor: Qt.darker(fig.cloth.shade, 1.12); strokeWidth: 2; PathSvg { path: "M 78 142 Q 100 160 122 142" } }
            Line { strokeColor: Qt.darker(fig.cloth.shade, 1.12); strokeWidth: 1.6; PathSvg { path: "M 92 152 L 90 170 M 108 152 L 110 170" } }
            Line { strokeColor: Qt.darker(fig.cloth.shade, 1.08); strokeWidth: 1.6; PathSvg { path: "M 46 214 Q 100 226 154 214" } }
        }
        // Pijama kalpleri
        Repeater {
            model: fig.cloth.dots ? [[62, 176], [132, 170], [84, 204], [146, 204], [110, 190], [56, 206]] : []
            Text { required property var modelData; x: modelData[0]; y: modelData[1]; text: "♥"; color: "#ffffff"; font.pixelSize: 9; opacity: .9 }
        }

        // 4. Kollar (omuz → dirsek → el); varsayılan: eller önde kenetli
        component Arm: Item {
            id: arm
            property real shoulder: 0
            property real elbow: 0
            property string holding: ""
            width: 0; height: 0; rotation: shoulder; transformOrigin: Item.TopLeft
            // Omuz hizasının üstüne kalkınca saçın ve başın önüne geç
            z: Math.abs(shoulder) > 95 ? 10 : 1
            Rectangle { x: -15; y: -10; width: 30; height: 54; radius: 15; color: fig.cloth.top
                border.color: Qt.darker(fig.cloth.shade, 1.15); border.width: 1.5
                gradient: Gradient { GradientStop { position: 0; color: fig.cloth.top } GradientStop { position: 1; color: fig.cloth.shade } } }
            Item {
                y: 40; width: 0; height: 0; rotation: arm.elbow; transformOrigin: Item.TopLeft
                Rectangle { x: -13; y: -6; width: 26; height: 42; radius: 13; color: fig.cloth.shade
                    border.color: Qt.darker(fig.cloth.shade, 1.18); border.width: 1.5 }
                Rectangle { x: -14; y: 26; width: 28; height: 10; radius: 5; color: Qt.darker(fig.cloth.shade, 1.1) }
                Rectangle { x: -8; y: 32; width: 16; height: 14; radius: 7; color: fig.skin; border.color: "#e9bfb0"; border.width: 1
                    Rectangle { x: 4; y: 4; width: 1.2; height: 6; radius: .6; color: "#e9bfb0" }
                    Rectangle { x: 8; y: 4; width: 1.2; height: 6; radius: .6; color: "#e9bfb0" } }
                // Elde tutulan küçük eşyalar
                Item {
                    x: 0; y: 40; visible: arm.holding !== ""
                    Rectangle { visible: arm.holding === "mikrofon"; x: -4; y: -2; width: 8; height: 20; radius: 3; color: "#4a4356" }
                    Rectangle { visible: arm.holding === "mikrofon"; x: -7; y: 14; width: 14; height: 14; radius: 7; color: "#bfb6cf" }
                    Rectangle { visible: arm.holding === "mendil"; x: -2; y: 2; width: 26; height: 22; radius: 3; color: "#ffffff"; rotation: 16
                        border.color: "#ff8fc8"; border.width: 2 }
                    Rectangle { visible: arm.holding === "tokmak"; x: -3; y: -4; width: 6; height: 26; radius: 2; color: "#8a5a35" }
                    Rectangle { visible: arm.holding === "tokmak"; x: -12; y: 16; width: 24; height: 11; radius: 3; color: "#a96f44" }
                    Rectangle { visible: arm.holding === "kasik"; x: -2; y: -2; width: 4; height: 22; radius: 2; color: "#d9a777" }
                    Rectangle { visible: arm.holding === "kasik"; x: -6; y: 16; width: 12; height: 10; radius: 5; color: "#d9a777" }
                    Rectangle { visible: arm.holding === "cakmak"; x: -4; y: 0; width: 8; height: 14; radius: 2; color: "#7d6fa0" }
                    Rectangle { visible: arm.holding === "cakmak"; x: -3; y: -10; width: 6; height: 10; radius: 3; color: "#ffc14d"
                        SequentialAnimation on opacity { running: parent.visible; loops: Animation.Infinite
                            NumberAnimation { to: .6; duration: 180 } NumberAnimation { to: 1; duration: 180 } } }
                }
            }
        }
        Arm { x: 56; y: 158; shoulder: fig.armLShoulder; elbow: fig.armLElbow }
        Arm { x: 144; y: 158; shoulder: fig.armRShoulder; elbow: fig.armRElbow; holding: fig.hand }
        // Önde tutulan eşyalar (kenetli ellerin hizasında)
        Item {
            x: 100; y: 206; z: 3; visible: fig.prop !== ""
            Rectangle { visible: fig.prop === "laptop"; x: -34; y: -30; width: 68; height: 40; radius: 6; color: "#4a4356"
                Rectangle { anchors.fill: parent; anchors.margins: 4; radius: 4; color: "#7fd3ff"
                    Rectangle { x: 6; y: 6; width: 30; height: 3; radius: 1.5; color: "#d9f3ff" }
                    Rectangle { x: 6; y: 13; width: 42; height: 3; radius: 1.5; color: "#d9f3ff" }
                    Rectangle { x: 6; y: 20; width: 22; height: 3; radius: 1.5; color: "#d9f3ff" } } }
            Rectangle { visible: fig.prop === "laptop"; x: -40; y: 8; width: 80; height: 8; radius: 4; color: "#8b84a0" }
            Rectangle { visible: fig.prop === "kitap"; x: -36; y: -22; width: 36; height: 34; radius: 4; color: "#fff6e6"; border.color: "#a77bff"; border.width: 3; rotation: -6 }
            Rectangle { visible: fig.prop === "kitap"; x: 0; y: -22; width: 36; height: 34; radius: 4; color: "#fff6e6"; border.color: "#a77bff"; border.width: 3; rotation: 6 }
            Rectangle { visible: fig.prop === "misir"; x: -18; y: -24; width: 36; height: 32; radius: 4; color: "#ff6f8f"
                Rectangle { x: 8; width: 6; height: 32; color: "white" } Rectangle { x: 22; width: 6; height: 32; color: "white" } }
            Repeater { model: fig.prop === "misir" ? [[-16, -34], [-4, -38], [8, -34], [-10, -28], [4, -29]] : []
                Rectangle { required property var modelData; x: modelData[0]; y: modelData[1]; width: 12; height: 11; radius: 6; color: "#fff3c4"; border.color: "#f0d98a" } }
        }

        // 5. Baş (boyun noktasından eğilir)
        Item {
            id: head
            z: 5
            anchors.fill: parent
            transform: Rotation { origin.x: 100; origin.y: 140; angle: fig.headTilt }

            // Öne, omuzlara dökülen yan lüleler
            Shape {
                anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                Fill { fillColor: fig.hair; PathSvg { path: S.lock(50, 74, 140, 32, 1, 11) + " " + S.lock(150, 74, 140, 32, -1, 13) } }
                Line { strokeColor: Qt.rgba(0.42, 0.28, 0.22, .55); strokeWidth: 1.3; PathSvg { path: S.curlField(50, 150, 12, 62, 7, 31, 4, 7) + S.curlField(150, 150, 12, 62, 7, 37, 4, 7) } }
            }
            Rectangle { x: 92; y: 128; width: 16; height: 16; radius: 6; color: fig.skinShade }
            // Yüz
            Rectangle {
                x: 55; y: 50; width: 90; height: 86; radius: 43
                gradient: Gradient { GradientStop { position: 0; color: fig.skin } GradientStop { position: 1; color: "#fbe3d8" } }
            }
            // Yanaklar
            Rectangle { x: 62; y: 110; width: 20; height: 10; radius: 5; color: "#f6a3b3"; opacity: fig.blush ? .85 : .35
                Behavior on opacity { NumberAnimation { duration: 400 } } }
            Rectangle { x: 118; y: 110; width: 20; height: 10; radius: 5; color: "#f6a3b3"; opacity: fig.blush ? .85 : .35
                Behavior on opacity { NumberAnimation { duration: 400 } } }
            // Kaşlar
            Shape {
                anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                Line { strokeColor: fig.hairMid; strokeWidth: 2.2
                    PathSvg { path: fig.mouth === "of" ? "M 70 84 Q 79 80 88 84 M 112 84 Q 121 80 130 84" : "M 70 84 Q 79 79 88 82 M 112 82 Q 121 79 130 84" } }
            }
            // Gözler
            Repeater {
                model: [80, 120]
                Item {
                    required property real modelData
                    x: modelData - 11; y: 88; width: 22; height: 26
                    // açık / aşağı / şaşkın: iri açık kahve göz
                    Item {
                        anchors.fill: parent
                        visible: ["acik", "asagi", "sasir"].indexOf(fig.eyes) >= 0
                        Rectangle { x: 3; y: fig.eyes === "asagi" ? 8 : 3; width: 16; height: fig.eyes === "asagi" ? 15 : fig.eyes === "sasir" ? 22 : 20; radius: 8
                            gradient: Gradient { GradientStop { position: 0; color: "#6e4428" } GradientStop { position: .55; color: "#b98252" } GradientStop { position: 1; color: "#d9a777" } } }
                        Rectangle { x: 7; y: fig.eyes === "asagi" ? 13 : 9; width: 8; height: 9; radius: 4; color: "#2a1814" }
                        Rectangle { x: 5; y: fig.eyes === "asagi" ? 10 : 5; width: 6; height: 6; radius: 3; color: "white" }
                        Rectangle { x: 13; y: fig.eyes === "asagi" ? 18 : 16; width: 3; height: 3; radius: 1.5; color: "white"; opacity: .9 }
                    }
                    Shape {
                        anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                        // üst kirpik çizgisi (açık gözde), kapalı/mutlu/kırpma halleri
                        Line { strokeColor: "#2a1814"; strokeWidth: 3
                            PathSvg { path: fig.eyes === "mutlu" ? "M 2 16 Q 11 6 20 16"
                                : fig.eyes === "kapali" || fig.eyes === "goz_kirp" ? "M 2 14 Q 11 20 20 14"
                                : fig.eyes === "asagi" ? "M 1 9 Q 11 5 21 9 L 23 7" : "M 1 5 Q 11 -1 21 5 L 23 3" } }
                    }
                }
            }
            // Burun
            Rectangle { x: 98; y: 112; width: 4; height: 3; radius: 1.5; color: "#eebcae" }
            // Ağız
            Shape {
                anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                Fill { fillColor: "#c2536b"
                    PathSvg { path: fig.mouth === "sirit" ? "M 89 119 Q 100 136 111 119 Q 100 123 89 119 Z"
                        : fig.mouth === "o" ? "M 96 120 Q 100 115 104 120 Q 104 128 100 129 Q 96 128 96 120 Z"
                        : fig.mouth === "of" ? "M 96 123 Q 100 120 104 123 Q 100 126 96 123 Z"
                        : fig.mouth === "dudak" ? "M 95 124 Q 100 121 105 124 Q 100 127 95 124 Z"
                        : "M 92 120 Q 100 129 108 120 Q 100 123 92 120 Z" } }
                Fill { fillColor: fig.mouth === "sirit" ? "#f2899c" : "transparent"; PathSvg { path: "M 94 126 Q 100 133 106 126 Q 100 128 94 126 Z" } }
            }
            // Öfleme: şişik yanak
            Rectangle { visible: fig.mouth === "of"; x: 104; y: 113; width: 16; height: 14; radius: 7; color: "#fbe3d8"; border.color: fig.skinShade }

            // Perçem: alnın üstünde dağınık kıvırcık lüleler
            Shape {
                anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                Fill { fillColor: fig.hair; PathSvg { path: S.curlyBlob(100, 66, 56, 30, 16, 7, 3, 180, 360) + " Z" } }
                Fill { fillColor: fig.hair; PathSvg { path: S.lock(74, 60, 26, 16, 1, 41) + " " + S.lock(96, 58, 22, 15, -1, 43) + " " + S.lock(122, 60, 26, 16, 1, 47) + " " + S.lock(60, 64, 34, 16, -1, 51) + " " + S.lock(140, 64, 34, 16, 1, 53) } }
                Line { strokeColor: Qt.rgba(0.42, 0.28, 0.22, .55); strokeWidth: 1.3; PathSvg { path: S.curlField(100, 54, 46, 14, 10, 61, 4, 7) } }
            }
            // Kelebek toka
            Item {
                x: 134; y: 50; width: 26; height: 20; rotation: 18
                Rectangle { x: 0; y: 0; width: 12; height: 10; radius: 6; color: "#ff8fc8"; rotation: -20 }
                Rectangle { x: 14; y: 0; width: 12; height: 10; radius: 6; color: "#ff8fc8"; rotation: 20 }
                Rectangle { x: 2; y: 9; width: 9; height: 8; radius: 4; color: "#c86cff"; rotation: 20 }
                Rectangle { x: 15; y: 9; width: 9; height: 8; radius: 4; color: "#c86cff"; rotation: -20 }
                Rectangle { x: 11; y: 2; width: 4; height: 15; radius: 2; color: "#4a2a5e" }
            }
            // Küçük taç
            Shape {
                anchors.fill: parent; preferredRendererType: Shape.CurveRenderer
                Fill { fillColor: "#f2d49c"; PathSvg { path: "M 88 40 L 91 28 L 96 36 L 100 25 L 104 36 L 109 28 L 112 40 Z" } }
                Fill { fillColor: "#a77bff"; PathSvg { path: "M 97 36 Q 100 31 103 36 Q 100 40 97 36 Z" } }
            }
        }
    }
}

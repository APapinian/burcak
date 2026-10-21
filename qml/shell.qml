// Burçak Animasyon Stüdyosu
// Çalıştır:  qs -p ~/Projeler/burcak/qml/shell.qml
// BurcakMoves.js / BurcakFigure.qml dosyasını kaydettiğinde Quickshell stüdyoyu kendiliğinden yeniler.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "BurcakMoves.js" as Moves

ShellRoot {
    FloatingWindow {
        id: studio
        title: "Burçak Stüdyosu"
        implicitWidth: 1180; implicitHeight: 780
        color: Theme.background

        property string move: "nefes"
        property string filter: ""
        property string category: ""
        property bool playing: true
        property real phase: 0
        property real bpm: 110
        property string outfit: "gunduz"
        property real zoom: 1.5
        property bool mirrored: false
        property string eyes: ""
        property string mouth: ""
        readonly property var info: Moves.moves[move] || {}
        readonly property var categories: Array.from(new Set(Moves.names.map(n => Moves.moves[n].cat)))
        readonly property var list: Moves.names.filter(n => (!category || Moves.moves[n].cat === category)
                                                         && (!filter || n.indexOf(filter.toLowerCase()) >= 0))
        function pick(delta) {
            const i = list.indexOf(move);
            if (list.length) move = list[(Math.max(0, i) + delta + list.length) % list.length];
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: e => {
                if (e.key === Qt.Key_Space) { studio.playing = !studio.playing; e.accepted = true; }
                else if (e.key === Qt.Key_Down) { studio.pick(1); e.accepted = true; }
                else if (e.key === Qt.Key_Up) { studio.pick(-1); e.accepted = true; }
                else if (e.key === Qt.Key_M) { studio.mirrored = !studio.mirrored; e.accepted = true; }
            }

            RowLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 18

                // ——— Hareket listesi
                Rectangle {
                    Layout.preferredWidth: 290; Layout.fillHeight: true; radius: 20
                    color: Theme.surface; border.color: Theme.border
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Text { text: "Hareketler · " + Moves.names.length; color: Theme.pale; font.family: Theme.serif; font.pixelSize: 20 }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 38; radius: 12; color: Theme.raised; border.color: search.activeFocus ? Theme.accent : Theme.border
                            TextInput {
                                id: search; anchors.fill: parent; anchors.leftMargin: 12; verticalAlignment: TextInput.AlignVCenter
                                color: Theme.pale; font.family: Theme.sans; font.pixelSize: 13
                                onTextChanged: studio.filter = text
                                Text { anchors.verticalCenter: parent.verticalCenter; visible: !search.text; text: "Ara…"; color: Theme.dim; font: search.font }
                            }
                        }
                        Flow {
                            Layout.fillWidth: true; spacing: 5
                            Repeater {
                                model: [""].concat(studio.categories)
                                Pill {
                                    required property string modelData
                                    label: modelData || "tümü"; implicitHeight: 28; horizontalPadding: 9
                                    fill: studio.category === modelData ? "#46385d" : Theme.raised
                                    onClicked: studio.category = modelData
                                }
                            }
                        }
                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 3
                            model: studio.list
                            delegate: Rectangle {
                                required property string modelData
                                width: ListView.view.width; height: 34; radius: 10
                                color: modelData === studio.move ? "#46385d" : hit.containsMouse ? Theme.raised : "transparent"
                                Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData; color: Theme.pale; font.family: Theme.sans; font.pixelSize: 13 }
                                Text { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                       text: Moves.moves[modelData].cat; color: Theme.dim; font.pixelSize: 10 }
                                MouseArea { id: hit; anchors.fill: parent; hoverEnabled: true; onClicked: studio.move = parent.modelData }
                            }
                        }
                    }
                }

                // ——— Sahne
                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; spacing: 12
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true; radius: 24; clip: true
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#2a1f42" }
                            GradientStop { position: 1; color: "#120f1b" }
                        }
                        border.color: Theme.border
                        // Zemin çizgisi ve ölçek ızgarası
                        Repeater {
                            model: 12
                            Rectangle { required property int index; x: index * parent.width / 12; width: 1; height: parent.height; color: "#ffffff"; opacity: .03 }
                        }
                        Rectangle { id: floor; y: parent.height - 70; width: parent.width; height: 1; color: Theme.accent; opacity: .35 }
                        BurcakActor {
                            id: actor
                            move: studio.move; bpm: studio.bpm; outfit: studio.outfit
                            running: studio.playing
                            fixedPhase: studio.playing ? -1 : studio.phase
                            eyesOverride: studio.eyes; mouthOverride: studio.mouth
                            scale: studio.zoom; transformOrigin: Item.Bottom
                            anchors.horizontalCenter: parent.horizontalCenter; y: floor.y - height
                            transform: Scale { origin.x: actor.width / 2; xScale: studio.mirrored ? -1 : 1 }
                            onFinished: name => finishedNote.text = name + " bitti (loop: false)"
                        }
                        Column {
                            x: 18; y: 16; spacing: 4
                            Text { text: studio.move; color: Theme.pale; font.family: Theme.serif; font.pixelSize: 26 }
                            Text {
                                color: Theme.muted; font.pixelSize: 12
                                text: "kategori: " + studio.info.cat + "   ·   " + (studio.info.beats ? studio.info.beats + " vuruş (" + Math.round(Moves.durationOf(studio.info, studio.bpm)) + " ms)" : (studio.info.dur || 0) + " ms")
                                      + "   ·   loop: " + (studio.info.loop !== false) + (studio.info.view ? "   ·   görünüm: " + studio.info.view : "")
                            }
                            Text { id: finishedNote; color: Theme.accent; font.pixelSize: 11 }
                        }
                        Text { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 14
                               text: "Boşluk: oynat/durdur · ↑↓: hareket · M: ayna"; color: Theme.dim; font.pixelSize: 11 }
                    }

                    // ——— Denetimler
                    Rectangle {
                        Layout.fillWidth: true; implicitHeight: controls.implicitHeight + 28; radius: 20
                        color: Theme.surface; border.color: Theme.border
                        GridLayout {
                            id: controls
                            anchors.fill: parent; anchors.margins: 14; columns: 2; columnSpacing: 14; rowSpacing: 10
                            Text { text: "Oynatma"; color: Theme.muted; font.pixelSize: 12 }
                            RowLayout {
                                Pill { label: studio.playing ? "Ⅱ Durdur" : "▶ Oynat"; onClicked: studio.playing = !studio.playing }
                                Pill { label: "↺ Baştan"; onClicked: { const m = studio.move; studio.move = "nefes"; studio.move = m; } }
                                Pill { label: "Ayna"; fill: studio.mirrored ? "#46385d" : Theme.raised; onClicked: studio.mirrored = !studio.mirrored }
                            }
                            Text { text: "Evre (durunca)"; color: Theme.muted; font.pixelSize: 12 }
                            Slider { Layout.fillWidth: true; value: studio.phase; onMoved: v => { studio.playing = false; studio.phase = v; } label: studio.phase.toFixed(2) }
                            Text { text: "BPM (danslar)"; color: Theme.muted; font.pixelSize: 12 }
                            Slider { Layout.fillWidth: true; value: (studio.bpm - 50) / 150; onMoved: v => studio.bpm = Math.round(50 + v * 150); label: studio.bpm + " bpm" }
                            Text { text: "Boyut"; color: Theme.muted; font.pixelSize: 12 }
                            Slider { Layout.fillWidth: true; value: (studio.zoom - .6) / 2.4; onMoved: v => studio.zoom = .6 + v * 2.4; label: studio.zoom.toFixed(1) + "×" }
                            Text { text: "Kıyafet"; color: Theme.muted; font.pixelSize: 12 }
                            RowLayout {
                                Repeater {
                                    model: ["gunduz", "siyah", "pijama"]
                                    Pill { required property string modelData; label: modelData; fill: studio.outfit === modelData ? "#46385d" : Theme.raised; onClicked: studio.outfit = modelData }
                                }
                            }
                            Text { text: "Göz / ağız"; color: Theme.muted; font.pixelSize: 12 }
                            Flow {
                                Layout.fillWidth: true; spacing: 5
                                Repeater {
                                    model: ["", "acik", "mutlu", "kapali", "asagi", "goz_kirp", "sasir"]
                                    Pill { required property string modelData; label: modelData || "göz: hareket"; implicitHeight: 28; horizontalPadding: 8
                                           fill: studio.eyes === modelData ? "#46385d" : Theme.raised; onClicked: studio.eyes = modelData }
                                }
                                Repeater {
                                    model: ["", "gulum", "sirit", "o", "of", "dudak"]
                                    Pill { required property string modelData; label: modelData || "ağız: hareket"; implicitHeight: 28; horizontalPadding: 8
                                           fill: studio.mouth === modelData ? "#46385d" : Theme.raised; onClicked: studio.mouth = modelData }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Basit kaydırıcı (Quickshell'de QtQuick.Controls'e bağımlı olmamak için)
    component Slider: Item {
        id: slider
        property real value: 0
        property string label: ""
        signal moved(real v)
        implicitHeight: 26
        Rectangle { y: 11; width: parent.width - 70; height: 4; radius: 2; color: Theme.raised
            Rectangle { width: parent.width * slider.value; height: 4; radius: 2; color: Theme.accent } }
        Rectangle { x: (slider.width - 70) * slider.value - 8; y: 5; width: 16; height: 16; radius: 8; color: Theme.pale; border.color: Theme.accent }
        Text { anchors.right: parent.right; y: 4; text: slider.label; color: Theme.pale; font.pixelSize: 12 }
        MouseArea {
            width: parent.width - 70; height: parent.height
            function at(x) { slider.moved(Math.max(0, Math.min(1, x / width))); }
            onPressed: m => at(m.x); onPositionChanged: m => at(m.x)
        }
    }
}

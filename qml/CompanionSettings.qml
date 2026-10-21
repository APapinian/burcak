import QtQuick
import QtQuick.Layouts
// Burçak, dock ve kalem halkası tercihleri (Theme'e kaydedilir).
ColumnLayout {
    id: panel
    required property var controller
    spacing: 14
    function moveItem(id, step) {
        const list = Theme.penRingItems.slice(), i = list.indexOf(id), j = i + step;
        if (i < 0 || j < 0 || j >= list.length) return;
        list[i] = list[j]; list[j] = id; Theme.penRingItems = list;
    }
    function toggleItem(id) {
        const list = Theme.penRingItems.slice(), i = list.indexOf(id);
        if (i >= 0) list.splice(i, 1); else list.push(id);
        Theme.penRingItems = list;
    }
    RowLayout {
        Layout.fillWidth: true
        ColumnLayout {
            Layout.fillWidth: true; spacing: 5
            Text { text: "Burçak ve dock"; color: Theme.pale; font.family: Theme.serif; font.pixelSize: 26 }
            Text { text: "EŞLİKÇİ  ·  DOCK  ·  KALEM HALKASI"; color: Theme.accent; font.family: Theme.sans; font.pixelSize: 9; font.letterSpacing: 2 }
        }
        Pill { label: "‹"; onClicked: panel.controller.openPanel = "settings" }
        Pill { label: "×"; onClicked: panel.controller.openPanel = "" }
    }

    Text { text: "BURÇAK"; color: Theme.muted; font.family: Theme.sans; font.pixelSize: 9; font.letterSpacing: 2 }
    RowLayout {
        Layout.fillWidth: true
        Text { Layout.fillWidth: true; text: "Burçak görünsün"; color: Theme.pale; font.family: Theme.sans; font.pixelSize: 12 }
        Pill { label: Theme.petEnabled ? "Açık" : "Kapalı"; onClicked: Theme.petEnabled = !Theme.petEnabled }
        Pill { visible: panel.controller.burcakHidden; label: "Geri çağır"; onClicked: panel.controller.burcakHidden = false }
    }
    Repeater {
        model: [{key: "burcakMorning", name: "Açık renk kıyafet (sabah)"}, {key: "burcakEvening", name: "Siyah hoodie (akşam)"}, {key: "burcakNight", name: "Pembe pijama (gece)"}]
        RowLayout {
            required property var modelData
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; text: modelData.name; color: Theme.pale; font.family: Theme.sans; font.pixelSize: 12 }
            Pill { label: "−30 dk"; implicitHeight: 34; onClicked: Theme.shiftTime(modelData.key, -30) }
            Text { text: Theme[modelData.key]; color: Theme.accent; font.family: Theme.sans; font.pixelSize: 14; Layout.preferredWidth: 46; horizontalAlignment: Text.AlignHCenter }
            Pill { label: "+30 dk"; implicitHeight: 34; onClicked: Theme.shiftTime(modelData.key, 30) }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
    Text { text: "DOCK OTOMATİK GİZLEME"; color: Theme.muted; font.family: Theme.sans; font.pixelSize: 9; font.letterSpacing: 2 }
    RowLayout {
        Layout.fillWidth: true
        Repeater {
            model: [{id: "off", name: "Kapalı"}, {id: "always", name: "Her zaman"}, {id: "smart", name: "Akıllı"}]
            Pill { required property var modelData; Layout.fillWidth: true; label: modelData.name
                fill: Theme.dockAutoHide === modelData.id ? "#46385d" : Theme.raised; onClicked: Theme.dockAutoHide = modelData.id }
        }
    }
    Text {
        Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Theme.muted; font.family: Theme.sans; font.pixelSize: 10
        text: Theme.dockAutoHide === "smart" ? "Bir pencere dock'un alanına girince gizlenir; alt kenara fare ya da dokunmayla gelince görünür."
            : Theme.dockAutoHide === "always" ? "Dock hep gizli; alt kenara fare ya da dokunmayla gelince görünür." : "Dock her zaman görünür."
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
    Text { text: "KALEM HALKASI"; color: Theme.muted; font.family: Theme.sans; font.pixelSize: 9; font.letterSpacing: 2 }
    Repeater {
        model: Theme.penRingItems.map(id => Theme.ringEntry(id)).filter(e => e).concat(Theme.penRingCatalog.filter(e => Theme.penRingItems.indexOf(e.id) < 0))
        RowLayout {
            required property var modelData
            readonly property bool on: Theme.penRingItems.indexOf(modelData.id) >= 0
            Layout.fillWidth: true; spacing: 6
            Text { text: modelData.mark; color: on ? Theme.accent : Theme.dim; font.pixelSize: 16; Layout.preferredWidth: 22 }
            Text { Layout.fillWidth: true; text: modelData.name; color: on ? Theme.pale : Theme.dim; font.family: Theme.sans; font.pixelSize: 12 }
            Pill { visible: on; label: "↑"; implicitHeight: 30; horizontalPadding: 10; onClicked: panel.moveItem(modelData.id, -1) }
            Pill { visible: on; label: "↓"; implicitHeight: 30; horizontalPadding: 10; onClicked: panel.moveItem(modelData.id, 1) }
            Pill { label: on ? "Açık" : "Kapalı"; implicitHeight: 30; onClicked: panel.toggleItem(modelData.id) }
        }
    }
    Text {
        Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Theme.muted; font.family: Theme.sans; font.pixelSize: 10
        text: "Halka kalemin ayrılmış yan tuşuyla açılır; tuş seçimi \"Kalem / kısayollar\" ayarındadır. " + (Theme.saveStatus || "Tercihler otomatik kaydedilir")
    }
}

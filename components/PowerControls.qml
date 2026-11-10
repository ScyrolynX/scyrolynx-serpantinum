import QtQuick
Item {
  id: p
  property var app
  property bool menu: false
  visible: app.showPower && (sddm.canPowerOff || sddm.canReboot)
  width: 64 * app.s; height: 64 * app.s
  Rectangle {
    id: btn; anchors.fill: parent; radius: app.ui.r2
    color: Qt.rgba(0.66, 0.45, 0.27, 0.85); border.width: 1; border.color: app.ui.border
    Icon { anchors.centerIn: parent; width: 28 * app.s; height: width; kind: "power"; color: "#FFB36B" }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: p.menu = !p.menu }
  }
  Column {
    visible: p.menu; anchors.right: parent.right; anchors.bottom: btn.top; anchors.bottomMargin: 10 * app.s; spacing: 8 * app.s
    Repeater {
      model: [ { t: "Restart", k: "restart", ok: sddm.canReboot }, { t: "Shut down", k: "power", ok: sddm.canPowerOff } ]
      Rectangle {
        required property var modelData
        visible: modelData.ok; width: 170 * app.s; height: 48 * app.s; radius: app.ui.r3
        color: Qt.rgba(0.17, 0.12, 0.09, 0.95); border.width: 1; border.color: app.ui.border
        Row { anchors.centerIn: parent; spacing: 10 * app.s
          Icon { width: 20 * app.s; height: width; kind: modelData.k; color: app.ui.gold }
          Text { text: modelData.t; color: app.ui.ivory; font.family: app.ui.font; font.weight: Font.Bold; font.pixelSize: 16 * app.s } }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
          onClicked: { p.menu = false; if (modelData.k === "restart") sddm.reboot(); else sddm.powerOff() } }
      }
    }
  }
}

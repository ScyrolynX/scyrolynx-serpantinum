import QtQuick
Card {
  id: m
  Row {
    anchors.fill: parent; anchors.margins: 14 * app.s; spacing: 14 * app.s
    Rectangle {
      width: parent.height; height: parent.height; radius: app.ui.r3
      color: Qt.rgba(1, 0.85, 0.55, 0.12); border.width: 1; border.color: app.ui.border
      Icon { anchors.centerIn: parent; width: parent.width * 0.4; height: width; kind: "note"; color: app.ui.ivory }
    }
    Column {
      width: parent.width - parent.height - parent.spacing; anchors.verticalCenter: parent.verticalCenter; spacing: 6 * app.s
      Text { text: "Nothing is playing"; color: app.ui.ivory; font.family: app.ui.font; font.weight: Font.Black; font.pixelSize: 21 * app.s; elide: Text.ElideRight; width: parent.width }
      Text { text: "Media controls unlock after sign-in"; color: app.ui.ivory; opacity: 0.6; font.family: app.ui.font; font.pixelSize: 13 * app.s; elide: Text.ElideRight; width: parent.width }
      Row {
        spacing: 8 * app.s; topPadding: 4 * app.s
        Repeater {
          model: ["prev", "play", "next"]
          Rectangle {
            required property string modelData
            width: 40 * app.s; height: 32 * app.s; radius: app.ui.r3; color: Qt.rgba(1, 0.85, 0.55, 0.14); opacity: 0.7
            Icon { anchors.centerIn: parent; width: 16 * app.s; height: width; kind: modelData; color: app.ui.gold }
          }
        }
      }
    }
  }
}

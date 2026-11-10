import QtQuick
Row {
  id: sg
  property var app
  property var items: []
  property int current: 0
  signal picked(int index)
  spacing: 6 * app.s
  Repeater {
    model: sg.items
    Rectangle {
      required property int index
      required property string modelData
      width: (sg.width - sg.spacing * (sg.items.length - 1)) / sg.items.length; height: 38 * sg.app.s; radius: sg.app.ui.r3
      color: sg.current === index ? sg.app.ui.gold : Qt.rgba(1, 0.85, 0.55, 0.12)
      border.width: 1; border.color: sg.app.ui.border
      Text { anchors.centerIn: parent; text: modelData; font.family: sg.app.ui.font; font.weight: Font.Bold; font.pixelSize: 14 * sg.app.s
             color: sg.current === index ? sg.app.ui.espresso : sg.app.ui.ivory }
      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sg.picked(index) }
    }
  }
}

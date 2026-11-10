import QtQuick
Row {
  id: sg
  property var app
  property var items: []
  property int current: 0
  signal picked(int index)
  spacing: 4 * app.s
  Repeater {
    model: sg.items
    Rectangle {
      required property int index
      required property string modelData
      width: (sg.width - sg.spacing * (sg.items.length - 1)) / sg.items.length; height: 28 * sg.app.s; radius: sg.app.ui.r3
      color: sg.current === index ? Qt.rgba(sg.app.ui.accent.r, sg.app.ui.accent.g, sg.app.ui.accent.b, 0.24) : Qt.rgba(1, 1, 1, 0.05)
      border.width: 1; border.color: sg.current === index ? sg.app.ui.accent : sg.app.ui.border
      Lbl { app: sg.app; anchors.centerIn: parent; text: modelData; sz: 10.5; font.weight: Font.Bold; font.letterSpacing: 0.6
            color: sg.current === index ? sg.app.ui.accent : sg.app.ui.text }
      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sg.picked(index) }
    }
  }
}

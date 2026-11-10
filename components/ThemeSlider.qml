import QtQuick
import QtQuick.Controls.Basic
Item {
  id: ts
  property var app
  property string label: ""
  property alias from: sl.from
  property alias to: sl.to
  property real value: 0
  signal moved(real v)
  height: 46 * app.s
  Text { text: ts.label; color: app.ui.ivory; font.family: app.ui.font; font.weight: Font.Bold; font.pixelSize: 14 * app.s; opacity: 0.85 }
  Slider {
    id: sl
    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 26 * app.s
    value: ts.value
    onMoved: ts.moved(value)
    background: Rectangle { y: sl.height/2 - height/2; width: sl.width; height: 6 * ts.app.s; radius: height/2; color: Qt.rgba(1, 0.85, 0.55, 0.18)
      Rectangle { width: sl.visualPosition * parent.width; height: parent.height; radius: parent.radius; color: ts.app.ui.gold } }
    handle: Rectangle { x: sl.visualPosition * (sl.width - width); y: sl.height/2 - height/2; width: 20 * ts.app.s; height: width; radius: width/2
      color: ts.app.ui.ivory; border.width: 2; border.color: ts.app.ui.gold }
  }
}

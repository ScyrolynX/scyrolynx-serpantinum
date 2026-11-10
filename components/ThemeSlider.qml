import QtQuick
import QtQuick.Controls.Basic
Item {
  id: ts
  property var app
  property string label: ""
  property alias from: sl.from
  property alias to: sl.to
  property real value: 0
  property string unit: ""
  property int decimals: 2
  signal moved(real v)
  height: 38 * app.s
  Lbl { app: ts.app; text: ts.label; sz: 10.5; dim: true; font.letterSpacing: 0.6 }
  Lbl { app: ts.app; anchors.right: parent.right; text: sl.value.toFixed(ts.decimals) + ts.unit; sz: 10.5 }
  Slider {
    id: sl
    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 20 * app.s
    value: ts.value
    onMoved: ts.moved(value)
    background: Rectangle { y: sl.height/2 - height/2; width: sl.width; height: 3 * ts.app.s; radius: 1; color: Qt.rgba(1, 1, 1, 0.12)
      Rectangle { width: sl.visualPosition * parent.width; height: parent.height; radius: 1; color: ts.app.ui.accent } }
    handle: Rectangle { x: sl.visualPosition * (sl.width - width); y: sl.height/2 - height/2; width: 12 * ts.app.s; height: width; radius: 2
      color: ts.app.ui.text; border.width: 2; border.color: ts.app.ui.accent }
  }
}

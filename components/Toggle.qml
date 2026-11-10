import QtQuick
Item {
  id: t
  property var app
  property string label: ""
  property bool on: false
  signal toggled(bool v)
  height: 26 * app.s
  Lbl { app: t.app; anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.right: sw.left; anchors.rightMargin: 8*t.app.s; text: t.label; sz: 11.5 }
  Rectangle { id: sw; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: 34*t.app.s; height: 16*t.app.s; radius: height/2
    color: t.on ? t.app.ui.accent : Qt.rgba(1,1,1,0.12); border.width: 1; border.color: t.on ? t.app.ui.accent : t.app.ui.border
    Rectangle { width: 10*t.app.s; height: width; radius: width/2; anchors.verticalCenter: parent.verticalCenter; x: t.on ? parent.width - width - 3*t.app.s : 3*t.app.s
      color: t.on ? t.app.ui.ink : t.app.ui.text; Behavior on x { NumberAnimation { duration: 120 } } } }
  MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: t.toggled(!t.on) }
}

import QtQuick
import QtQuick.Controls.Basic
// Real text input (user name / password / path ...).
Rectangle {
  id: f
  property var app
  property string iconKind: "user"
  property alias text: tf.text
  property alias field: tf
  property string placeholder: ""
  property bool secret: false
  property bool reveal: false
  property bool bad: false
  property real rightPad: 8 * app.s
  property bool mono: true
  signal accepted()
  height: 38 * app.s; radius: app.ui.r3; color: app.ui.field
  border.width: tf.activeFocus ? 2 : 1
  border.color: bad ? app.ui.bad : (tf.activeFocus ? app.ui.accent : app.ui.border)
  Icon { x: 11*f.app.s; anchors.verticalCenter: parent.verticalCenter; width: 16*f.app.s; height: width; kind: f.iconKind; color: tf.activeFocus ? f.app.ui.accent : f.app.ui.dim }
  TextField {
    id: tf
    anchors.fill: parent; anchors.leftMargin: 36*f.app.s; anchors.rightMargin: f.secret ? 36*f.app.s : f.rightPad
    echoMode: f.secret && !f.reveal ? TextInput.Password : TextInput.Normal; passwordCharacter: "•"
    placeholderText: f.placeholder; placeholderTextColor: f.app.ui.dim
    color: f.app.ui.text; selectionColor: f.app.ui.accent; selectedTextColor: f.app.ui.ink
    font.family: f.mono ? f.app.ui.font : f.app.ui.fontUi; font.pixelSize: 14*f.app.s
    verticalAlignment: TextInput.AlignVCenter; background: Item {}
    selectByMouse: true
    onAccepted: f.accepted()
  }
  Item { visible: f.secret; anchors.right: parent.right; width: 34*f.app.s; height: parent.height
    Icon { anchors.centerIn: parent; width: 16*f.app.s; height: width; kind: f.reveal ? "eyeoff" : "eye"; color: f.reveal ? f.app.ui.accent : f.app.ui.dim }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: f.reveal = !f.reveal } }
}

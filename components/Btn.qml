import QtQuick
Rectangle {
  id: b
  property var app
  property string text: ""
  property string icon: ""
  property bool primary: false
  property bool danger: false
  property bool active: false
  property bool busy: false
  signal clicked()
  height: 32 * app.s; radius: app.ui.r3
  opacity: busy ? 0.5 : 1
  color: primary ? (ma.containsMouse ? Qt.lighter(app.ui.accent, 1.12) : app.ui.accent)
       : active ? Qt.rgba(app.ui.accent.r, app.ui.accent.g, app.ui.accent.b, 0.22)
       : danger ? (ma.containsMouse ? Qt.rgba(1, 0.36, 0.36, 0.30) : Qt.rgba(1, 0.36, 0.36, 0.14))
       : (ma.containsMouse ? Qt.rgba(1, 1, 1, 0.11) : Qt.rgba(1, 1, 1, 0.06))
  border.width: 1; border.color: primary ? "transparent" : (active ? app.ui.accent : (danger ? Qt.rgba(1, 0.36, 0.36, 0.5) : app.ui.border))
  readonly property color fg: primary ? app.ui.ink : (danger ? "#FF8A8A" : app.ui.text)
  Row { anchors.centerIn: parent; spacing: 7 * app.s
    Icon { visible: b.icon.length > 0; width: 15*b.app.s; height: width; kind: b.icon; color: b.fg; anchors.verticalCenter: parent.verticalCenter }
    Lbl { app: b.app; visible: b.text.length > 0; text: b.text; color: b.fg; sz: 11.5; font.weight: Font.Bold; font.letterSpacing: 0.8; anchors.verticalCenter: parent.verticalCenter }
  }
  MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (!b.busy) b.clicked() }
}

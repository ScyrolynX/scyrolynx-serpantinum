import QtQuick
Rectangle {
  id: t
  property var app
  property string label: ""
  property string value: ""
  property real fill: 0.5        // purely decorative meter level
  property color tint: "#E8B7C0"
  property string iconKind: "shield"
  radius: app.ui.r2; color: Qt.rgba(1, 0.85, 0.55, 0.10); border.width: 1; border.color: app.ui.border; clip: true
  Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: parent.height * t.fill; radius: t.radius; color: t.tint; opacity: 0.92 }
  Row { x: 14*t.app.s; y: 12*t.app.s; spacing: 8*t.app.s
    Icon { width: 18*t.app.s; height: width; kind: t.iconKind; color: t.app.ui.ivory }
    Text { text: t.label; color: t.app.ui.ivory; font.family: t.app.ui.font; font.weight: Font.Black; font.pixelSize: 15*t.app.s; font.letterSpacing: 1 } }
  Text { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 14*t.app.s; width: parent.width - 28*t.app.s
    horizontalAlignment: Text.AlignRight; elide: Text.ElideRight; text: t.value
    color: t.app.ui.espresso; font.family: t.app.ui.font; font.weight: Font.Black; font.pixelSize: 24*t.app.s }
}

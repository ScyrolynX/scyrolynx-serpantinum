import QtQuick
Item {
  id: dg
  property var app
  property string ch: "0"
  property color fill: "white"
  property real px: 150
  width: px * 0.66; height: px * 0.98
  Text { x: dg.px*0.03; y: dg.px*0.05; width: dg.width; horizontalAlignment: Text.AlignHCenter
    text: dg.ch; color: Qt.darker(dg.app.ui.bronze, 1.7); font.family: dg.app.ui.font; font.weight: Font.Black; font.pixelSize: dg.px }
  Text { width: dg.width; horizontalAlignment: Text.AlignHCenter
    text: dg.ch; color: dg.fill; font.family: dg.app.ui.font; font.weight: Font.Black; font.pixelSize: dg.px }
}

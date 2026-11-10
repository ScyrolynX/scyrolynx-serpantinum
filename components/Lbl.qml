import QtQuick
// Themed text. mono=true for data/labels, false for display text.
Text {
  property var app
  property bool mono: true
  property bool dim: false
  property real sz: 12
  color: dim ? app.ui.dim : app.ui.text
  font.family: mono ? app.ui.font : app.ui.fontUi
  font.pixelSize: sz * app.s
  elide: Text.ElideRight
  renderType: Text.QtRendering
}

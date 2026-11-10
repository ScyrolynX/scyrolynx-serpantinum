import QtQuick
Rectangle {
  property var app
  radius: app.ui.r2
  color: app.ui.card
  border.width: 1
  border.color: app.ui.border
}

import QtQuick
// Heading above the clock (no chrome). Text is editable in Customize -> Style.
Item {
  id: g
  property var app
  Column { anchors.centerIn: parent; spacing: 4 * app.s; width: parent.width
    Lbl { app: g.app; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: app.welcomeText; mono: false; sz: 30; font.weight: Font.Black; style: Text.Raised; styleColor: Qt.rgba(0, 0, 0, 0.5) }
    Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 10*app.s
      Rectangle { width: 28*app.s; height: 1; color: app.ui.accent; anchors.verticalCenter: parent.verticalCenter }
      Lbl { app: g.app; text: app.brandText; sz: 12; color: app.ui.accent; font.weight: Font.Bold; font.letterSpacing: 6 }
      Rectangle { width: 28*app.s; height: 1; color: app.ui.accent; anchors.verticalCenter: parent.verticalCenter } }
    Lbl { app: g.app; width: parent.width; horizontalAlignment: Text.AlignHCenter; sz: 10.5; dim: true; font.letterSpacing: 2
          text: Qt.formatDateTime(app.now, "dddd · d MMMM yyyy").toUpperCase() }
  }
}

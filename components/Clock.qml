import QtQuick
// Auto-fits its parent. mini=true forces the compact HUD style (used on the login dashboard).
Item {
  id: c
  property var app
  property bool mini: false
  readonly property int style: mini ? 2 : app.st.clockStyle
  readonly property string hh: pad(hours())
  readonly property string mm: pad(app.now.getMinutes())
  readonly property string ss: pad(app.now.getSeconds())
  function hours() { var h = app.now.getHours(); if (!app.use24h) { h = h % 12; if (h === 0) h = 12 } return h }
  function pad(n) { return (n < 10 ? "0" : "") + n }
  readonly property real iw: style === 2 ? hud.width : grid.width
  readonly property real ih: style === 2 ? hud.height : grid.height
  Item {
    id: fit
    width: c.iw; height: c.ih
    anchors.centerIn: parent
    scale: Math.max(0.05, Math.min(c.width / Math.max(1, width), c.height / Math.max(1, height)))
    Grid {
      id: grid; visible: c.style !== 2
      columns: c.style === 0 ? 2 : 4
      spacing: 175 * 0.02
      Digit { app: c.app; px: 175; ch: c.hh.charAt(0); fill: c.app.ui.digitA }
      Digit { app: c.app; px: 175; ch: c.hh.charAt(1); fill: c.app.ui.digitB }
      Digit { app: c.app; px: 175; ch: c.mm.charAt(0); fill: c.app.ui.digitB }
      Digit { app: c.app; px: 175; ch: c.mm.charAt(1); fill: c.app.ui.digitA }
    }
    Item {
      id: hud; visible: c.style === 2; width: row.width; height: row.height
      Row { id: row; spacing: 10
        Lbl { app: c.app; text: c.hh; sz: 78 / c.app.s; mono: false; font.weight: Font.Light; color: c.app.ui.text; anchors.verticalCenter: parent.verticalCenter }
        Lbl { app: c.app; text: ":"; sz: 78 / c.app.s; mono: false; font.weight: Font.Light; color: c.app.ui.accent; anchors.verticalCenter: parent.verticalCenter
              opacity: (c.app.now.getSeconds() % 2 === 0) ? 1 : 0.25 }
        Lbl { app: c.app; text: c.mm; sz: 78 / c.app.s; mono: false; font.weight: Font.Light; color: c.app.ui.text; anchors.verticalCenter: parent.verticalCenter }
        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; visible: c.app.st.showSeconds || c.mini
          Lbl { app: c.app; text: c.ss; sz: 26 / c.app.s; color: c.app.ui.accent; font.weight: Font.Bold }
          Lbl { app: c.app; visible: !c.app.use24h; text: c.app.now.getHours() < 12 ? "AM" : "PM"; sz: 14 / c.app.s; dim: true } }
      }
    }
  }
}

import QtQuick
Item {
  id: c
  property var app
  property real px: 175 * app.s * app.st.clockScale
  readonly property string hh: pad(hours())
  readonly property string mm: pad(app.now.getMinutes())
  function hours() { var h = app.now.getHours(); if (!app.use24h) { h = h % 12; if (h === 0) h = 12 } return h }
  function pad(n) { return (n < 10 ? "0" : "") + n }
  implicitWidth: grid.width; implicitHeight: grid.height
  Grid {
    id: grid
    columns: app.st.clockStyle === 0 ? 2 : 4
    spacing: c.px * 0.02
    Digit { app: c.app; px: c.px; ch: c.hh.charAt(0); fill: c.app.ui.digitA }
    Digit { app: c.app; px: c.px; ch: c.hh.charAt(1); fill: c.app.ui.digitB }
    Digit { app: c.app; px: c.px; ch: c.mm.charAt(0); fill: c.app.ui.digitB }
    Digit { app: c.app; px: c.px; ch: c.mm.charAt(1); fill: c.app.ui.digitA }
  }
}

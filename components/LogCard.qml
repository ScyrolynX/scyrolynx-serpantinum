import QtQuick
// Real greeter event log (auth attempts, user switches, wallpaper changes ...). Passwords are never logged.
Panel {
  id: lc
  title: "Event log"
  tag: app.logModel.count + " EVT"
  ListView {
    id: lv
    anchors.fill: parent; anchors.margins: 8*app.s; clip: true; spacing: 3*app.s
    model: app.logModel
    delegate: Row { required property string time; required property string level; required property string msg
      width: lv.width; spacing: 6*app.s
      Lbl { app: lc.app; text: time; sz: 9.5; dim: true }
      Lbl { app: lc.app; text: level; sz: 9.5; font.weight: Font.Bold; width: 34*app.s
        color: level === "FAIL" ? app.ui.bad : level === "OK" ? app.ui.ok : level === "WARN" ? app.ui.warn : app.ui.accent }
      Lbl { app: lc.app; text: msg; sz: 9.5; width: parent.width - 100*app.s } }
  }
}

import QtQuick
Panel {
  id: ic
  title: "Identity"
  tag: "LOCKED"
  tagColor: app.ui.accent
  Column { anchors.fill: parent; anchors.margins: 10*app.s; spacing: 4*app.s
    Kv { app: ic.app; width: parent.width; k: "HOST"; v: sddm.hostName; iconKind: "host" }
    Kv { app: ic.app; width: parent.width; k: "USER"; v: userModel.lastUser; iconKind: "user" }
    Kv { app: ic.app; width: parent.width; k: "SESSION"; v: app.sessionName.length ? app.sessionName : "—"; iconKind: "terminal" }
    Kv { app: ic.app; width: parent.width; k: "KERNEL"; v: app.sys.kernel; iconKind: "cpu" }
    Kv { app: ic.app; width: parent.width; k: "UPTIME"; v: app.sys.uptime; iconKind: "clock" }
    Kv { app: ic.app; width: parent.width; k: "KEYMAP"; v: app.kbName; iconKind: "kbd" }
  }
}

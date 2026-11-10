import QtQuick
Panel {
  id: sc
  title: "Security"
  tag: app.authState === "busy" ? "VERIFYING" : (app.authState === "failed" ? "DENIED" : "ARMED")
  tagColor: app.authState === "failed" ? app.ui.bad : (app.authState === "busy" ? app.ui.warn : app.ui.ok)
  dotColor: tagColor
  Column { anchors.fill: parent; anchors.margins: 10*app.s; spacing: 4*app.s
    Kv { app: sc.app; width: parent.width; k: "PASSWORD"; v: "PAM · READY"; iconKind: "key"; vColor: app.ui.ok }
    Kv { app: sc.app; width: parent.width; k: "FINGERPRINT"; v: app.fpEnabled ? "VIA PAM" : "DISABLED"; iconKind: "finger"; vColor: app.fpEnabled ? app.ui.text : app.ui.dim }
    Kv { app: sc.app; width: parent.width; k: "FAILED TRIES"; v: String(app.failCount); iconKind: "warn"; vColor: app.failCount > 0 ? app.ui.warn : app.ui.text }
    Kv { app: sc.app; width: parent.width; k: "CAPS LOCK"; v: app.caps ? "ON" : "OFF"; iconKind: "caps"; vColor: app.caps ? app.ui.warn : app.ui.text }
    Kv { app: sc.app; width: parent.width; k: "LAST EVENT"; v: app.logModel.count ? app.logModel.get(0).level : "—"; iconKind: "shield" }
  }
}

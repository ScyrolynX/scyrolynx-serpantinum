import QtQuick
Panel {
  id: sc
  title: "System"
  tag: app.sys.ok ? "LIVE" : "NO TELEMETRY"
  tagColor: app.sys.ok ? app.ui.ok : app.ui.warn
  readonly property var rows: [
    { k: "CPU",  icon: "cpu",     v: app.sys.cpu,     t: app.sys.cpu < 0 ? "n/a" : Math.round(app.sys.cpu * 100) + "%" },
    { k: "MEM",  icon: "mem",     v: app.sys.memUsed, t: app.sys.memUsed < 0 ? "n/a" : app.sys.memText },
    { k: "TEMP", icon: "temp",    v: app.sys.temp < 0 ? -1 : Math.min(1, app.sys.temp / 100), t: app.sys.temp < 0 ? "n/a" : app.sys.temp.toFixed(0) + " °C" },
    { k: "BAT",  icon: "battery", v: app.sys.battery < 0 ? -1 : app.sys.battery / 100, t: app.sys.battery < 0 ? "n/a" : app.sys.battery + "%" + (app.sys.batState === "Charging" ? " ⚡" : "") }
  ]
  Column {
    anchors.fill: parent; anchors.margins: 10*app.s; spacing: 7*app.s
    Repeater { model: sc.rows
      Item { required property var modelData; width: parent.width; height: 24*app.s
        Icon { width: 13*app.s; height: width; kind: modelData.icon; color: app.ui.accent; anchors.verticalCenter: parent.verticalCenter }
        Lbl { app: sc.app; x: 20*app.s; anchors.verticalCenter: parent.verticalCenter; text: modelData.k; sz: 10; dim: true; font.letterSpacing: 1.2 }
        Rectangle { x: 62*app.s; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 62*app.s - valT.width - 8*app.s; height: 5*app.s; radius: 1; color: Qt.rgba(1,1,1,0.08)
          Rectangle { width: Math.max(0, modelData.v) * parent.width; height: parent.height; radius: 1; color: modelData.v > 0.85 ? app.ui.bad : (modelData.v > 0.65 ? app.ui.warn : app.ui.accent)
            Behavior on width { NumberAnimation { duration: 400 } } } }
        Lbl { id: valT; app: sc.app; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: modelData.t; sz: 10.5; font.weight: Font.Bold; elide: Text.ElideNone } } }
    Rectangle { width: parent.width; height: 1; color: app.ui.border }
    Kv { app: sc.app; width: parent.width; k: "UPTIME"; v: app.sys.uptime; iconKind: "clock" }
    Kv { app: sc.app; width: parent.width; k: "LOAD"; v: app.sys.load }
    Kv { app: sc.app; width: parent.width; k: "KERNEL"; v: app.sys.kernel }
  }
}

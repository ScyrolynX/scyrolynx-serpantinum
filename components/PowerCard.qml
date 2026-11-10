import QtQuick
// Real power actions with two-step confirm.
Panel {
  id: pc
  title: "Power"
  property string armed: ""
  Timer { id: disarm; interval: 3000; onTriggered: pc.armed = "" }
  function act(k) {
    if (armed !== k) { armed = k; disarm.restart(); return }
    armed = ""
    if (k === "sleep") sddm.suspend(); else if (k === "hib") sddm.hibernate(); else if (k === "restart") sddm.reboot(); else sddm.powerOff()
  }
  Row {
    anchors.fill: parent; anchors.margins: 8*app.s; spacing: 6*app.s
    Repeater {
      model: [ { k: "sleep", t: "SLEEP", i: "sleep", ok: (typeof sddm.canSuspend !== "undefined") ? sddm.canSuspend : false },
               { k: "hib", t: "HIBERNATE", i: "hibernate", ok: (typeof sddm.canHibernate !== "undefined") ? sddm.canHibernate : false },
               { k: "restart", t: "RESTART", i: "restart", ok: sddm.canReboot },
               { k: "off", t: "SHUT DOWN", i: "power", ok: sddm.canPowerOff } ]
      Btn { required property var modelData
        visible: modelData.ok; app: pc.app; width: (parent.width - 18*app.s) / 4 - 0.5; height: parent.height
        icon: modelData.i; text: pc.armed === modelData.k ? "CONFIRM" : ""; danger: pc.armed === modelData.k; active: false
        onClicked: pc.act(modelData.k)
        Lbl { visible: pc.armed !== modelData.k && parent.width > 52*app.s; app: pc.app; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 3*app.s; text: modelData.t; sz: 7.5; dim: true }
      }
    }
  }
}

import QtQuick
Item {
  id: ls
  property var app
  readonly property var ui: app.ui
  readonly property real s: app.s
  property real margin: 44 * s
  function clamp(v) { return Math.max(0.05, Math.min(0.95, v)) }

  // ---- top-left identity card ----
  Card { app: ls.app; x: ls.margin; y: ls.margin; width: 400*s; height: 200*s
    Row { x: 14*ls.s; y: 14*ls.s; spacing: 12*ls.s
      Rectangle { width: 92*ls.s; height: 92*ls.s; radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.12); border.width: 1; border.color: ui.border
        Icon { anchors.centerIn: parent; width: parent.width*0.5; height: width; kind: "user"; color: ui.ivory } }
      Column { spacing: 8*ls.s; width: 400*ls.s - 14*ls.s*3 - 92*ls.s
        Repeater { model: [ { k: "user", t: sddm.hostName }, { k: "lock", t: "Session locked" } ]
          Rectangle { required property var modelData; width: parent.width; height: 42*ls.s; radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.12)
            Row { anchors.verticalCenter: parent.verticalCenter; x: 10*ls.s; spacing: 8*ls.s
              Icon { width: 18*ls.s; height: width; kind: modelData.k; color: ui.gold }
              Text { text: modelData.t; color: ui.ivory; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 16*ls.s } } } } } }
    Row { anchors.bottom: parent.bottom; anchors.bottomMargin: 14*ls.s; x: 14*ls.s; spacing: 8*ls.s
      Repeater { model: ["lock", "key", "finger"]
        Rectangle { required property string modelData; width: (400*ls.s - 28*ls.s - 16*ls.s)/3; height: 52*ls.s; radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.14)
          Icon { anchors.centerIn: parent; width: 24*ls.s; height: width; kind: modelData; color: ui.gold } } } } }

  // ---- top-right status card ----
  Card { app: ls.app; anchors.right: parent.right; anchors.rightMargin: ls.margin; y: ls.margin; width: 380*s; height: 200*s
    Text { x: 18*ls.s; y: 16*ls.s; text: "Session"; color: ui.ivory; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 20*ls.s }
    Rectangle { anchors.right: parent.right; anchors.rightMargin: 16*ls.s; y: 14*ls.s; width: 104*ls.s; height: 36*ls.s; radius: ui.r3; color: ui.gold
      Text { anchors.centerIn: parent; text: "SECURE"; color: ui.espresso; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 14*ls.s; font.letterSpacing: 1.5 } }
    Icon { anchors.horizontalCenter: parent.horizontalCenter; y: 62*ls.s; width: 74*ls.s; height: width; kind: "cloud"; color: ui.fpTone }
    Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 16*ls.s
      text: "SYSTEM READY"; color: ui.ivory; opacity: 0.7; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 13*ls.s; font.letterSpacing: 2 } }

  // ---- bottom-left music-style card ----
  MusicCard { app: ls.app; x: ls.margin; anchors.bottom: parent.bottom; anchors.bottomMargin: ls.margin; width: 420*s; height: 176*s }

  // ---- bottom-right security card (leaves room for the power button) ----
  Card { app: ls.app; anchors.right: parent.right; anchors.rightMargin: ls.margin; anchors.bottom: parent.bottom; anchors.bottomMargin: ls.margin + 84*s; width: 380*s; height: 200*s
    Row { x: 16*ls.s; y: 14*ls.s; spacing: 10*ls.s
      Icon { width: 30*ls.s; height: width; kind: "shield"; color: ui.gold }
      Column { Text { text: "SECURITY"; color: ui.ivory; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 16*ls.s; font.letterSpacing: 1.5 }
        Text { text: Qt.formatDateTime(app.now, "yyyy-MM-dd HH:mm:ss"); color: ui.ivory; opacity: 0.65; font.family: ui.font; font.pixelSize: 12*ls.s } } }
    Column { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 14*ls.s; spacing: 8*ls.s
      Repeater { model: [ "Password login: ready", app.fpEnabled ? "Fingerprint: via PAM" : "Fingerprint: disabled" ]
        Rectangle { required property string modelData; width: parent.width; height: 44*ls.s; radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.12)
          Text { anchors.verticalCenter: parent.verticalCenter; x: 12*ls.s; text: modelData; color: ui.ivory; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 15*ls.s } } } } }

  // ---- movable: heading + clock ----
  Item {
    id: clockBox
    x: ls.width * app.st.clockX - width/2; y: ls.height * app.st.clockY - height/2
    width: Math.max(col.width, 200); height: col.height
    Column {
      id: col; spacing: 6*ls.s
      Text { anchors.horizontalCenter: parent.horizontalCenter; text: app.welcomeText; color: ui.ivory
        font.family: ui.font; font.weight: Font.Black; font.pixelSize: 30*ls.s; style: Text.Raised; styleColor: Qt.rgba(0,0,0,0.5) }
      Text { anchors.horizontalCenter: parent.horizontalCenter; text: app.brandText; color: ui.gold
        font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 15*ls.s; font.letterSpacing: 6 }
      Item { width: 1; height: 8*ls.s }
      ClockDisplay { app: ls.app; anchors.horizontalCenter: parent.horizontalCenter }
    }
    Rectangle { anchors.fill: parent; anchors.margins: -10*ls.s; color: "transparent"; radius: ui.r2; border.width: 2; border.color: ui.gold; visible: app.customizing; opacity: 0.8 }
    MouseArea {
      id: clockMa; anchors.fill: parent; anchors.margins: -10*ls.s; property real gx: 0; property real gy: 0
      cursorShape: app.customizing ? Qt.SizeAllCursor : Qt.PointingHandCursor
      onPressed: (m) => { var p = mapToItem(ls, m.x, m.y); gx = p.x - ls.width*app.st.clockX; gy = p.y - ls.height*app.st.clockY }
      onPositionChanged: (m) => { if (app.customizing && pressed) { var p = mapToItem(ls, m.x, m.y); app.st.clockX = ls.clamp((p.x-gx)/ls.width); app.st.clockY = ls.clamp((p.y-gy)/ls.height) } }
      onClicked: if (!app.customizing) app.openDash()
    }
  }

  // ---- movable: fingerprint ----
  Item {
    id: fpBox
    x: ls.width * app.st.fpX - width/2; y: ls.height * app.st.fpY - height/2
    width: scanner.width; height: scanner.height
    FingerprintScanner { id: scanner; app: ls.app; mode: app.fpMode; onClicked: if (!app.customizing) app.openDash() }
    Rectangle { anchors.fill: parent; anchors.margins: -8*ls.s; color: "transparent"; radius: ui.r2; border.width: 2; border.color: ui.gold; visible: app.customizing; opacity: 0.8 }
    MouseArea {
      anchors.fill: parent; enabled: app.customizing; z: 5; property real gx: 0; property real gy: 0; cursorShape: Qt.SizeAllCursor
      onPressed: (m) => { var p = mapToItem(ls, m.x, m.y); gx = p.x - ls.width*app.st.fpX; gy = p.y - ls.height*app.st.fpY }
      onPositionChanged: (m) => { if (pressed) { var p = mapToItem(ls, m.x, m.y); app.st.fpX = ls.clamp((p.x-gx)/ls.width); app.st.fpY = ls.clamp((p.y-gy)/ls.height) } }
    }
  }

  // ---- date, lower centre ----
  Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 18*s
    text: Qt.formatDateTime(app.now, "dddd, d MMMM yyyy  ·  HH:mm"); color: ui.ivory; opacity: 0.8
    font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 16*s; font.letterSpacing: 1 }
}

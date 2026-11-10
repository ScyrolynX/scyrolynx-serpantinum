import QtQuick
// Biometric scanner HUD. Honest states only: the sweep animates while we wait for SDDM/PAM, and
// "accepted" is shown only after loginSucceeded. Fills its parent; square art on top, readout below.
Item {
  id: f
  property var app
  property string mode: "idle"   // idle | waiting | accepted | rejected | unavailable
  property bool showText: true
  signal clicked()
  readonly property int style: app.st.fpStyle   // 0 HUD  1 Ring  2 Minimal
  readonly property real textH: showText ? 44 * app.s : 0
  readonly property real box: Math.max(60, Math.min(width, height - textH))
  readonly property bool live: mode === "idle" || mode === "waiting"
  readonly property color tone: mode === "accepted" ? app.ui.ok : mode === "rejected" ? app.ui.bad
        : mode === "unavailable" ? Qt.rgba(1, 1, 1, 0.3) : app.ui.accent
  readonly property var labels: ({ idle: "TOUCH SENSOR", waiting: "AWAITING FINGER", accepted: "MATCH · ACCEPTED", rejected: "NO MATCH · REJECTED", unavailable: "SENSOR UNAVAILABLE" })
  property real prog: 0
  property string hex: "-- -- -- -- -- --"
  onToneChanged: { brk.requestPaint(); ticks.requestPaint(); dim.requestPaint(); bright.requestPaint() }
  onModeChanged: { if (mode === "accepted" || mode === "rejected") prog = 1; else if (mode === "unavailable") prog = 0 }

  function hh(i, a) { var x = Math.sin(i * 127.1 + a * 311.7) * 43758.5453; return x - Math.floor(x) }
  // Procedural ridge pattern: nested wobbling loops with a delta gap at the base.
  function ridges(ctx, w, h, col, alpha) {
    ctx.clearRect(0, 0, w, h); ctx.strokeStyle = col; ctx.globalAlpha = alpha
    ctx.lineWidth = Math.max(1.2, w * 0.018); ctx.lineCap = "round"
    var cx = w / 2, cy = h * 0.52, n = 13, PI = Math.PI
    for (var i = 2; i <= n; i++) {
      var k = i / n, rx = w * 0.47 * k, ry = h * 0.5 * k, lift = (1 - k) * h * 0.1, pen = false
      ctx.beginPath()
      for (var a = 0; a <= 360; a += 5) {
        var th = a * PI / 180
        var wob = 1 + 0.035 * Math.sin(3 * th + i * 0.9) + 0.018 * Math.sin(5 * th - i * 0.5)
        var gap = (a > 62 && a < 118 && (i % 4 !== 0)) || hh(i, a) < 0.03
        var x = cx + rx * wob * Math.cos(th), y = cy - lift + ry * wob * Math.sin(th)
        if (gap) { pen = false; continue }
        if (!pen) { ctx.moveTo(x, y); pen = true } else ctx.lineTo(x, y)
      }
      ctx.stroke()
    }
    ctx.globalAlpha = 1
  }

  Timer { interval: 90; repeat: true; running: f.mode === "waiting"
    onTriggered: { var s = []; for (var i = 0; i < 6; i++) { var v = Math.floor(Math.random() * 256).toString(16).toUpperCase(); s.push(v.length < 2 ? "0" + v : v) } f.hex = s.join(" ") }
    onRunningChanged: if (!running) f.hex = "-- -- -- -- -- --" }

  Item {
    id: art
    width: f.box; height: f.box; x: (f.width - width) / 2; y: 0
    scale: ma.pressed ? 0.97 : 1
    Behavior on scale { NumberAnimation { duration: 100 } }

    // style 1: ring + rotating ticks
    Rectangle { visible: f.style === 1; anchors.fill: parent; anchors.margins: parent.width * 0.04; radius: width / 2; color: Qt.rgba(1, 1, 1, 0.03)
                border.width: Math.max(1, f.box * 0.012); border.color: Qt.rgba(f.tone.r, f.tone.g, f.tone.b, 0.55) }
    Item { id: tickWrap; visible: f.style === 1; anchors.fill: parent
      Canvas { id: ticks; anchors.fill: parent
        onPaint: { var c = getContext("2d"); c.clearRect(0, 0, width, height); var cx = width/2, cy = height/2, r1 = width*0.485, N = 72
          for (var i = 0; i < N; i++) { var a = i / N * Math.PI * 2, big = i % 6 === 0, r0 = r1 - (big ? width*0.045 : width*0.02)
            c.strokeStyle = f.tone; c.globalAlpha = big ? 0.95 : (i < 18 ? 0.75 : 0.35); c.lineWidth = Math.max(1, width*0.008)
            c.beginPath(); c.moveTo(cx + Math.cos(a)*r0, cy + Math.sin(a)*r0); c.lineTo(cx + Math.cos(a)*r1, cy + Math.sin(a)*r1); c.stroke() } }
        Component.onCompleted: requestPaint(); onWidthChanged: requestPaint() }
      RotationAnimator on rotation { from: 0; to: 360; duration: f.mode === "waiting" ? 2600 : 24000; loops: Animation.Infinite; running: f.live && f.style === 1 }
    }
    // style 0: corner brackets
    Canvas { id: brk; visible: f.style === 0; anchors.fill: parent
      onPaint: { var c = getContext("2d"); c.clearRect(0, 0, width, height); c.strokeStyle = f.tone; c.lineWidth = Math.max(2, width * 0.022); c.lineCap = "square"
        var L = width * 0.2, m = c.lineWidth / 2 + 1, w = width, h = height; c.beginPath()
        c.moveTo(m, L); c.lineTo(m, m); c.lineTo(L, m); c.moveTo(w-L, m); c.lineTo(w-m, m); c.lineTo(w-m, L)
        c.moveTo(w-m, h-L); c.lineTo(w-m, h-m); c.lineTo(w-L, h-m); c.moveTo(L, h-m); c.lineTo(m, h-m); c.lineTo(m, h-L); c.stroke()
        c.lineWidth = 1; c.globalAlpha = 0.5; for (var i = 1; i < 8; i++) { var p = L + (w - 2*L) * i / 8; c.beginPath(); c.moveTo(p, 0); c.lineTo(p, i % 2 ? m + 3 : m + 6); c.stroke(); c.beginPath(); c.moveTo(p, h); c.lineTo(p, h - (i % 2 ? m + 3 : m + 6)); c.stroke() } }
      Component.onCompleted: requestPaint(); onWidthChanged: requestPaint() }

    // ridge field
    Item {
      id: field; width: f.box * 0.62; height: width; anchors.centerIn: parent
      Canvas { id: dim; anchors.fill: parent; onPaint: f.ridges(getContext("2d"), width, height, f.tone, 0.28); Component.onCompleted: requestPaint(); onWidthChanged: requestPaint() }
      Item { id: lit; width: parent.width; height: parent.height * f.prog; clip: true
        Canvas { id: bright; width: field.width; height: field.height; onPaint: f.ridges(getContext("2d"), width, height, f.tone, 1.0); Component.onCompleted: requestPaint(); onWidthChanged: requestPaint() } }
      // scan line + glow
      Rectangle { visible: f.live; y: lit.height - 1; width: parent.width; height: Math.max(2, f.box * 0.014); color: f.tone
        Rectangle { anchors.bottom: parent.top; width: parent.width; height: field.height * 0.16
          gradient: Gradient { GradientStop { position: 0; color: "transparent" } GradientStop { position: 1; color: Qt.rgba(f.tone.r, f.tone.g, f.tone.b, 0.38) } } } }
    }
    transform: Translate { id: shk; x: 0 }
  }

  SequentialAnimation { running: f.mode === "rejected"
    NumberAnimation { target: shk; property: "x"; to: -6*f.app.s; duration: 50 } NumberAnimation { target: shk; property: "x"; to: 6*f.app.s; duration: 80 }
    NumberAnimation { target: shk; property: "x"; to: -3*f.app.s; duration: 60 } NumberAnimation { target: shk; property: "x"; to: 0; duration: 50 } }
  SequentialAnimation { running: f.live; loops: Animation.Infinite
    NumberAnimation { target: f; property: "prog"; from: 0.0; to: 1.0; duration: f.mode === "waiting" ? 1200 : 2800; easing.type: Easing.InOutSine }
    PauseAnimation { duration: 200 }
    NumberAnimation { target: f; property: "prog"; from: 1.0; to: 0.0; duration: f.mode === "waiting" ? 1200 : 2800; easing.type: Easing.InOutSine } }
  Column {
    visible: f.showText; anchors.top: art.bottom; anchors.topMargin: 8 * app.s; anchors.horizontalCenter: parent.horizontalCenter; spacing: 3 * app.s; width: parent.width
    Lbl { app: f.app; width: parent.width; horizontalAlignment: Text.AlignHCenter; text: f.labels[f.mode]; sz: 11; color: f.tone; font.weight: Font.Bold; font.letterSpacing: 1.6 }
    Lbl { app: f.app; width: parent.width; horizontalAlignment: Text.AlignHCenter; sz: 9.5; dim: true; font.letterSpacing: 1
          text: f.mode === "waiting" ? f.hex : (f.mode === "idle" ? "FPRINTD · PAM" : "—") }
  }
  MouseArea { id: ma; anchors.fill: art; cursorShape: Qt.PointingHandCursor; onClicked: f.clicked() }
}

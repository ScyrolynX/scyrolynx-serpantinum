import QtQuick
Item {
  id: f
  property var app
  property string mode: "idle"   // idle | waiting | busy | accepted | rejected | unavailable
  property real box: 150 * app.s
  property bool showText: true
  signal clicked()
  readonly property color tone: mode === "accepted" ? "#9FD6A0" : mode === "rejected" ? "#E5736A"
        : mode === "unavailable" ? Qt.darker(app.ui.bronze, 1.2) : (mode === "idle" ? app.ui.fpTone : app.ui.gold)
  readonly property var labels: ({ idle: "TOUCH THE SENSOR", waiting: "WAITING FOR FINGERPRINT…", busy: "VERIFYING…",
                                   accepted: "FINGERPRINT ACCEPTED", rejected: "FINGERPRINT REJECTED", unavailable: "SENSOR UNAVAILABLE" })
  width: box; height: box + (showText ? 40 * app.s : 0)
  onToneChanged: { printCanvas.requestPaint(); frame.requestPaint() }

  Item {
    id: art
    width: f.box; height: f.box
    Canvas {
      id: frame; anchors.fill: parent; visible: app.st.fpStyle === 0
      onPaint: {
        var ctx = getContext("2d"); ctx.clearRect(0,0,width,height);
        ctx.strokeStyle = f.tone; ctx.lineWidth = Math.max(2, width*0.03); ctx.lineCap = "round";
        var L = width*0.2, m = ctx.lineWidth/2+1, w = width, h = height;
        ctx.beginPath();
        ctx.moveTo(m,L); ctx.lineTo(m,m); ctx.lineTo(L,m);
        ctx.moveTo(w-L,m); ctx.lineTo(w-m,m); ctx.lineTo(w-m,L);
        ctx.moveTo(w-m,h-L); ctx.lineTo(w-m,h-m); ctx.lineTo(w-L,h-m);
        ctx.moveTo(L,h-m); ctx.lineTo(m,h-m); ctx.lineTo(m,h-L);
        ctx.stroke();
      }
      Component.onCompleted: requestPaint()
      onWidthChanged: requestPaint()
    }
    Rectangle {
      anchors.fill: parent; radius: width/2; visible: app.st.fpStyle === 1
      color: Qt.rgba(1,1,1,0.04); border.width: Math.max(2, f.box*0.025); border.color: f.tone
    }
    Item {
      id: clip
      anchors.centerIn: parent; width: f.box*0.62; height: f.box*0.62; clip: true
      Canvas {
        id: printCanvas; anchors.fill: parent
        onPaint: {
          var ctx = getContext("2d"); ctx.clearRect(0,0,width,height);
          ctx.strokeStyle = f.tone; ctx.lineWidth = Math.max(1.5, width*0.045); ctx.lineCap = "round";
          var cx = width/2, cy = height*0.52, PI = Math.PI;
          for (var i = 1; i <= 7; i++) {
            var r = width*0.065*i;
            ctx.beginPath(); ctx.arc(cx, cy, r, PI*(1.0+0.02*i), PI*(2.0-0.02*i)); ctx.stroke();
            if (i > 2 && i < 7) { ctx.beginPath(); ctx.arc(cx, cy, r, PI*(0.08+0.03*i), PI*(0.42+0.05*i)); ctx.stroke();
                                   ctx.beginPath(); ctx.arc(cx, cy, r, PI*(0.62+0.02*i), PI*(0.92-0.01*i)); ctx.stroke(); }
          }
          ctx.beginPath(); ctx.moveTo(cx, cy-width*0.03); ctx.lineTo(cx, height*0.82); ctx.stroke();
        }
        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
      }
      Rectangle {
        id: sweep
        width: parent.width; height: Math.max(2, 3*app.s); radius: height/2
        color: f.tone; opacity: f.mode === "idle" ? 0.35 : 0.9
        visible: f.mode !== "accepted" && f.mode !== "rejected" && f.mode !== "unavailable"
        SequentialAnimation on y {
          running: sweep.visible; loops: Animation.Infinite
          NumberAnimation { from: 0; to: clip.height - sweep.height; duration: f.mode === "idle" ? 2800 : 1300; easing.type: Easing.InOutSine }
          NumberAnimation { from: clip.height - sweep.height; to: 0; duration: f.mode === "idle" ? 2800 : 1300; easing.type: Easing.InOutSine }
        }
      }
    }
    scale: ma.pressed ? 0.96 : 1
    Behavior on scale { NumberAnimation { duration: app.ui.dFast } }
  }
  Text {
    visible: f.showText
    anchors.top: art.bottom; anchors.topMargin: 10*app.s; anchors.horizontalCenter: parent.horizontalCenter
    text: f.labels[f.mode]; color: app.ui.ivory; opacity: 0.9
    font.family: app.ui.font; font.weight: Font.Bold; font.pixelSize: 15*app.s; font.letterSpacing: 1.5
  }
  MouseArea { id: ma; anchors.fill: art; cursorShape: Qt.PointingHandCursor; onClicked: f.clicked() }
}

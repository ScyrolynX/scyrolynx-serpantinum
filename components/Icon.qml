import QtQuick
Canvas {
  id: c
  property string kind: "lock"
  property color color: "#F3EBDD"
  implicitWidth: 24; implicitHeight: 24
  onColorChanged: requestPaint()
  onKindChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()
  Component.onCompleted: requestPaint()
  onPaint: {
    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
    var w = width, h = height, PI = Math.PI;
    ctx.strokeStyle = color; ctx.fillStyle = color;
    ctx.lineWidth = Math.max(1.5, w * 0.09); ctx.lineCap = "round"; ctx.lineJoin = "round";
    function tri(x1,y1,x2,y2,x3,y3){ ctx.beginPath(); ctx.moveTo(x1,y1); ctx.lineTo(x2,y2); ctx.lineTo(x3,y3); ctx.closePath(); ctx.fill(); }
    switch (kind) {
    case "power":
      ctx.beginPath(); ctx.arc(w/2, h/2+h*0.03, w*0.32, -PI/2+0.75, 1.5*PI-0.75); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(w/2, h*0.12); ctx.lineTo(w/2, h*0.5); ctx.stroke(); break;
    case "restart":
      ctx.beginPath(); ctx.arc(w/2, h/2, w*0.32, -PI/2+0.4, 1.5*PI-0.2); ctx.stroke();
      tri(w*0.5,h*0.06, w*0.5,h*0.3, w*0.72,h*0.18); break;
    case "lock":
      ctx.fillRect(w*0.2, h*0.46, w*0.6, h*0.4);
      ctx.beginPath(); ctx.moveTo(w*0.32,h*0.46); ctx.lineTo(w*0.32,h*0.35); ctx.arc(w/2,h*0.35,w*0.18,PI,0); ctx.lineTo(w*0.68,h*0.46); ctx.stroke(); break;
    case "user":
      ctx.beginPath(); ctx.arc(w/2, h*0.32, w*0.17, 0, 2*PI); ctx.fill();
      ctx.beginPath(); ctx.arc(w/2, h*0.9, w*0.34, PI, 2*PI); ctx.fill(); break;
    case "note":
      ctx.beginPath(); ctx.arc(w*0.34, h*0.74, w*0.15, 0, 2*PI); ctx.fill();
      ctx.beginPath(); ctx.moveTo(w*0.47,h*0.72); ctx.lineTo(w*0.47,h*0.16); ctx.lineTo(w*0.8,h*0.3); ctx.stroke(); break;
    case "prev": ctx.fillRect(w*0.2,h*0.25,w*0.1,h*0.5); tri(w*0.8,h*0.25, w*0.8,h*0.75, w*0.34,h*0.5); break;
    case "play": tri(w*0.28,h*0.2, w*0.28,h*0.8, w*0.8,h*0.5); break;
    case "next": ctx.fillRect(w*0.7,h*0.25,w*0.1,h*0.5); tri(w*0.2,h*0.25, w*0.2,h*0.75, w*0.66,h*0.5); break;
    case "cloud":
      ctx.beginPath(); ctx.arc(w*0.32,h*0.6,w*0.18,0,2*PI); ctx.fill();
      ctx.beginPath(); ctx.arc(w*0.52,h*0.44,w*0.24,0,2*PI); ctx.fill();
      ctx.beginPath(); ctx.arc(w*0.74,h*0.62,w*0.16,0,2*PI); ctx.fill();
      ctx.fillRect(w*0.3,h*0.6,w*0.45,h*0.18); break;
    case "shield":
      ctx.beginPath(); ctx.moveTo(w/2,h*0.1); ctx.lineTo(w*0.82,h*0.22); ctx.lineTo(w*0.8,h*0.55);
      ctx.quadraticCurveTo(w*0.7,h*0.8,w/2,h*0.92); ctx.quadraticCurveTo(w*0.3,h*0.8,w*0.2,h*0.55); ctx.lineTo(w*0.18,h*0.22); ctx.closePath(); ctx.fill(); break;
    case "key":
      ctx.beginPath(); ctx.arc(w*0.3,h*0.5,w*0.18,0,2*PI); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(w*0.48,h*0.5); ctx.lineTo(w*0.9,h*0.5); ctx.moveTo(w*0.76,h*0.5); ctx.lineTo(w*0.76,h*0.68); ctx.stroke(); break;
    case "finger":
      for (var i = 1; i <= 4; i++) { ctx.beginPath(); ctx.arc(w/2, h*0.56, w*0.09*i, PI*1.05, PI*1.95); ctx.stroke(); }
      ctx.beginPath(); ctx.arc(w/2, h*0.56, w*0.03, 0, 2*PI); ctx.fill(); break;
    case "chevron": ctx.beginPath(); ctx.moveTo(w*0.36,h*0.2); ctx.lineTo(w*0.66,h*0.5); ctx.lineTo(w*0.36,h*0.8); ctx.stroke(); break;
    case "close": ctx.beginPath(); ctx.moveTo(w*0.25,h*0.25); ctx.lineTo(w*0.75,h*0.75); ctx.moveTo(w*0.75,h*0.25); ctx.lineTo(w*0.25,h*0.75); ctx.stroke(); break;
    case "sliders":
      for (var k = 0; k < 3; k++) { var y = h*(0.25+0.25*k); ctx.beginPath(); ctx.moveTo(w*0.12,y); ctx.lineTo(w*0.88,y); ctx.stroke();
        ctx.beginPath(); ctx.arc(w*(0.3+0.2*((k*2)%3)), y, w*0.1, 0, 2*PI); ctx.fill(); } break;
    case "moon": ctx.beginPath(); ctx.arc(w/2,h/2,w*0.32,0,2*PI); ctx.fill(); break;
    }
  }
}

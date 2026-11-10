import QtQuick
// Thin stroked technical icons, drawn on Canvas.
Canvas {
  id: c
  property string kind: "lock"
  property color color: "#F3EBDD"
  implicitWidth: 20; implicitHeight: 20
  onColorChanged: requestPaint()
  onKindChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()
  Component.onCompleted: requestPaint()
  onPaint: {
    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height)
    var w = width, h = height, PI = Math.PI
    ctx.strokeStyle = color; ctx.fillStyle = color
    ctx.lineWidth = Math.max(1.2, w * 0.085); ctx.lineCap = "round"; ctx.lineJoin = "round"
    function L(x1, y1, x2, y2) { ctx.beginPath(); ctx.moveTo(w*x1, h*y1); ctx.lineTo(w*x2, h*y2); ctx.stroke() }
    function C(x, y, r, fill) { ctx.beginPath(); ctx.arc(w*x, h*y, w*r, 0, 2*PI); if (fill) ctx.fill(); else ctx.stroke() }
    function R(x, y, rw, rh) { ctx.strokeRect(w*x, h*y, w*rw, h*rh) }
    function T(x1, y1, x2, y2, x3, y3) { ctx.beginPath(); ctx.moveTo(w*x1, h*y1); ctx.lineTo(w*x2, h*y2); ctx.lineTo(w*x3, h*y3); ctx.closePath(); ctx.fill() }
    switch (kind) {
    case "lock":
      R(0.2, 0.46, 0.6, 0.4)
      ctx.beginPath(); ctx.moveTo(w*0.3, h*0.46); ctx.lineTo(w*0.3, h*0.34); ctx.arc(w*0.5, h*0.34, w*0.2, PI, 0); ctx.lineTo(w*0.7, h*0.46); ctx.stroke()
      C(0.5, 0.65, 0.05, true); break
    case "user": C(0.5, 0.32, 0.17, false)
      ctx.beginPath(); ctx.arc(w*0.5, h*0.92, w*0.34, PI*1.1, PI*1.9); ctx.stroke(); break
    case "key": C(0.3, 0.5, 0.18, false); L(0.48, 0.5, 0.9, 0.5); L(0.76, 0.5, 0.76, 0.68); L(0.64, 0.5, 0.64, 0.64); break
    case "finger":
      for (var i = 1; i <= 3; i++) { var rr = w*(0.11*i + 0.05), yy = h*0.5; ctx.beginPath(); ctx.moveTo(w*0.5 - rr, h*(0.5 + 0.08*(4-i)+0.1)); ctx.lineTo(w*0.5 - rr, yy); ctx.arc(w*0.5, yy, rr, PI, 2*PI); ctx.lineTo(w*0.5 + rr, h*(0.5 + 0.08*(4-i)+0.1)); ctx.stroke() }
      L(0.5, 0.5, 0.5, 0.86); break
    case "shield":
      ctx.beginPath(); ctx.moveTo(w*0.5, h*0.1); ctx.lineTo(w*0.82, h*0.22); ctx.lineTo(w*0.8, h*0.55)
      ctx.quadraticCurveTo(w*0.7, h*0.8, w*0.5, h*0.92); ctx.quadraticCurveTo(w*0.3, h*0.8, w*0.2, h*0.55); ctx.lineTo(w*0.18, h*0.22); ctx.closePath(); ctx.stroke(); break
    case "power": ctx.beginPath(); ctx.arc(w*0.5, h*0.53, w*0.32, -PI/2+0.75, 1.5*PI-0.75); ctx.stroke(); L(0.5, 0.12, 0.5, 0.5); break
    case "restart": ctx.beginPath(); ctx.arc(w*0.5, h*0.5, w*0.32, -PI/2+0.4, 1.5*PI-0.2); ctx.stroke(); T(0.5, 0.06, 0.5, 0.3, 0.72, 0.18); break
    case "sleep":
      ctx.beginPath(); ctx.moveTo(w*0.62, h*0.16); ctx.quadraticCurveTo(w*0.18, h*0.24, w*0.28, h*0.64)
      ctx.quadraticCurveTo(w*0.4, h*0.92, w*0.84, h*0.7); ctx.quadraticCurveTo(w*0.5, h*0.62, w*0.62, h*0.16); ctx.stroke(); break
    case "hibernate": L(0.5, 0.12, 0.5, 0.58); ctx.beginPath(); ctx.moveTo(w*0.3, h*0.42); ctx.lineTo(w*0.5, h*0.62); ctx.lineTo(w*0.7, h*0.42); ctx.stroke(); L(0.2, 0.82, 0.8, 0.82); break
    case "chevron": ctx.beginPath(); ctx.moveTo(w*0.36, h*0.2); ctx.lineTo(w*0.66, h*0.5); ctx.lineTo(w*0.36, h*0.8); ctx.stroke(); break
    case "arrow": L(0.15, 0.5, 0.82, 0.5); ctx.beginPath(); ctx.moveTo(w*0.55, h*0.24); ctx.lineTo(w*0.84, h*0.5); ctx.lineTo(w*0.55, h*0.76); ctx.stroke(); break
    case "close": L(0.25, 0.25, 0.75, 0.75); L(0.75, 0.25, 0.25, 0.75); break
    case "check": ctx.beginPath(); ctx.moveTo(w*0.2, h*0.52); ctx.lineTo(w*0.42, h*0.72); ctx.lineTo(w*0.8, h*0.28); ctx.stroke(); break
    case "warn": ctx.beginPath(); ctx.moveTo(w*0.5, h*0.12); ctx.lineTo(w*0.9, h*0.84); ctx.lineTo(w*0.1, h*0.84); ctx.closePath(); ctx.stroke(); L(0.5, 0.4, 0.5, 0.6); C(0.5, 0.72, 0.03, true); break
    case "eye":
      ctx.beginPath(); ctx.moveTo(w*0.08, h*0.5); ctx.quadraticCurveTo(w*0.5, h*0.1, w*0.92, h*0.5); ctx.quadraticCurveTo(w*0.5, h*0.9, w*0.08, h*0.5); ctx.stroke(); C(0.5, 0.5, 0.12, false); break
    case "eyeoff":
      ctx.beginPath(); ctx.moveTo(w*0.08, h*0.5); ctx.quadraticCurveTo(w*0.5, h*0.1, w*0.92, h*0.5); ctx.quadraticCurveTo(w*0.5, h*0.9, w*0.08, h*0.5); ctx.stroke(); L(0.18, 0.84, 0.82, 0.16); break
    case "caps": ctx.beginPath(); ctx.moveTo(w*0.5, h*0.1); ctx.lineTo(w*0.82, h*0.48); ctx.lineTo(w*0.64, h*0.48); ctx.lineTo(w*0.64, h*0.7); ctx.lineTo(w*0.36, h*0.7); ctx.lineTo(w*0.36, h*0.48); ctx.lineTo(w*0.18, h*0.48); ctx.closePath(); ctx.stroke(); L(0.36, 0.88, 0.64, 0.88); break
    case "cpu": R(0.28, 0.28, 0.44, 0.44); for (var p = 0; p < 3; p++) { var q = 0.38 + p*0.12; L(q, 0.12, q, 0.28); L(q, 0.72, q, 0.88); L(0.12, q, 0.28, q); L(0.72, q, 0.88, q) } break
    case "mem": R(0.1, 0.3, 0.8, 0.4); for (var m = 0; m < 4; m++) L(0.24 + m*0.17, 0.7, 0.24 + m*0.17, 0.84); L(0.24, 0.45, 0.76, 0.45); break
    case "battery": R(0.1, 0.32, 0.74, 0.36); L(0.9, 0.44, 0.9, 0.56); ctx.fillRect(w*0.16, h*0.38, w*0.36, h*0.24); break
    case "clock": C(0.5, 0.5, 0.38, false); L(0.5, 0.5, 0.5, 0.26); L(0.5, 0.5, 0.68, 0.58); break
    case "temp": R(0.42, 0.1, 0.16, 0.5); C(0.5, 0.72, 0.17, false); L(0.5, 0.3, 0.5, 0.7); break
    case "folder": ctx.beginPath(); ctx.moveTo(w*0.1, h*0.28); ctx.lineTo(w*0.4, h*0.28); ctx.lineTo(w*0.48, h*0.38); ctx.lineTo(w*0.9, h*0.38); ctx.lineTo(w*0.9, h*0.78); ctx.lineTo(w*0.1, h*0.78); ctx.closePath(); ctx.stroke(); break
    case "image": R(0.12, 0.2, 0.76, 0.6); ctx.beginPath(); ctx.moveTo(w*0.12, h*0.72); ctx.lineTo(w*0.38, h*0.46); ctx.lineTo(w*0.56, h*0.64); ctx.lineTo(w*0.68, h*0.52); ctx.lineTo(w*0.88, h*0.72); ctx.stroke(); C(0.7, 0.34, 0.05, true); break
    case "terminal": R(0.1, 0.2, 0.8, 0.6); ctx.beginPath(); ctx.moveTo(w*0.24, h*0.4); ctx.lineTo(w*0.38, h*0.5); ctx.lineTo(w*0.24, h*0.6); ctx.stroke(); L(0.46, 0.62, 0.62, 0.62); break
    case "sliders": for (var k = 0; k < 3; k++) { var y = 0.25 + 0.25*k; L(0.12, y, 0.88, y); C(0.3 + 0.2*((k*2)%3), y, 0.08, true) } break
    case "grid": R(0.14, 0.14, 0.3, 0.3); R(0.56, 0.14, 0.3, 0.3); R(0.14, 0.56, 0.3, 0.3); R(0.56, 0.56, 0.3, 0.3); break
    case "move": L(0.5, 0.1, 0.5, 0.9); L(0.1, 0.5, 0.9, 0.5); L(0.5, 0.1, 0.4, 0.22); L(0.5, 0.1, 0.6, 0.22); L(0.5, 0.9, 0.4, 0.78); L(0.5, 0.9, 0.6, 0.78); L(0.1, 0.5, 0.22, 0.4); L(0.1, 0.5, 0.22, 0.6); L(0.9, 0.5, 0.78, 0.4); L(0.9, 0.5, 0.78, 0.6); break
    case "plus": L(0.5, 0.2, 0.5, 0.8); L(0.2, 0.5, 0.8, 0.5); break
    case "refresh": ctx.beginPath(); ctx.arc(w*0.5, h*0.5, w*0.3, 0.3, 1.7*PI); ctx.stroke(); T(0.72, 0.12, 0.72, 0.36, 0.5, 0.26); break
    case "host": R(0.1, 0.16, 0.8, 0.52); L(0.5, 0.68, 0.5, 0.84); L(0.3, 0.84, 0.7, 0.84); break
    case "kbd": R(0.08, 0.28, 0.84, 0.44); for (var kk = 0; kk < 4; kk++) L(0.2 + kk*0.2, 0.42, 0.22 + kk*0.2, 0.42); L(0.28, 0.58, 0.72, 0.58); break
    case "dot": C(0.5, 0.5, 0.2, true); break
    }
  }
}

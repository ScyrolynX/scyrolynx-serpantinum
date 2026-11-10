import QtQuick
// Every card/clock/scanner lives in one of these. In edit mode it can be dragged,
// resized from the bottom-right grip, and hidden / restored. Geometry is persisted by Main.qml.
Item {
  id: w
  property var app
  property string wid: ""
  default property alias content: body.data
  readonly property var def: app.defs[wid]
  readonly property var g: app.layout[wid]
  readonly property real cx: (g && g.cx !== undefined) ? g.cx : def.cx
  readonly property real cy: (g && g.cy !== undefined) ? g.cy : def.cy
  readonly property real lw: (g && g.w !== undefined) ? g.w : def.w
  readonly property real lh: (g && g.h !== undefined) ? g.h : def.h
  readonly property bool off: (g && g.hidden !== undefined) ? g.hidden : (def.hidden === true)
  readonly property bool editing: app.editing
  readonly property real sc: app.s

  width: lw * sc; height: lh * sc
  x: cx * parent.width - width / 2
  y: cy * parent.height - height / 2
  visible: !off || editing
  opacity: off ? 0.35 : 1
  Behavior on opacity { NumberAnimation { duration: 140 } }

  Item { id: body; anchors.fill: parent }

  function grid() { return app.st.snap ? 20 * sc : 0 }
  function snapv(v) { var g0 = grid(); return g0 > 0 ? Math.round(v / g0) * g0 : v }
  function commit(ncx, ncy, nw, nh, hid) {
    app.setGeo(wid, { cx: ncx, cy: ncy, w: nw, h: nh, hidden: hid })
  }

  // ---------------- edit overlay ----------------
  Item {
    id: ov
    anchors.fill: parent; visible: w.editing; z: 100
    Rectangle { anchors.fill: parent; color: Qt.rgba(w.app.ui.accent.r, w.app.ui.accent.g, w.app.ui.accent.b, 0.07)
                border.width: 1; border.color: w.app.ui.accent }
    // tag
    Rectangle { x: 0; y: -height; height: 16 * w.sc; width: tagTxt.implicitWidth + 12 * w.sc; color: w.app.ui.accent
      Lbl { id: tagTxt; app: w.app; anchors.centerIn: parent; text: w.def.title.toUpperCase() + "  " + Math.round(w.lw) + "×" + Math.round(w.lh); sz: 9; color: w.app.ui.ink; font.weight: Font.Bold } }
    // drag
    MouseArea {
      id: dragMa
      anchors.fill: parent; cursorShape: Qt.SizeAllCursor
      property real px0: 0; property real py0: 0; property real cx0: 0; property real cy0: 0
      onPressed: (m) => { var p = mapToItem(w.parent, m.x, m.y); px0 = p.x; py0 = p.y; cx0 = w.cx * w.parent.width; cy0 = w.cy * w.parent.height; w.z = ++w.app.zTop }
      onPositionChanged: (m) => {
        if (!pressed) return
        var p = mapToItem(w.parent, m.x, m.y)
        var tlx = w.snapv(cx0 + (p.x - px0) - w.width / 2), tly = w.snapv(cy0 + (p.y - py0) - w.height / 2)
        tlx = Math.max(0, Math.min(w.parent.width - w.width, tlx)); tly = Math.max(0, Math.min(w.parent.height - w.height, tly))
        w.commit((tlx + w.width / 2) / w.parent.width, (tly + w.height / 2) / w.parent.height, w.lw, w.lh, w.off)
      }
    }
    // hide / restore
    Rectangle { anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 4 * w.sc; width: 20 * w.sc; height: width; radius: 3; z: 3
      color: Qt.rgba(0, 0, 0, 0.6); border.width: 1; border.color: w.app.ui.accent
      Icon { anchors.centerIn: parent; width: 13 * w.sc; height: width; kind: w.off ? "eye" : "eyeoff"; color: w.app.ui.accent }
      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: w.commit(w.cx, w.cy, w.lw, w.lh, !w.off) } }
    // resize grip
    Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: 18 * w.sc; height: width; color: w.app.ui.accent; z: 3
      Canvas { anchors.fill: parent; onPaint: { var c = getContext("2d"); c.clearRect(0,0,width,height); c.strokeStyle = "#000"; c.lineWidth = 1.5
        c.beginPath(); c.moveTo(width*0.3, height*0.9); c.lineTo(width*0.9, height*0.3); c.moveTo(width*0.6, height*0.9); c.lineTo(width*0.9, height*0.6); c.stroke() } }
      MouseArea {
        anchors.fill: parent; cursorShape: Qt.SizeFDiagCursor
        property real px0: 0; property real py0: 0; property real w0: 0; property real h0: 0; property real tlx: 0; property real tly: 0
        onPressed: (m) => { var p = mapToItem(w.parent, m.x, m.y); px0 = p.x; py0 = p.y; w0 = w.width; h0 = w.height; tlx = w.x; tly = w.y; w.z = ++w.app.zTop }
        onPositionChanged: (m) => {
          if (!pressed) return
          var p = mapToItem(w.parent, m.x, m.y)
          var nw = w.snapv(w0 + p.x - px0), nh = w.snapv(h0 + p.y - py0)
          nw = Math.max(w.def.minW * w.sc, Math.min(w.parent.width - tlx, nw)); nh = Math.max(w.def.minH * w.sc, Math.min(w.parent.height - tly, nh))
          w.commit((tlx + nw / 2) / w.parent.width, (tly + nh / 2) / w.parent.height, nw / w.sc, nh / w.sc, w.off)
        }
      }
    }
  }
}

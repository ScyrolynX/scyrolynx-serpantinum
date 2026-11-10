import QtQuick
// key / value row
Item {
  id: kv
  property var app
  property string k: ""
  property string v: ""
  property color vColor: app.ui.text
  property string iconKind: ""
  height: 20 * app.s
  Icon { visible: kv.iconKind.length > 0; x: 0; anchors.verticalCenter: parent.verticalCenter; width: 13*kv.app.s; height: width; kind: kv.iconKind; color: kv.app.ui.accent }
  Lbl { app: kv.app; x: kv.iconKind.length ? 20*kv.app.s : 0; anchors.verticalCenter: parent.verticalCenter; text: kv.k; sz: 10; dim: true; font.letterSpacing: 1.2 }
  Lbl { app: kv.app; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: parent.width * 0.62; horizontalAlignment: Text.AlignRight
        text: kv.v; sz: 11.5; color: kv.vColor; font.weight: Font.Bold }
}

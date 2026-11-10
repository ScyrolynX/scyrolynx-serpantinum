import QtQuick
// Card chrome: titled header, hairline border, corner ticks. Children go in the body.
Rectangle {
  id: p
  property var app
  property string title: ""
  property string tag: ""
  property color tagColor: app.ui.dim
  property color dotColor: app.ui.accent
  property bool showDot: true
  property real pad: 10 * app.s
  default property alias content: body.data
  readonly property real headH: title.length ? 26 * app.s : 0
  readonly property real bodyW: body.width
  readonly property real bodyH: body.height
  radius: app.ui.r2; color: app.ui.card
  border.width: 1; border.color: app.ui.border
  clip: false

  Item { id: hdr; visible: p.title.length > 0; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; height: p.headH
    Rectangle { visible: p.showDot; x: 10*p.app.s; anchors.verticalCenter: parent.verticalCenter; width: 5*p.app.s; height: width; radius: 1; color: p.dotColor }
    Lbl { app: p.app; x: (p.showDot ? 22 : 10) * p.app.s; anchors.verticalCenter: parent.verticalCenter; text: p.title.toUpperCase(); sz: 10.5; font.weight: Font.Bold; font.letterSpacing: 1.6 }
    Lbl { app: p.app; anchors.right: parent.right; anchors.rightMargin: 10*p.app.s; anchors.verticalCenter: parent.verticalCenter; text: p.tag; sz: 10; color: p.tagColor; font.letterSpacing: 1 }
    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.leftMargin: 1; anchors.rightMargin: 1; height: 1; color: p.app.ui.border }
  }
  Item { id: body; anchors.top: hdr.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; clip: true }

  // corner ticks
  Repeater { model: 4
    Item { required property int index
      width: 9*p.app.s; height: width
      x: (index % 2 === 0) ? -1 : p.width - width + 1; y: index < 2 ? -1 : p.height - height + 1
      Rectangle { width: parent.width; height: 2; color: p.app.ui.accent; y: index < 2 ? 0 : parent.height - 2 }
      Rectangle { height: parent.height; width: 2; color: p.app.ui.accent; x: (index % 2 === 0) ? 0 : parent.width - 2 }
    }
  }
}

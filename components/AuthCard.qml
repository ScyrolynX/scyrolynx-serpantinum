import QtQuick
import QtQuick.Controls.Basic
// The real login form. Everything here is live input -> sddm.login().
Panel {
  id: ac
  title: "Authentication"
  tag: sddm.hostName.toUpperCase()
  dotColor: app.authState === "failed" ? app.ui.bad : (app.authState === "busy" ? app.ui.warn : app.ui.accent)
  property string curIcon: ""
  property alias userField: uf
  property alias pwField: pf
  readonly property string initials: (uf.text.length ? uf.text.charAt(0) : "?").toUpperCase()
  readonly property bool locked: app.authState === "busy" || app.cooldown > 0

  function focusPassword(initial) { pf.field.forceActiveFocus(); if (initial) pf.field.text += initial }
  function shake() { shakeAnim.restart(); pf.text = "" }
  function submit() { app.tryPassword(uf.text, pf.text) }

  transform: Translate { id: shakeT; x: 0 }
  SequentialAnimation { id: shakeAnim
    NumberAnimation { target: shakeT; property: "x"; to: -10*app.s; duration: 50 } NumberAnimation { target: shakeT; property: "x"; to: 10*app.s; duration: 80 }
    NumberAnimation { target: shakeT; property: "x"; to: -5*app.s; duration: 60 } NumberAnimation { target: shakeT; property: "x"; to: 0; duration: 50 } }

  Column {
    anchors.fill: parent; anchors.margins: 12 * app.s; spacing: 8 * app.s

    // identity row
    Row { spacing: 12 * app.s; height: 56 * app.s
      Item { width: 56*app.s; height: width
        Rectangle { id: avMask; anchors.fill: parent; radius: 4*app.s; visible: false; layer.enabled: true }
        Image { id: avImg; anchors.fill: parent; source: ac.curIcon.length ? ac.curIcon : app.avatarUrl; fillMode: Image.PreserveAspectCrop; visible: false; asynchronous: true; sourceSize: Qt.size(160, 160) }
        Rectangle { anchors.fill: parent; radius: 4*app.s; color: app.ui.field; border.width: 1; border.color: app.ui.accent
          Lbl { app: ac.app; anchors.centerIn: parent; text: ac.initials; sz: 26; color: app.ui.accent; font.weight: Font.Bold; visible: avImg.status !== Image.Ready } }
        Image { anchors.fill: parent; anchors.margins: 1; source: avImg.source; fillMode: Image.PreserveAspectCrop; visible: avImg.status === Image.Ready; asynchronous: true; sourceSize: Qt.size(160, 160) }
      }
      Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3*app.s; width: ac.bodyW - 24*app.s - 68*app.s
        Lbl { app: ac.app; width: parent.width; text: uf.text.length ? uf.text : "no user"; sz: 18; font.weight: Font.Bold; mono: false }
        Lbl { app: ac.app; width: parent.width; text: (uf.text.length ? uf.text : "?") + "@" + sddm.hostName; sz: 10.5; dim: true }
        Row { spacing: 6*app.s
          Rectangle { visible: app.caps; width: capsTxt.implicitWidth + 14*app.s; height: 16*app.s; radius: 2; color: Qt.rgba(1, 0.69, 0.12, 0.2); border.width: 1; border.color: app.ui.warn
            Row { anchors.centerIn: parent; spacing: 4*app.s; Icon { width: 10*app.s; height: width; kind: "caps"; color: app.ui.warn; anchors.verticalCenter: parent.verticalCenter }
              Lbl { id: capsTxt; app: ac.app; text: "CAPS LOCK"; sz: 9; color: app.ui.warn; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter } } }
          Rectangle { width: kbTxt.implicitWidth + 14*app.s; height: 16*app.s; radius: 2; color: "transparent"; border.width: 1; border.color: app.ui.border
            Lbl { id: kbTxt; app: ac.app; anchors.centerIn: parent; text: app.kbName; sz: 9; dim: true } }
        }
      }
    }

    // user switcher (only when there is more than one account)
    Flow { visible: userModel.count > 1; width: parent.width; spacing: 5*app.s
      Repeater { model: userModel
        Rectangle { required property string name; required property string icon
          width: chipTxt.implicitWidth + 18*app.s; height: 22*app.s; radius: app.ui.r3
          color: uf.text === name ? Qt.rgba(app.ui.accent.r, app.ui.accent.g, app.ui.accent.b, 0.22) : Qt.rgba(1,1,1,0.05)
          border.width: 1; border.color: uf.text === name ? app.ui.accent : app.ui.border
          Lbl { id: chipTxt; app: ac.app; anchors.centerIn: parent; text: name; sz: 10.5; color: uf.text === name ? app.ui.accent : app.ui.text }
          Component.onCompleted: if (name === userModel.lastUser) ac.curIcon = icon
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { uf.text = name; ac.curIcon = icon; app.log("INFO", "user → " + name); ac.focusPassword() } } } } }

    Field { id: uf; app: ac.app; width: parent.width; iconKind: "user"; placeholder: "username"; text: userModel.lastUser; enabled: !ac.locked
      onAccepted: ac.focusPassword(); onTextChanged: app.curUser = text }

    Item { width: parent.width; height: pf.height
      Field { id: pf; app: ac.app; width: parent.width - 44*app.s; iconKind: "key"; placeholder: ac.locked ? (app.cooldown > 0 ? "locked " + app.cooldown + "s" : "verifying…") : "password"
        secret: true; bad: app.authState === "failed"; enabled: !ac.locked
        onAccepted: ac.submit() }
      Rectangle { anchors.right: parent.right; width: 38*app.s; height: pf.height; radius: app.ui.r3; color: app.ui.accent; opacity: ac.locked ? 0.4 : 1
        Icon { anchors.centerIn: parent; width: 18*app.s; height: width; kind: "arrow"; color: app.ui.ink }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (!ac.locked) ac.submit() } }
    }

    Row { width: parent.width; spacing: 8 * app.s; height: 32 * app.s
      ComboBox {
        id: sess; width: parent.width - fpBtn.width - 8*app.s; height: 32*app.s
        model: sessionModel; textRole: "name"; currentIndex: sessionModel.lastIndex
        onActivated: (i) => app.sessionIndex = i
        Component.onCompleted: app.sessionIndex = currentIndex
        onDisplayTextChanged: app.sessionName = displayText
        background: Rectangle { radius: app.ui.r3; color: app.ui.field; border.width: sess.activeFocus ? 2 : 1; border.color: sess.activeFocus ? app.ui.accent : app.ui.border }
        contentItem: Lbl { app: ac.app; leftPadding: 10*app.s; rightPadding: 28*app.s; text: sess.displayText; sz: 12; verticalAlignment: Text.AlignVCenter }
        indicator: Icon { x: sess.width - width - 10*app.s; y: (sess.height - height)/2; width: 12*app.s; height: width; kind: "chevron"; color: app.ui.accent; rotation: 90 }
        delegate: ItemDelegate { id: dl; required property var model; required property int index
          width: sess.width; height: 30*app.s; highlighted: sess.highlightedIndex === index
          contentItem: Lbl { app: ac.app; text: dl.model[sess.textRole]; sz: 12; color: dl.highlighted ? app.ui.ink : app.ui.text; verticalAlignment: Text.AlignVCenter; leftPadding: 4*app.s }
          background: Rectangle { radius: app.ui.r3; color: dl.highlighted ? app.ui.accent : "transparent" } }
        popup: Popup { y: sess.height + 4*app.s; width: sess.width; padding: 4*app.s
          implicitHeight: Math.min(contentItem.implicitHeight + 8*app.s, 220*app.s)
          contentItem: ListView { clip: true; implicitHeight: contentHeight; model: sess.popup.visible ? sess.delegateModel : null; currentIndex: sess.highlightedIndex }
          background: Rectangle { radius: app.ui.r3; color: "#12161B"; border.width: 1; border.color: app.ui.accent } }
      }
      Btn { id: fpBtn; app: ac.app; width: 112*app.s; icon: "finger"; text: "FINGER"; busy: ac.locked; visible: app.fpEnabled; onClicked: app.tryFingerprint(uf.text) }
    }

    // status line
    Rectangle { width: parent.width; height: Math.max(40*app.s, ac.bodyH - y - 12*app.s); radius: app.ui.r3; color: Qt.rgba(0, 0, 0, 0.25)
      border.width: 1; border.color: app.authState === "failed" ? Qt.rgba(1, 0.36, 0.36, 0.6) : app.ui.border; clip: true
      Row { anchors.fill: parent; anchors.margins: 8*app.s; spacing: 8*app.s
        Icon { width: 14*app.s; height: width; anchors.verticalCenter: parent.verticalCenter
          kind: app.authState === "failed" ? "warn" : (app.authState === "busy" ? "refresh" : "shield"); color: app.authState === "failed" ? app.ui.bad : (app.authState === "busy" ? app.ui.warn : app.ui.accent) }
        Lbl { app: ac.app; width: parent.width - 26*app.s; anchors.verticalCenter: parent.verticalCenter; text: app.cooldown > 0 ? "Too many attempts — wait " + app.cooldown + "s" : app.statusText
          sz: 11; wrapMode: Text.WordWrap; maximumLineCount: 2; color: app.authState === "failed" ? app.ui.bad : app.ui.text } }
      Rectangle { visible: app.authState === "busy"; height: 2; width: parent.width * 0.3; color: app.ui.accent; anchors.bottom: parent.bottom
        SequentialAnimation on x { running: app.authState === "busy"; loops: Animation.Infinite
          NumberAnimation { from: 0; to: ac.bodyW * 0.7 - 24*app.s; duration: 700; easing.type: Easing.InOutSine } NumberAnimation { to: 0; duration: 700; easing.type: Easing.InOutSine } } }
    }
  }
}

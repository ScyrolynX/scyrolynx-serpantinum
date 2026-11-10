import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic
Item {
  id: d
  property var app
  readonly property var ui: app.ui
  readonly property real s: app.s
  opacity: app.dashOpen ? 1 : 0
  scale: app.dashOpen ? 1 : 0.965
  visible: opacity > 0.01
  Behavior on opacity { NumberAnimation { duration: d.ui.dMed; easing.type: Easing.OutCubic } }
  Behavior on scale { NumberAnimation { duration: d.ui.dMed; easing.type: Easing.OutCubic } }
  function focusPassword() { pw.forceActiveFocus() }
  function shake() { shakeAnim.restart(); pw.text = "" }
  readonly property string initials: (userField.text.length ? userField.text.charAt(0) : "?").toUpperCase()

  Rectangle {
    id: panel
    anchors.centerIn: parent
    width: Math.min(d.width - 60*s, 1680*s); height: Math.min(d.height - 110*s, 740*s)
    radius: ui.r1; color: ui.panel; border.width: 1; border.color: ui.border

    Rectangle { // close
      z: 10; anchors.right: parent.right; anchors.bottom: parent.top; anchors.bottomMargin: 10*d.s; width: 44*d.s; height: width; radius: width/2
      color: Qt.rgba(1,0.85,0.55,0.14); border.width: 1; border.color: ui.border
      Icon { anchors.centerIn: parent; width: 18*d.s; height: width; kind: "close"; color: ui.ivory }
      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.back() }
    }

    RowLayout {
      anchors.fill: parent; anchors.margins: 34*d.s; spacing: 28*d.s

      // ================= LEFT =================
      ColumnLayout {
        Layout.preferredWidth: 30; Layout.fillWidth: true; Layout.fillHeight: true; spacing: 18*d.s
        Item {
          Layout.fillWidth: true; Layout.preferredHeight: 280*d.s
          Icon { x: 6*d.s; y: 6*d.s; width: 84*d.s; height: width; kind: "cloud"; color: ui.fpTone }
          Text { x: 0; anchors.bottom: parent.bottom; anchors.bottomMargin: 56*d.s; text: Qt.formatDate(app.now, "dd"); color: ui.ivory
            font.family: ui.font; font.weight: Font.Black; font.pixelSize: 120*d.s }
          Text { x: 4*d.s; anchors.bottom: parent.bottom; anchors.bottomMargin: 26*d.s; text: Qt.formatDate(app.now, "dddd · MMMM yyyy"); color: ui.ivory; opacity: 0.75
            font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 16*d.s }
          Column { anchors.right: parent.right; anchors.top: parent.top; anchors.topMargin: 6*d.s; spacing: 2*d.s
            Text { anchors.right: parent.right; text: "ScyrolynX"; color: ui.ivory; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 24*d.s }
            Text { anchors.right: parent.right; text: "Secure login"; color: ui.ivory; opacity: 0.7; font.family: ui.font; font.pixelSize: 16*d.s } }
          Row { anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.bottomMargin: 20*d.s; spacing: 14*d.s
            Repeater { model: [ { k: "lock", t: "LOCKED" }, { k: "key", t: "PASSWORD" }, { k: "finger", t: "FINGER" }, { k: "shield", t: "PAM" } ]
              Column { required property var modelData; spacing: 4*d.s
                Icon { anchors.horizontalCenter: parent.horizontalCenter; width: 28*d.s; height: width; kind: modelData.k; color: ui.gold }
                Text { text: modelData.t; color: ui.ivory; opacity: 0.8; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 11*d.s } } } }
        }
        GridLayout {
          Layout.fillWidth: true; Layout.fillHeight: true; columns: 2; rowSpacing: 14*d.s; columnSpacing: 14*d.s
          Tile { app: d.app; Layout.fillWidth: true; Layout.fillHeight: true; label: "SECURITY"; iconKind: "shield"; tint: "#F3EBDD"; fill: 0.42
                 value: app.authState === "failed" ? "RETRY" : (app.authState === "busy" ? "AUTH…" : "LOCKED") }
          Tile { app: d.app; Layout.fillWidth: true; Layout.fillHeight: true; label: "WORKSTATION"; iconKind: "user"; tint: "#E8B7C0"; fill: 0.6; value: sddm.hostName }
          Tile { app: d.app; Layout.fillWidth: true; Layout.fillHeight: true; label: "AUTH"; iconKind: "key"; tint: "#E8B7C0"; fill: 0.75
                 value: app.fpEnabled ? "PW + FP" : "PW" }
          Tile { app: d.app; Layout.fillWidth: true; Layout.fillHeight: true; label: "SESSION"; iconKind: "finger"; tint: "#E8B7C0"; fill: 0.5; value: sess.displayText }
        }
      }

      // ================= CENTRE =================
      ColumnLayout {
        Layout.preferredWidth: 35; Layout.fillWidth: true; Layout.fillHeight: true; spacing: 12*d.s
        Item {
          id: av; Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 184*d.s; Layout.preferredHeight: 184*d.s
          Rectangle { id: avMask; anchors.fill: parent; radius: width/2; visible: false; layer.enabled: true }
          Image { id: avImg; anchors.fill: parent; source: app.avatarUrl; fillMode: Image.PreserveAspectCrop; visible: false; asynchronous: true; sourceSize: Qt.size(400, 400) }
          MultiEffect { anchors.fill: parent; source: avImg; maskEnabled: true; maskSource: avMask; visible: avImg.status === Image.Ready }
          Rectangle { anchors.fill: parent; radius: width/2; visible: avImg.status !== Image.Ready; color: ui.cocoa
            Text { anchors.centerIn: parent; text: d.initials; color: ui.gold; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 84*d.s } }
          Rectangle { anchors.fill: parent; radius: width/2; color: "transparent"; border.width: 3*d.s; border.color: ui.gold }
        }
        RowLayout {
          Layout.fillWidth: true; spacing: 12*d.s
          Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 52*d.s; radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.14); border.width: 1; border.color: ui.border
            Icon { x: 14*d.s; anchors.verticalCenter: parent.verticalCenter; width: 22*d.s; height: width; kind: "user"; color: ui.ivory }
            TextField { id: userField; anchors.fill: parent; anchors.leftMargin: 44*d.s; text: userModel.lastUser; color: ui.ivory; selectionColor: ui.gold; selectedTextColor: ui.espresso
              font.family: ui.font; font.weight: Font.Black; font.pixelSize: 19*d.s; verticalAlignment: TextInput.AlignVCenter; background: Item {}
              onAccepted: pw.forceActiveFocus() } }
          Rectangle { Layout.preferredWidth: 150*d.s; Layout.preferredHeight: 52*d.s; radius: ui.r3; border.width: 1; border.color: ui.border
            color: app.authState === "failed" ? Qt.rgba(0.9,0.45,0.4,0.35) : Qt.rgba(1,0.85,0.55,0.14)
            Row { anchors.centerIn: parent; spacing: 8*d.s
              Icon { width: 20*d.s; height: width; kind: "lock"; color: app.authState === "failed" ? "#E5736A" : ui.ivory }
              Text { text: app.authState === "busy" ? "Verifying" : (app.authState === "failed" ? "Denied" : "Locked"); color: ui.ivory; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 18*d.s } } }
        }
        Rectangle {
          id: pwBox; Layout.fillWidth: true; Layout.preferredHeight: 60*d.s; radius: ui.r3
          color: Qt.rgba(1,0.85,0.55,0.14); border.width: pw.activeFocus ? 2 : 1
          border.color: app.authState === "failed" ? "#E5736A" : (pw.activeFocus ? ui.gold : ui.border)
          transform: Translate { id: shakeT; x: 0 }
          SequentialAnimation { id: shakeAnim
            NumberAnimation { target: shakeT; property: "x"; to: -12*d.s; duration: 55 } NumberAnimation { target: shakeT; property: "x"; to: 12*d.s; duration: 90 }
            NumberAnimation { target: shakeT; property: "x"; to: -6*d.s; duration: 70 } NumberAnimation { target: shakeT; property: "x"; to: 0; duration: 50 } }
          Icon { x: 16*d.s; anchors.verticalCenter: parent.verticalCenter; width: 24*d.s; height: width; kind: "lock"; color: ui.gold }
          TextField { id: pw; anchors.fill: parent; anchors.leftMargin: 54*d.s; anchors.rightMargin: 72*d.s; echoMode: TextInput.Password; passwordCharacter: "●"
            placeholderText: "Password"; placeholderTextColor: Qt.rgba(0.95,0.92,0.87,0.4); color: ui.ivory; selectionColor: ui.gold; selectedTextColor: ui.espresso
            font.family: ui.font; font.pixelSize: 20*d.s; verticalAlignment: TextInput.AlignVCenter; background: Item {}
            enabled: app.authState !== "busy"
            onAccepted: app.tryPassword(userField.text, pw.text)
            Keys.onEscapePressed: app.back() }
          Rectangle { anchors.right: parent.right; anchors.rightMargin: 8*d.s; anchors.verticalCenter: parent.verticalCenter; width: 52*d.s; height: 44*d.s; radius: ui.r3; color: ui.fpTone
            opacity: app.authState === "busy" ? 0.5 : 1
            Icon { anchors.centerIn: parent; width: 22*d.s; height: width; kind: "chevron"; color: ui.espresso }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.tryPassword(userField.text, pw.text) } }
        }
        RowLayout {
          Layout.fillWidth: true; spacing: 12*d.s
          ComboBox {
            id: sess; Layout.fillWidth: true; Layout.preferredHeight: 48*d.s
            model: sessionModel; textRole: "name"; currentIndex: sessionModel.lastIndex
            onActivated: (i) => app.sessionIndex = i
            Component.onCompleted: app.sessionIndex = currentIndex
            background: Rectangle { radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.14); border.width: sess.activeFocus ? 2 : 1; border.color: sess.activeFocus ? ui.gold : ui.border }
            contentItem: Text { leftPadding: 16*d.s; rightPadding: 34*d.s; text: sess.displayText; color: ui.ivory; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 17*d.s
              verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
            indicator: Icon { x: sess.width - width - 12*d.s; y: (sess.height - height)/2; width: 16*d.s; height: width; kind: "chevron"; color: ui.gold; rotation: 90 }
            delegate: ItemDelegate {
              id: dl; required property var model; required property int index
              width: sess.width; height: 42*d.s; highlighted: sess.highlightedIndex === index
              contentItem: Text { text: dl.model[sess.textRole]; color: dl.highlighted ? ui.espresso : ui.ivory; font.family: ui.font; font.pixelSize: 16*d.s; verticalAlignment: Text.AlignVCenter; leftPadding: 8*d.s }
              background: Rectangle { radius: ui.r3; color: dl.highlighted ? ui.gold : "transparent" }
            }
            popup: Popup {
              y: -implicitHeight - 6*d.s; width: sess.width; padding: 6*d.s
              implicitHeight: Math.min(contentItem.implicitHeight + 12*d.s, 300*d.s)
              contentItem: ListView { clip: true; implicitHeight: contentHeight; model: sess.popup.visible ? sess.delegateModel : null; currentIndex: sess.highlightedIndex }
              background: Rectangle { radius: ui.r2; color: "#241A14"; border.width: 1; border.color: ui.border }
            }
          }
          Rectangle { Layout.preferredWidth: 160*d.s; Layout.preferredHeight: 48*d.s; radius: ui.r3; color: ui.gold; opacity: app.authState === "busy" ? 0.5 : 1
            Row { anchors.centerIn: parent; spacing: 8*d.s
              Icon { width: 20*d.s; height: width; kind: "finger"; color: ui.espresso }
              Text { text: "Fingerprint"; color: ui.espresso; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 16*d.s } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.tryFingerprint(userField.text) } }
        }
        Item { Layout.fillHeight: true; Layout.fillWidth: true
          FingerprintScanner { anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; app: d.app; box: 104*d.s; mode: app.fpMode; onClicked: app.tryFingerprint(userField.text) } }
      }

      // ================= RIGHT =================
      ColumnLayout {
        Layout.preferredWidth: 33; Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16*d.s
        Card {
          app: d.app; Layout.fillWidth: true; Layout.fillHeight: true; radius: ui.r2
          Text { x: 22*d.s; y: 20*d.s; text: "Notifications"; color: ui.ivory; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 20*d.s }
          Rectangle { anchors.right: parent.right; anchors.rightMargin: 74*d.s; y: 14*d.s; width: 112*d.s; height: 36*d.s; radius: ui.r3; color: ui.gold
            Row { anchors.centerIn: parent; spacing: 6*d.s
              Icon { width: 16*d.s; height: width; kind: "moon"; color: ui.espresso }
              Text { text: "Silent"; color: ui.espresso; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 14*d.s } } }
          Column { anchors.centerIn: parent; spacing: 14*d.s
            Item { width: 170*d.s; height: 90*d.s; anchors.horizontalCenter: parent.horizontalCenter
              Rectangle { id: cat; x: 30*d.s; y: 8*d.s; width: 110*d.s; height: 50*d.s; radius: 25*d.s; color: ui.ivory
                Rectangle { x: 10*d.s; y: -9*d.s; width: 22*d.s; height: 22*d.s; rotation: 45; radius: 4*d.s; color: ui.ivory }
                Rectangle { x: 76*d.s; y: -9*d.s; width: 22*d.s; height: 22*d.s; rotation: 45; radius: 4*d.s; color: ui.ivory } }
              Rectangle { x: 0; y: 34*d.s; width: 170*d.s; height: 52*d.s; radius: 26*d.s; color: ui.fpTone; border.width: 2*d.s; border.color: "#F6D6DC" } }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "You're all caught up."; color: ui.gold; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 17*d.s }
            Text { anchors.horizontalCenter: parent.horizontalCenter; width: 300*d.s; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
              text: app.statusText; color: app.authState === "failed" ? "#E5736A" : ui.ivory; opacity: 0.8; font.family: ui.font; font.pixelSize: 14*d.s }
          }
        }
        MusicCard { app: d.app; Layout.fillWidth: true; Layout.preferredHeight: 150*d.s }
      }
    }
  }
}

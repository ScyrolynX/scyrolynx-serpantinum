import QtQuick
import QtQuick.Layouts
Rectangle {
  id: cp
  property var app
  readonly property var ui: app.ui
  readonly property real s: app.s
  width: 360*s; height: Math.min(parent.height - 80*s, col.implicitHeight + 40*s)
  radius: ui.r1; color: Qt.rgba(0.11, 0.08, 0.06, 0.94); border.width: 1; border.color: ui.border
  opacity: app.customizing ? 1 : 0; visible: opacity > 0.01
  x: app.customizing ? parent.width - width - 30*s : parent.width
  Behavior on opacity { NumberAnimation { duration: ui.dMed; easing.type: Easing.OutCubic } }
  Behavior on x { NumberAnimation { duration: ui.dMed; easing.type: Easing.OutCubic } }
  MouseArea { anchors.fill: parent }
  ColumnLayout {
    id: col; anchors.fill: parent; anchors.margins: 20*cp.s; spacing: 10*cp.s
    RowLayout { Layout.fillWidth: true
      Text { text: "Customize"; color: ui.ivory; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 22*cp.s; Layout.fillWidth: true }
      Rectangle { Layout.preferredWidth: 80*cp.s; Layout.preferredHeight: 34*cp.s; radius: ui.r3; color: ui.gold
        Text { anchors.centerIn: parent; text: "Done"; color: ui.espresso; font.family: ui.font; font.weight: Font.Black; font.pixelSize: 14*cp.s }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.customizing = false } } }
    Text { Layout.fillWidth: true; wrapMode: Text.WordWrap; text: "Drag the clock and the fingerprint on the lock screen to move them. Changes save automatically."
      color: ui.ivory; opacity: 0.6; font.family: ui.font; font.pixelSize: 12*cp.s }
    ThemeSlider { app: cp.app; Layout.fillWidth: true; label: "Background blur"; from: 0; to: 1; value: app.st.blur; onMoved: (v) => app.st.blur = v }
    ThemeSlider { app: cp.app; Layout.fillWidth: true; label: "Darkness"; from: 0; to: 0.9; value: app.st.darkness; onMoved: (v) => app.st.darkness = v }
    ThemeSlider { app: cp.app; Layout.fillWidth: true; label: "Card opacity"; from: 0.2; to: 0.95; value: app.st.cardAlpha; onMoved: (v) => app.st.cardAlpha = v }
    ThemeSlider { app: cp.app; Layout.fillWidth: true; label: "Clock size"; from: 0.6; to: 1.6; value: app.st.clockScale; onMoved: (v) => app.st.clockScale = v }
    Text { text: "Colour"; color: ui.ivory; opacity: 0.85; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 14*cp.s }
    Row { spacing: 10*cp.s
      Repeater { model: app.palettes
        Rectangle { required property int index; required property var modelData
          width: 40*cp.s; height: width; radius: width/2; color: modelData.gold
          border.width: app.st.accent === index ? 3*cp.s : 1; border.color: app.st.accent === index ? ui.ivory : ui.border
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.st.accent = index } } } }
    Text { text: "Clock layout"; color: ui.ivory; opacity: 0.85; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 14*cp.s }
    Seg { app: cp.app; Layout.fillWidth: true; width: 320*cp.s; items: ["2 × 2", "Inline"]; current: app.st.clockStyle; onPicked: (i) => app.st.clockStyle = i }
    Text { text: "Fingerprint style"; color: ui.ivory; opacity: 0.85; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 14*cp.s }
    Seg { app: cp.app; Layout.fillWidth: true; width: 320*cp.s; items: ["Frame", "Ring", "Minimal"]; current: app.st.fpStyle; onPicked: (i) => app.st.fpStyle = i }
    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38*cp.s; radius: ui.r3; color: Qt.rgba(1,0.85,0.55,0.12); border.width: 1; border.color: ui.border
      Text { anchors.centerIn: parent; text: "Reset to defaults"; color: ui.ivory; font.family: ui.font; font.weight: Font.Bold; font.pixelSize: 14*cp.s }
      MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.resetCustomization() } }
  }
}

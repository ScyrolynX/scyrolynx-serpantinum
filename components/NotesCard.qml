import QtQuick
import QtQuick.Controls.Basic
// Free-text scratchpad. Persisted in the greeter settings file. NOTE: readable on the lock screen.
Panel {
  id: nc
  title: "Scratchpad"
  tag: "PUBLIC"
  tagColor: app.ui.warn
  ScrollView {
    anchors.fill: parent; anchors.margins: 8*app.s; clip: true
    TextArea {
      id: ta
      text: app.st.notes; placeholderText: "type here — visible on lock screen"; placeholderTextColor: app.ui.dim
      color: app.ui.text; selectionColor: app.ui.accent; selectedTextColor: app.ui.ink
      font.family: app.ui.font; font.pixelSize: 12*app.s; wrapMode: TextEdit.Wrap; background: Item {}
      onTextChanged: if (text !== app.st.notes) app.st.notes = text
    }
  }
}

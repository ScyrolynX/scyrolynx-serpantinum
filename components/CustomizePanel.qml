import QtQuick
import QtQuick.Controls.Basic
// In-greeter customization drawer. Opening it switches the screen into layout-edit mode.
Rectangle {
  id: cp
  property var app
  readonly property var ui: app.ui
  readonly property real s: app.s
  readonly property var sceneWidgets: app.widgetDefs.filter(function (d) { return d.scene === "both" || d.scene === app.sceneName })
  width: 348 * s; height: parent.height - 2 * 56 * s
  y: 56 * s
  radius: ui.r2; color: Qt.rgba(0.05, 0.06, 0.08, 0.95); border.width: 1; border.color: ui.accent
  opacity: app.editing ? 1 : 0; visible: opacity > 0.01
  x: app.editing ? parent.width - width - 24 * s : parent.width + 10
  Behavior on opacity { NumberAnimation { duration: ui.dMed; easing.type: Easing.OutCubic } }
  Behavior on x { NumberAnimation { duration: ui.dMed; easing.type: Easing.OutCubic } }
  MouseArea { anchors.fill: parent }   // swallow clicks

  Item { id: head; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; height: 44 * s
    Icon { x: 14*cp.s; anchors.verticalCenter: parent.verticalCenter; width: 16*cp.s; height: width; kind: "sliders"; color: ui.accent }
    Lbl { app: cp.app; x: 38*cp.s; anchors.verticalCenter: parent.verticalCenter; text: "CUSTOMIZE"; sz: 12; font.weight: Font.Bold; font.letterSpacing: 2 }
    Btn { app: cp.app; anchors.right: parent.right; anchors.rightMargin: 10*cp.s; anchors.verticalCenter: parent.verticalCenter; width: 66*cp.s; height: 26*cp.s; primary: true; text: "DONE"; onClicked: app.editing = false }
    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: ui.border }
  }
  Seg { id: tabs; app: cp.app; anchors.top: head.bottom; anchors.topMargin: 10*cp.s; anchors.horizontalCenter: parent.horizontalCenter; width: parent.width - 24*cp.s
        items: ["LAYOUT", "WALLPAPER", "STYLE"]; current: app.tab; onPicked: (i) => app.tab = i }

  Flickable {
    id: fl
    anchors.top: tabs.bottom; anchors.topMargin: 10*cp.s; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 12*cp.s
    contentWidth: width; contentHeight: col.implicitHeight; clip: true; boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar { width: 4 }
    Column {
      id: col; width: fl.width; spacing: 9 * cp.s

      // ======================= LAYOUT =======================
      Column { visible: app.tab === 0; width: parent.width; spacing: 9*cp.s
        Lbl { app: cp.app; width: parent.width; wrapMode: Text.WordWrap; sz: 10.5; dim: true
              text: "Drag any block to move it. Pull the corner grip to resize. The eye hides or restores a block. Everything is saved automatically." }
        Toggle { app: cp.app; width: parent.width; label: "Snap to 20px grid"; on: app.st.snap; onToggled: (v) => app.st.snap = v }
        ThemeSlider { app: cp.app; width: parent.width; label: "INTERFACE SCALE"; from: 0.7; to: 1.4; value: app.st.uiScale; onMoved: (v) => app.st.uiScale = v; unit: "×" }
        Lbl { app: cp.app; text: "BLOCKS — " + (app.dashOpen ? "LOGIN SCREEN" : "LOCK SCREEN"); sz: 10; dim: true; font.letterSpacing: 1.4 }
        Repeater { model: cp.sceneWidgets
          Toggle { required property var modelData; app: cp.app; width: col.width; label: modelData.title; on: !app.isOff(modelData.id); onToggled: (v) => app.setHidden(modelData.id, !v) } }
        Row { spacing: 8*cp.s; width: parent.width
          Btn { app: cp.app; width: (parent.width - 8*cp.s)/2; text: "RESET SCREEN"; onClicked: app.resetScene(app.sceneName) }
          Btn { app: cp.app; width: (parent.width - 8*cp.s)/2; text: "RESET ALL"; danger: true; onClicked: app.resetAll() } }
      }

      // ======================= WALLPAPER =======================
      Column { visible: app.tab === 1; width: parent.width; spacing: 9*cp.s
        Lbl { app: cp.app; text: "WALLPAPER FOLDER"; sz: 10; dim: true; font.letterSpacing: 1.4 }
        Row { width: parent.width; spacing: 6*cp.s
          Field { id: dirF; app: cp.app; width: parent.width - 66*cp.s; iconKind: "folder"; placeholder: "/usr/share/backgrounds"; text: app.wallDir; mono: true
            onAccepted: app.setWallDir(text) }
          Btn { app: cp.app; width: 60*cp.s; height: dirF.height; text: "SCAN"; primary: true; onClicked: app.setWallDir(dirF.text) } }
        Lbl { app: cp.app; width: parent.width; wrapMode: Text.WordWrap; sz: 10; color: app.wallModel.count > 0 ? app.ui.ok : app.ui.warn
              text: app.wallModel.count > 0 ? app.wallModel.count + " images found" : "No images found. Use an absolute path the 'sddm' user can read (no ~)." }
        Rectangle { width: parent.width; height: 196*cp.s; radius: ui.r3; color: Qt.rgba(0,0,0,0.3); border.width: 1; border.color: ui.border; clip: true
          GridView {
            id: gv; anchors.fill: parent; anchors.margins: 6*cp.s; cellWidth: Math.floor(width / 3); cellHeight: cellWidth * 0.62; model: app.wallModel; clip: true
            ScrollBar.vertical: ScrollBar { width: 4 }
            delegate: Item { required property url fileUrl; required property string fileName
              width: gv.cellWidth; height: gv.cellHeight
              Rectangle { anchors.fill: parent; anchors.margins: 2*cp.s; color: Qt.rgba(1,1,1,0.05); border.width: String(fileUrl) === String(app.wallUrl) ? 2 : 1
                border.color: String(fileUrl) === String(app.wallUrl) ? ui.accent : ui.border
                Image { anchors.fill: parent; anchors.margins: 2; source: fileUrl; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize: Qt.size(220, 140) } }
              MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.pickWallpaper(fileUrl) } } } }
        Row { spacing: 8*cp.s; width: parent.width
          Btn { app: cp.app; width: (parent.width - 8*cp.s)/2; text: "THEME DEFAULT"; icon: "image"; onClicked: { app.st.wallpaperFile = ""; app.log("INFO", "wallpaper → theme default") } }
          Btn { app: cp.app; width: (parent.width - 8*cp.s)/2; text: "SHUFFLE"; icon: "refresh"; onClicked: app.shuffleWallpaper() } }
        Lbl { app: cp.app; text: "SLIDESHOW"; sz: 10; dim: true; font.letterSpacing: 1.4 }
        Seg { app: cp.app; width: parent.width; items: ["OFF", "1 MIN", "5 MIN", "15 MIN"]; current: app.st.slideshow; onPicked: (i) => app.st.slideshow = i }
        ThemeSlider { app: cp.app; width: parent.width; label: "BLUR"; from: 0; to: 1; value: app.st.blur; onMoved: (v) => app.st.blur = v }
        ThemeSlider { app: cp.app; width: parent.width; label: "DARKNESS"; from: 0; to: 0.9; value: app.st.darkness; onMoved: (v) => app.st.darkness = v }
      }

      // ======================= STYLE =======================
      Column { visible: app.tab === 2; width: parent.width; spacing: 9*cp.s
        Lbl { app: cp.app; text: "ACCENT"; sz: 10; dim: true; font.letterSpacing: 1.4 }
        Flow { width: parent.width; spacing: 8*cp.s
          Repeater { model: app.palettes
            Rectangle { required property int index; required property var modelData
              width: 30*cp.s; height: width; radius: 4; color: modelData.gold
              border.width: app.st.palette === index ? 3 : 1; border.color: app.st.palette === index ? ui.text : ui.border
              MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: app.st.palette = index } } } }
        Lbl { app: cp.app; text: app.palettes[Math.min(app.palettes.length - 1, app.st.palette)].name.toUpperCase(); sz: 10; color: ui.accent; font.letterSpacing: 1.4 }
        ThemeSlider { app: cp.app; width: parent.width; label: "CARD OPACITY"; from: 0.2; to: 0.98; value: app.st.cardAlpha; onMoved: (v) => app.st.cardAlpha = v }
        Lbl { app: cp.app; text: "CLOCK"; sz: 10; dim: true; font.letterSpacing: 1.4 }
        Seg { app: cp.app; width: parent.width; items: ["CHECKER", "INLINE", "HUD"]; current: app.st.clockStyle; onPicked: (i) => app.st.clockStyle = i }
        Toggle { app: cp.app; width: parent.width; label: "Show seconds (HUD)"; on: app.st.showSeconds; onToggled: (v) => app.st.showSeconds = v }
        Toggle { app: cp.app; width: parent.width; label: "12-hour clock"; on: app.st.hour12; onToggled: (v) => app.st.hour12 = v }
        Lbl { app: cp.app; text: "FINGERPRINT SCANNER"; sz: 10; dim: true; font.letterSpacing: 1.4 }
        Seg { app: cp.app; width: parent.width; items: ["HUD", "RING", "MINIMAL"]; current: app.st.fpStyle; onPicked: (i) => app.st.fpStyle = i }
        Lbl { app: cp.app; text: "GREETING"; sz: 10; dim: true; font.letterSpacing: 1.4 }
        Field { app: cp.app; width: parent.width; iconKind: "terminal"; text: app.welcomeText; mono: false; onTextChanged: if (text !== app.welcomeText) app.st.welcome = text }
        Btn { app: cp.app; width: parent.width; text: "RESET STYLE"; onClicked: app.resetStyle() }
      }
    }
  }
}

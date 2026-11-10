import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtCore
import "components"

Item {
  id: root
  width: 1920; height: 1080
  focus: true

  // ---------- config helpers (theme.conf) ----------
  function cfgStr(k, d) { var v = config[k]; return (v === undefined || v === null || v === "") ? d : String(v) }
  function cfgBool(k, d) { var v = config[k]; if (v === undefined || v === null || v === "") return d; return String(v).toLowerCase() === "true" }
  function toUrl(p) { if (!p) return ""; if (p.indexOf("/") === 0) return "file://" + p; return Qt.resolvedUrl(p) }

  readonly property real s: Math.max(0.45, Math.min(width / 1920, height / 1080))
  property alias ui: uiObj
  property alias st: stObj
  property date now: new Date()
  property bool dashOpen: false
  property bool customizing: false
  property string authState: "idle"      // idle | busy | failed
  property string fpMode: "idle"         // idle | waiting | accepted | rejected | unavailable
  property bool fpPending: false
  property string statusText: "Locked — sign in to continue."
  property int sessionIndex: sessionModel.lastIndex
  readonly property bool use24h: cfgBool("clock_24h", true)
  readonly property bool showPower: cfgBool("show_power", true)
  readonly property bool fpEnabled: cfgBool("fingerprint_enabled", true)
  readonly property string welcomeText: cfgStr("welcome_text", "Hi Dev-Scyrolynx")
  readonly property string brandText: cfgStr("brand_text", "SCYROLYNX")
  readonly property url avatarUrl: toUrl(cfgStr("avatar", ""))
  readonly property var palettes: [
    { name: "Arc Gold", gold: "#D6B36A", alt: "#F3EBDD" },
    { name: "Bronze",   gold: "#C98B55", alt: "#F3EBDD" },
    { name: "Rose",     gold: "#E8B7C0", alt: "#F3EBDD" },
    { name: "Ivory",    gold: "#F3EBDD", alt: "#D6B36A" },
    { name: "Citrine",  gold: "#FFD21F", alt: "#FFFFFF" }
  ]

  // ---------- persisted customization (written by the greeter itself) ----------
  Settings {
    id: stObj
    location: "file://" + root.cfgStr("settings_path", "/var/lib/sddm/.config/scyrolynx-serpantinum.conf")
    property real clockX: 0.5
    property real clockY: 0.36
    property real clockScale: 1.0
    property int clockStyle: 0
    property real fpX: 0.5
    property real fpY: 0.86
    property int fpStyle: 0
    property real blur: 0.8
    property real darkness: 0.55
    property real cardAlpha: 0.66
    property int accent: 0
  }
  function resetCustomization() {
    st.clockX = 0.5; st.clockY = 0.36; st.clockScale = 1.0; st.clockStyle = 0; st.fpX = 0.5; st.fpY = 0.86
    st.fpStyle = 0; st.blur = 0.8; st.darkness = 0.55; st.cardAlpha = 0.66; st.accent = 0
  }

  // ---------- design tokens ----------
  QtObject {
    id: uiObj
    readonly property string font: root.cfgStr("font_family", "Nunito")
    readonly property color espresso: "#17120F"
    readonly property color walnut: "#241A14"
    readonly property color bronze: "#A87345"
    readonly property color ivory: "#F3EBDD"
    readonly property color cocoa: "#3A2A20"
    readonly property color fpTone: "#E8B7C0"
    readonly property var pal: root.palettes[Math.max(0, Math.min(root.palettes.length - 1, stObj.accent))]
    readonly property color gold: pal.gold
    readonly property color digitA: pal.alt
    readonly property color digitB: pal.gold
    readonly property color card: Qt.rgba(0.50, 0.34, 0.17, stObj.cardAlpha)
    readonly property color panel: Qt.rgba(0.27, 0.18, 0.10, Math.min(0.95, stObj.cardAlpha + 0.2))
    readonly property color border: Qt.rgba(1, 0.9, 0.7, 0.16)
    readonly property real r1: 34 * root.s
    readonly property real r2: 22 * root.s
    readonly property real r3: 14 * root.s
    readonly property int dFast: 140
    readonly property int dMed: 380
  }

  Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }
  Timer { id: fpReset; interval: 3500; onTriggered: { root.fpMode = "idle"; if (root.authState === "failed") root.authState = "idle" } }

  // ---------- navigation ----------
  function openDash() { dashOpen = true; Qt.callLater(function () { dash.focusPassword() }) }
  function back() {
    if (customizing) customizing = false
    else if (dashOpen) { dashOpen = false; root.forceActiveFocus() }
  }
  Shortcut { sequence: "Escape"; onActivated: root.back() }
  Keys.onPressed: (e) => { if (!dashOpen && !customizing && e.text.length > 0 && e.key !== Qt.Key_Escape) openDash() }

  // ---------- authentication (all real SDDM calls) ----------
  function tryPassword(user, pw) {
    if (authState === "busy" || user.length === 0) return
    fpPending = false; authState = "busy"; statusText = "Verifying…"
    sddm.login(user, pw, sessionIndex)
  }
  // Fingerprint: starts the SAME PAM conversation with an empty password. Works only when
  // /etc/pam.d/sddm lists pam_fprintd.so as "sufficient" before pam_unix (see docs/AUTHENTICATION.md).
  function tryFingerprint(user) {
    if (!fpEnabled) { fpMode = "unavailable"; statusText = "Fingerprint is disabled in theme.conf."; fpReset.restart(); return }
    if (authState === "busy" || user.length === 0) return
    fpPending = true; authState = "busy"; fpMode = "waiting"; statusText = "Place your finger on the sensor…"
    sddm.login(user, "", sessionIndex)
  }
  Connections {
    target: sddm
    function onLoginSucceeded() { root.authState = "idle"; root.statusText = "Authenticated — starting session…"; if (root.fpPending) root.fpMode = "accepted" }
    function onLoginFailed() {
      root.authState = "failed"
      if (root.fpPending) { root.fpMode = "rejected"; root.statusText = "Fingerprint not accepted. Use your password." }
      else root.statusText = "Incorrect password. Try again."
      root.fpPending = false; fpReset.restart(); dash.shake()
    }
  }

  // ---------- background ----------
  Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: uiObj.espresso } GradientStop { position: 1; color: uiObj.walnut } } }
  Image { id: wp; anchors.fill: parent; source: root.toUrl(root.cfgStr("wallpaper", "assets/images/wallpaper.jpg")); fillMode: Image.PreserveAspectCrop
          asynchronous: true; sourceSize: Qt.size(root.width, root.height); visible: root.cfgBool("disable_blur", false) }
  MultiEffect { anchors.fill: parent; source: wp; visible: !root.cfgBool("disable_blur", false) && wp.status === Image.Ready
                blurEnabled: true; blurMax: 64; blur: stObj.blur; autoPaddingEnabled: false }
  Rectangle { anchors.fill: parent; color: "black"; opacity: stObj.darkness }
  Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: "#99000000" } GradientStop { position: 0.3; color: "#00000000" }
                                                         GradientStop { position: 0.7; color: "#00000000" } GradientStop { position: 1; color: "#B3000000" } } }
  Rectangle { anchors.fill: parent; gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: "#80000000" } GradientStop { position: 0.25; color: "#00000000" }
                                                         GradientStop { position: 0.75; color: "#00000000" } GradientStop { position: 1; color: "#80000000" } } }

  // ---------- the two states ----------
  LockScreen {
    id: lock; app: root; anchors.fill: parent
    opacity: root.dashOpen ? 0 : 1; scale: root.dashOpen ? 1.02 : 1; enabled: !root.dashOpen
    Behavior on opacity { NumberAnimation { duration: uiObj.dMed; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: uiObj.dMed; easing.type: Easing.OutCubic } }
  }
  Dashboard { id: dash; app: root; anchors.fill: parent; enabled: root.dashOpen }

  // ---------- chrome: customize + power ----------
  Rectangle {
    id: custBtn
    anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: 18 * root.s
    width: 150 * root.s; height: 38 * root.s; radius: height / 2; visible: !root.customizing
    color: Qt.rgba(0.1, 0.07, 0.05, 0.6); border.width: 1; border.color: uiObj.border
    Row { anchors.centerIn: parent; spacing: 8 * root.s
      Icon { width: 18 * root.s; height: width; kind: "sliders"; color: uiObj.gold }
      Text { text: "Customize"; color: uiObj.ivory; font.family: uiObj.font; font.weight: Font.Bold; font.pixelSize: 14 * root.s } }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.dashOpen) root.dashOpen = false; root.customizing = true } }
  }
  CustomizePanel { app: root; y: 40 * root.s }
  PowerControls { app: root; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 44 * root.s }
}

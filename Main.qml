import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtCore
import Qt.labs.folderlistmodel
import "components"

Item {
  id: root
  width: 1920; height: 1080
  focus: true

  // ---------- config helpers (theme.conf) ----------
  function cfgStr(k, d) { var v = config[k]; return (v === undefined || v === null || v === "") ? d : String(v) }
  function cfgBool(k, d) { var v = config[k]; if (v === undefined || v === null || v === "") return d; return String(v).toLowerCase() === "true" }
  function toUrl(p) { if (!p) return ""; if (p.indexOf("file://") === 0) return p; if (p.indexOf("/") === 0) return "file://" + p; return Qt.resolvedUrl(p) }

  readonly property real s: Math.max(0.45, Math.min(width / 1920, height / 1080)) * st.uiScale
  property alias ui: uiObj
  property alias st: stObj
  property alias sys: sysObj
  property alias logModel: logM
  property alias wallModel: wallM
  property date now: new Date()
  property bool dashOpen: false
  property bool editing: false
  property int tab: 0
  property int zTop: 10
  property string authState: "idle"      // idle | busy | failed
  property string fpMode: "idle"         // idle | waiting | accepted | rejected | unavailable
  property bool fpPending: false
  property string statusText: "Locked — authenticate to continue."
  property int sessionIndex: sessionModel.lastIndex
  property string sessionName: ""
  property string curUser: userModel.lastUser
  property int failCount: 0
  property int cooldown: 0
  readonly property string sceneName: dashOpen ? "dash" : "lock"
  readonly property bool use24h: st.hour12 ? false : cfgBool("clock_24h", true)
  readonly property bool fpEnabled: cfgBool("fingerprint_enabled", true)
  readonly property string welcomeText: st.welcome.length ? st.welcome : cfgStr("welcome_text", "Hi Dev-Scyrolynx")
  readonly property string brandText: cfgStr("brand_text", "SCYROLYNX")
  readonly property url avatarUrl: toUrl(cfgStr("avatar", ""))
  readonly property bool caps: (typeof keyboard !== "undefined" && keyboard) ? keyboard.capsLock : false
  readonly property string kbName: kbLabel()
  function kbLabel() {
    try { if (typeof keyboard !== "undefined" && keyboard && keyboard.layouts && keyboard.layouts.length > 0) return String(keyboard.layouts[keyboard.currentLayout].shortName).toUpperCase() } catch (e) {}
    return "—"
  }

  readonly property var palettes: [
    { name: "Arc Gold", gold: "#D6B36A", alt: "#F3EBDD", base: "#241A13" },
    { name: "Citrine",  gold: "#FFD21F", alt: "#FFFFFF", base: "#1A1609" },
    { name: "Cobalt",   gold: "#4CC9F0", alt: "#E6F7FF", base: "#0E1620" },
    { name: "Phosphor", gold: "#3DFF9A", alt: "#E8FFF2", base: "#0B1510" },
    { name: "Violet",   gold: "#B48CFF", alt: "#F1EAFF", base: "#15101F" },
    { name: "Crimson",  gold: "#FF5D6C", alt: "#FFECEE", base: "#1C1012" },
    { name: "Bronze",   gold: "#C98B55", alt: "#F3EBDD", base: "#201710" },
    { name: "Ivory",    gold: "#F3EBDD", alt: "#D6B36A", base: "#1B1815" }
  ]

  // ---------- movable blocks: default geometry (centre fractions, logical px at 1920x1080) ----------
  readonly property var widgetDefs: [
    { id: "greet",  title: "Greeting",    scene: "lock", cx: 0.5,   cy: 0.17,  w: 520, h: 120, minW: 200, minH: 80 },
    { id: "clock",  title: "Clock",       scene: "lock", cx: 0.5,   cy: 0.42,  w: 300, h: 350, minW: 120, minH: 60 },
    { id: "fp",     title: "Fingerprint", scene: "lock", cx: 0.5,   cy: 0.82,  w: 230, h: 250, minW: 110, minH: 110 },
    { id: "ident",  title: "Identity",    scene: "lock", cx: 0.111, cy: 0.135, w: 340, h: 204, minW: 220, minH: 100 },
    { id: "secs",   title: "Security",    scene: "lock", cx: 0.889, cy: 0.13,  w: 340, h: 176, minW: 220, minH: 100 },
    { id: "sys",    title: "System",      scene: "lock", cx: 0.111, cy: 0.83,  w: 340, h: 272, minW: 220, minH: 140 },
    { id: "notes",  title: "Scratchpad",  scene: "lock", cx: 0.889, cy: 0.48,  w: 300, h: 200, minW: 160, minH: 90, hidden: true },
    { id: "dclock", title: "Clock",       scene: "dash", cx: 0.5,   cy: 0.095, w: 360, h: 90,  minW: 140, minH: 40 },
    { id: "auth",   title: "Login",       scene: "dash", cx: 0.5,   cy: 0.50,  w: 430, h: 350, minW: 340, minH: 310 },
    { id: "dfp",    title: "Fingerprint", scene: "dash", cx: 0.695, cy: 0.50,  w: 250, h: 290, minW: 110, minH: 110 },
    { id: "dsys",   title: "System",      scene: "dash", cx: 0.285, cy: 0.36,  w: 330, h: 272, minW: 220, minH: 140 },
    { id: "dlog",   title: "Event log",   scene: "dash", cx: 0.285, cy: 0.70,  w: 330, h: 200, minW: 200, minH: 100 },
    { id: "dnotes", title: "Scratchpad",  scene: "dash", cx: 0.695, cy: 0.79,  w: 250, h: 170, minW: 160, minH: 90, hidden: true },
    { id: "power",  title: "Power",       scene: "both", cx: 0.887, cy: 0.935, w: 330, h: 78,  minW: 200, minH: 52 }
  ]
  readonly property var defs: buildDefs()
  function buildDefs() { var o = {}; for (var i = 0; i < widgetDefs.length; i++) o[widgetDefs[i].id] = widgetDefs[i]; return o }

  // ---------- persisted customization (written by the greeter itself) ----------
  Settings {
    id: stObj
    location: "file://" + root.cfgStr("settings_path", "/var/lib/sddm/.config/scyrolynx-serpantinum.conf")
    property string layoutJson: "{}"
    property string wallpaperDir: ""
    property string wallpaperFile: ""
    property int slideshow: 0
    property real blur: 0.8
    property real darkness: 0.55
    property real cardAlpha: 0.78
    property int palette: 0
    property real uiScale: 1.0
    property bool snap: true
    property int clockStyle: 0
    property bool showSeconds: true
    property bool hour12: false
    property int fpStyle: 0
    property string welcome: ""
    property string notes: ""
  }
  property var layout: ({})
  function loadLayout() { try { layout = JSON.parse(st.layoutJson || "{}") } catch (e) { layout = {} } }
  function setGeo(id, g) { var l = {}; for (var k in layout) l[k] = layout[k]; l[id] = g; layout = l; st.layoutJson = JSON.stringify(l) }
  function isOff(id) { var g = layout[id]; return (g && g.hidden !== undefined) ? g.hidden : (defs[id].hidden === true) }
  function setHidden(id, hid) {
    var g = layout[id] || {}, d = defs[id]
    setGeo(id, { cx: g.cx !== undefined ? g.cx : d.cx, cy: g.cy !== undefined ? g.cy : d.cy, w: g.w !== undefined ? g.w : d.w, h: g.h !== undefined ? g.h : d.h, hidden: hid })
  }
  function resetScene(scene) {
    var l = {}; for (var k in layout) { if (defs[k] && defs[k].scene !== scene && !(scene !== "both" && defs[k].scene === "both" && false)) l[k] = layout[k] }
    layout = l; st.layoutJson = JSON.stringify(l); log("INFO", "layout reset: " + scene)
  }
  function resetAll() { layout = {}; st.layoutJson = "{}"; log("INFO", "layout reset: all") }
  function resetStyle() { st.palette = 0; st.cardAlpha = 0.78; st.clockStyle = 0; st.showSeconds = true; st.hour12 = false; st.fpStyle = 0; st.welcome = ""; st.uiScale = 1.0 }
  Component.onCompleted: { loadLayout(); log("INFO", "greeter started · " + sddm.hostName) }

  // ---------- design tokens ----------
  QtObject {
    id: uiObj
    readonly property string font: root.cfgStr("font_family", "JetBrains Mono")
    readonly property string fontUi: root.cfgStr("font_ui", "Inter")
    readonly property var pal: root.palettes[Math.max(0, Math.min(root.palettes.length - 1, stObj.palette))]
    readonly property color accent: pal.gold
    readonly property color base: pal.base
    readonly property color digitA: pal.alt
    readonly property color digitB: pal.gold
    readonly property color text: pal.alt
    readonly property color dim: Qt.rgba(text.r, text.g, text.b, 0.55)
    readonly property color ink: "#0A0C0F"
    readonly property color card: Qt.rgba(base.r, base.g, base.b, stObj.cardAlpha)
    readonly property color field: Qt.rgba(1, 1, 1, 0.05)
    readonly property color border: Qt.rgba(accent.r, accent.g, accent.b, 0.26)
    readonly property color ok: "#4ADE80"
    readonly property color bad: "#FF5D5D"
    readonly property color warn: "#FFB020"
    readonly property real r1: 10 * root.s
    readonly property real r2: 6 * root.s
    readonly property real r3: 4 * root.s
    readonly property int dFast: 140
    readonly property int dMed: 340
  }

  SysInfo { id: sysObj; running: root.cfgBool("telemetry", true) }
  ListModel { id: logM }
  function log(level, msg) {
    logM.insert(0, { time: Qt.formatTime(new Date(), "HH:mm:ss"), level: level, msg: msg })
    while (logM.count > 60) logM.remove(logM.count - 1)
  }

  Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }
  Timer { id: fpReset; interval: 3500; onTriggered: { root.fpMode = "idle"; if (root.authState === "failed") root.authState = "idle" } }
  Timer { id: cdTimer; interval: 1000; repeat: true; running: root.cooldown > 0
    onTriggered: { root.cooldown--; if (root.cooldown === 0) { root.authState = "idle"; root.statusText = "Ready." } } }

  // ---------- navigation ----------
  function openDash(initial) { dashOpen = true; Qt.callLater(function () { authCard.focusPassword(initial || "") }) }
  function back() {
    if (editing) editing = false
    else if (dashOpen) { dashOpen = false; root.forceActiveFocus() }
  }
  Shortcut { sequence: "Escape"; onActivated: root.back() }
  Keys.onPressed: (e) => {
    if (dashOpen || editing || e.key === Qt.Key_Escape) return
    if (e.text.length > 0 && e.text.charCodeAt(0) >= 32) { openDash(e.text); e.accepted = true }
    else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space) { openDash(""); e.accepted = true }
  }

  // ---------- authentication (all real SDDM calls) ----------
  function tryPassword(user, pw) {
    if (authState === "busy" || cooldown > 0 || user.length === 0) return
    fpPending = false; authState = "busy"; statusText = "Verifying credentials…"
    log("INFO", "auth attempt · " + user + " · password")
    sddm.login(user, pw, sessionIndex)
  }
  // Fingerprint: same PAM conversation with an empty password; works only with pam_fprintd (docs/AUTHENTICATION.md).
  function tryFingerprint(user) {
    if (!fpEnabled) { fpMode = "unavailable"; statusText = "Fingerprint disabled in theme.conf."; fpReset.restart(); return }
    if (authState === "busy" || cooldown > 0 || user.length === 0) return
    fpPending = true; authState = "busy"; fpMode = "waiting"; statusText = "Place your finger on the sensor…"
    log("INFO", "auth attempt · " + user + " · fingerprint")
    sddm.login(user, "", sessionIndex)
  }
  Connections {
    target: sddm
    function onLoginSucceeded() { root.authState = "idle"; root.statusText = "Authenticated — starting session…"; root.log("OK", "login accepted"); if (root.fpPending) root.fpMode = "accepted" }
    function onLoginFailed() {
      root.authState = "failed"; root.failCount++
      if (root.fpPending) { root.fpMode = "rejected"; root.statusText = "Fingerprint not accepted. Use your password."; root.log("FAIL", "fingerprint rejected") }
      else { root.statusText = "Incorrect password."; root.log("FAIL", "bad password (#" + root.failCount + ")") }
      if (root.failCount >= 3) { root.cooldown = Math.min(30, 1 << Math.min(5, root.failCount - 2)); root.log("WARN", "UI cooldown " + root.cooldown + "s") }
      root.fpPending = false; fpReset.restart(); authCard.shake()
    }
  }

  // ---------- wallpapers ----------
  readonly property string wallDir: st.wallpaperDir.length ? st.wallpaperDir : cfgStr("wallpaper_dir", "")
  readonly property url wallDirUrl: wallDir.length ? toUrl(wallDir) : Qt.resolvedUrl("assets/images")
  readonly property url wallUrl: st.wallpaperFile.length ? st.wallpaperFile : toUrl(cfgStr("wallpaper", "assets/images/wallpaper.jpg"))
  FolderListModel { id: wallM; folder: root.wallDirUrl; showDirs: false; sortField: FolderListModel.Name
    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.bmp", "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"] }
  function setWallDir(p) {
    p = String(p).trim(); if (p.indexOf("file://") === 0) p = p.substring(7)
    while (p.length > 1 && p.charAt(p.length - 1) === "/") p = p.substring(0, p.length - 1)
    if (p.charAt(0) === "~") log("WARN", "~ is not expanded — use an absolute path")
    st.wallpaperDir = p; log("INFO", "wallpaper folder → " + (p.length ? p : "theme default"))
  }
  function pickWallpaper(u) { st.wallpaperFile = String(u); log("INFO", "wallpaper → " + String(u).split("/").pop()) }
  function curWallIndex() { for (var i = 0; i < wallM.count; i++) if (String(wallM.get(i, "fileUrl")) === String(wallUrl)) return i; return -1 }
  function nextWallpaper() { if (wallM.count < 1) return; var i = (curWallIndex() + 1) % wallM.count; st.wallpaperFile = String(wallM.get(i, "fileUrl")) }
  function shuffleWallpaper() { if (wallM.count < 1) return; var i = Math.floor(Math.random() * wallM.count); pickWallpaper(wallM.get(i, "fileUrl")) }
  Timer { interval: [0, 60000, 300000, 900000][Math.max(0, Math.min(3, st.slideshow))]; repeat: true
    running: st.slideshow > 0 && wallM.count > 1; onTriggered: root.nextWallpaper() }

  // ---------- background ----------
  Rectangle { anchors.fill: parent; color: "#07090C" }
  Item {
    id: wpLayer; anchors.fill: parent; layer.enabled: !root.cfgBool("disable_blur", false)
    Image { id: wpA; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize: Qt.size(root.width, root.height) }
    Image { id: wpB; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize: Qt.size(root.width, root.height); opacity: 0
      source: root.wallUrl
      onStatusChanged: {
        if (status === Image.Ready) { if (wpA.source == source) opacity = 0; else fade.restart() }
        else if (status === Image.Error && root.st.wallpaperFile.length) { root.log("WARN", "wallpaper unreadable → default"); root.st.wallpaperFile = "" }
      } }
    SequentialAnimation { id: fade
      NumberAnimation { target: wpB; property: "opacity"; to: 1; duration: 650; easing.type: Easing.InOutQuad }
      ScriptAction { script: { wpA.source = wpB.source; wpB.opacity = 0 } } }
  }
  MultiEffect { anchors.fill: parent; source: wpLayer; visible: !root.cfgBool("disable_blur", false) && wpA.status !== Image.Null
                blurEnabled: true; blurMax: 64; blur: stObj.blur; autoPaddingEnabled: false }
  Rectangle { anchors.fill: parent; color: "black"; opacity: stObj.darkness }
  Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0; color: "#99000000" } GradientStop { position: 0.3; color: "#00000000" }
                                                         GradientStop { position: 0.7; color: "#00000000" } GradientStop { position: 1; color: "#B3000000" } } }
  // faint technical grid
  Canvas { anchors.fill: parent; opacity: 0.5
    onPaint: { var c = getContext("2d"); c.clearRect(0, 0, width, height); c.strokeStyle = "rgba(255,255,255,0.035)"; c.lineWidth = 1
      var g = 48 * root.s; c.beginPath(); for (var x = 0; x < width; x += g) { c.moveTo(x + 0.5, 0); c.lineTo(x + 0.5, height) } for (var y = 0; y < height; y += g) { c.moveTo(0, y + 0.5); c.lineTo(width, y + 0.5) } c.stroke() }
    onWidthChanged: requestPaint(); onHeightChanged: requestPaint() }

  // ---------- scene 1: lock ----------
  Item {
    id: lockScene; anchors.fill: parent
    opacity: root.dashOpen ? 0 : 1; scale: root.dashOpen ? 1.02 : 1; visible: opacity > 0.01; enabled: !root.dashOpen
    Behavior on opacity { NumberAnimation { duration: uiObj.dMed; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: uiObj.dMed; easing.type: Easing.OutCubic } }
    MouseArea { anchors.fill: parent; enabled: !root.editing; onClicked: root.openDash("") }

    Widget { app: root; wid: "greet"; GreetCard { app: root; anchors.fill: parent } }
    Widget { app: root; wid: "clock"; Clock { app: root; anchors.fill: parent }
             MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openDash("") } }
    Widget { app: root; wid: "fp"; FingerprintScanner { app: root; anchors.fill: parent; mode: root.fpMode; onClicked: root.openDash("") } }
    Widget { app: root; wid: "ident"; IdentityCard { app: root; anchors.fill: parent } }
    Widget { app: root; wid: "secs"; SecurityCard { app: root; anchors.fill: parent } }
    Widget { app: root; wid: "sys"; SysCard { app: root; anchors.fill: parent } }
    Widget { app: root; wid: "notes"; NotesCard { app: root; anchors.fill: parent } }
  }

  // ---------- scene 2: login dashboard ----------
  Item {
    id: dashScene; anchors.fill: parent
    opacity: root.dashOpen ? 1 : 0; scale: root.dashOpen ? 1 : 0.97; visible: opacity > 0.01; enabled: root.dashOpen
    Behavior on opacity { NumberAnimation { duration: uiObj.dMed; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: uiObj.dMed; easing.type: Easing.OutCubic } }

    Widget { app: root; wid: "dclock"; Clock { app: root; mini: true; anchors.fill: parent } }
    Widget { app: root; wid: "auth"; AuthCard { id: authCard; app: root; anchors.fill: parent } }
    Widget { app: root; wid: "dfp"; FingerprintScanner { app: root; anchors.fill: parent; mode: root.fpMode; onClicked: root.tryFingerprint(root.curUser) } }
    Widget { app: root; wid: "dsys"; SysCard { app: root; anchors.fill: parent } }
    Widget { app: root; wid: "dlog"; LogCard { app: root; anchors.fill: parent } }
    Widget { app: root; wid: "dnotes"; NotesCard { app: root; anchors.fill: parent } }
  }

  // ---------- chrome ----------
  Widget { app: root; wid: "power"; PowerCard { app: root; anchors.fill: parent } }

  Row {
    anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: 14 * root.s; spacing: 8 * root.s; z: 500
    Btn { app: root; visible: root.dashOpen && !root.editing; width: 84*root.s; icon: "chevron"; text: "BACK"; onClicked: root.back() }
    Btn { app: root; width: 132*root.s; icon: "sliders"; text: root.editing ? "EDITING…" : "CUSTOMIZE"; active: root.editing; onClicked: root.editing = !root.editing }
    Rectangle { visible: root.editing; height: 32*root.s; width: hint.implicitWidth + 20*root.s; radius: uiObj.r3; color: Qt.rgba(0, 0, 0, 0.55); border.width: 1; border.color: uiObj.accent
      Lbl { id: hint; app: root; anchors.centerIn: parent; text: "DRAG · RESIZE · ESC TO EXIT"; sz: 10; color: uiObj.accent; font.letterSpacing: 1.2 } }
  }
  CustomizePanel { app: root; z: 400 }
}

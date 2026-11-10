#!/usr/bin/env python3
"""Offscreen test harness: mocks SDDM's context (sddm, userModel, sessionModel, keyboard, config) and renders the states.
usage: QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QML_XHR_ALLOW_FILE_READ=1 python3 tools/preview.py [W H]
env: OUT=/tmp (screenshot dir), WALLS=/path/to/images (wallpaper folder to scan)"""
import sys, os
from PySide6.QtCore import QObject, Property, Signal, Slot, QUrl, QAbstractListModel, Qt, QModelIndex, QTimer, QMetaObject, Q_ARG
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickView

class Sddm(QObject):
    loginSucceeded = Signal(); loginFailed = Signal()
    def __init__(s): super().__init__(); s.calls = []
    @Property(bool, constant=True)
    def canPowerOff(s): return True
    @Property(bool, constant=True)
    def canReboot(s): return True
    @Property(bool, constant=True)
    def canSuspend(s): return True
    @Property(bool, constant=True)
    def canHibernate(s): return True
    @Property(str, constant=True)
    def hostName(s): return "scyrolynx"
    @Slot(str, str, int)
    def login(s, u, p, i): s.calls.append((u, bool(p), i)); print("sddm.login", u, "pw" if p else "empty-pw", i); s.loginFailed.emit()
    @Slot()
    def powerOff(s): print("powerOff")
    @Slot()
    def reboot(s): print("reboot")
    @Slot()
    def suspend(s): print("suspend")
    @Slot()
    def hibernate(s): print("hibernate")

class Users(QAbstractListModel):
    NAME, REAL, ICON = Qt.UserRole + 1, Qt.UserRole + 2, Qt.UserRole + 3
    def __init__(s): super().__init__(); s.rows = [("dev", "Dev", ""), ("guest", "Guest", "")]
    def rowCount(s, p=QModelIndex()): return len(s.rows)
    def data(s, i, r):
        n = s.rows[i.row()]
        return {s.NAME: n[0], s.REAL: n[1], s.ICON: n[2]}.get(r)
    def roleNames(s): return {s.NAME: b"name", s.REAL: b"realName", s.ICON: b"icon"}
    @Property(str, constant=True)
    def lastUser(s): return "dev"
    @Property(int, constant=True)
    def lastIndex(s): return 0
    @Property(int, constant=True)
    def count(s): return len(s.rows)

class Sessions(QAbstractListModel):
    NAME = Qt.UserRole + 1
    def __init__(s): super().__init__(); s.rows = ["Hyprland", "Plasma (Wayland)", "GNOME"]
    def rowCount(s, p=QModelIndex()): return len(s.rows)
    def data(s, i, r): return s.rows[i.row()] if r in (s.NAME, Qt.DisplayRole) else None
    def roleNames(s): return {s.NAME: b"name"}
    @Property(int, constant=True)
    def lastIndex(s): return 0
    @Property(int, constant=True)
    def count(s): return len(s.rows)

class Keyboard(QObject):
    @Property(bool, constant=True)
    def capsLock(s): return True
    @Property(int, constant=True)
    def currentLayout(s): return 0
    @Property("QVariantList", constant=True)
    def layouts(s): return [{"shortName": "us", "longName": "English (US)"}]

app = QGuiApplication(sys.argv)
W, H = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) > 2 else (1920, 1080)
v = QQuickView(); v.setResizeMode(QQuickView.SizeRootObjectToView); v.resize(W, H)
sddm, users, sessions, kb = Sddm(), Users(), Sessions(), Keyboard()
ctx = v.rootContext()
theme = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for k, o in (("sddm", sddm), ("userModel", users), ("sessionModel", sessions), ("keyboard", kb)): ctx.setContextProperty(k, o)
cfg = {"disable_blur": "true", "settings_path": "/tmp/scy-test.conf", "clock_24h": "true", "font_family": "DejaVu Sans Mono"}
if os.environ.get("WALLS"): cfg["wallpaper_dir"] = os.environ["WALLS"]
ctx.setContextProperty("config", cfg)
errs = []
v.engine().warnings.connect(lambda w: errs.extend(x.toString() for x in w))
v.setSource(QUrl.fromLocalFile(theme + "/Main.qml"))
v.show()
out = os.environ.get("OUT", "/tmp")
def wait(ms):
    t = QTimer(); t.setSingleShot(True); t.start(ms)
    while t.isActive(): app.processEvents()
if v.status() != QQuickView.Ready:
    print("LOAD FAILED"); [print(e) for e in v.errors()]; sys.exit(1)
root = v.rootObject()
def shot(n): wait(1200); v.grabWindow().save(f"{out}/{n}_{W}x{H}.png")
shot("lock")
root.setProperty("editing", True); shot("lock_edit")
root.setProperty("tab", 1); shot("edit_wall")
root.setProperty("tab", 2); shot("edit_style")
root.setProperty("tab", 0); root.setProperty("editing", False)
root.setProperty("dashOpen", True); shot("dash")
root.setProperty("editing", True); shot("dash_edit"); root.setProperty("editing", False)
QMetaObject.invokeMethod(root, "tryFingerprint", Q_ARG("QVariant", "dev")); wait(300)
QMetaObject.invokeMethod(root, "tryPassword", Q_ARG("QVariant", "dev"), Q_ARG("QVariant", "x")); wait(300)
shot("dash_failed")
print("auth state after failed login:", root.property("authState"), "failCount:", root.property("failCount"))
print("WARNINGS:", len(errs)); [print(" ", e) for e in errs]

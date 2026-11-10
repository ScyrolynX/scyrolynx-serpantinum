#!/usr/bin/env python3
"""Offscreen test harness: mocks SDDM's context (sddm, userModel, sessionModel, config) and renders both states.
usage: QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software python3 tools/preview.py [W H]"""
import sys, os
from PySide6.QtCore import QObject, Property, Signal, Slot, QUrl, QAbstractListModel, Qt, QModelIndex, QTimer
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickView

class Sddm(QObject):
    loginSucceeded = Signal(); loginFailed = Signal()
    def __init__(s): super().__init__(); s.calls = []
    @Property(bool, constant=True)
    def canPowerOff(s): return True
    @Property(bool, constant=True)
    def canReboot(s): return True
    @Property(str, constant=True)
    def hostName(s): return "scyrolynx"
    @Slot(str, str, int)
    def login(s, u, p, i): s.calls.append((u, bool(p), i)); print("sddm.login", u, "pw" if p else "empty-pw", i); s.loginFailed.emit()
    @Slot()
    def powerOff(s): print("powerOff")
    @Slot()
    def reboot(s): print("reboot")

class Users(QObject):
    @Property(str, constant=True)
    def lastUser(s): return "codex"
    @Property(int, constant=True)
    def lastIndex(s): return 0

class Sessions(QAbstractListModel):
    NAME = Qt.UserRole + 1
    def __init__(s): super().__init__(); s.rows = ["Hyprland", "Plasma (Wayland)", "GNOME"]
    def rowCount(s, p=QModelIndex()): return len(s.rows)
    def data(s, i, r):
        return s.rows[i.row()] if r in (s.NAME, Qt.DisplayRole) else None
    def roleNames(s): return {s.NAME: b"name"}
    @Property(int, constant=True)
    def lastIndex(s): return 0
    @Property(int, constant=True)
    def count(s): return len(s.rows)

app = QGuiApplication(sys.argv)
W, H = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) > 2 else (1920, 1080)
v = QQuickView(); v.setResizeMode(QQuickView.SizeRootObjectToView); v.resize(W, H)
sddm, users, sessions = Sddm(), Users(), Sessions()
ctx = v.rootContext()
theme = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ctx.setContextProperty("sddm", sddm); ctx.setContextProperty("userModel", users); ctx.setContextProperty("sessionModel", sessions)
ctx.setContextProperty("config", {"disable_blur": "true", "settings_path": "/tmp/scy-test.conf", "clock_24h": "true"})
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
wait(1200); v.grabWindow().save(f"{out}/lock_{W}x{H}.png")
root.setProperty("dashOpen", True); wait(1200); v.grabWindow().save(f"{out}/dash_{W}x{H}.png")
root.setProperty("dashOpen", False); root.setProperty("customizing", True); wait(1000); v.grabWindow().save(f"{out}/custom_{W}x{H}.png")
root.setProperty("customizing", False); root.setProperty("dashOpen", True); wait(600)
root.metaObject()
from PySide6.QtCore import QMetaObject, Q_ARG
QMetaObject.invokeMethod(root, "tryFingerprint", Q_ARG("QVariant", "codex")); wait(300)
QMetaObject.invokeMethod(root, "tryPassword", Q_ARG("QVariant", "codex"), Q_ARG("QVariant", "x")); wait(300)
print("auth state after failed login:", root.property("authState"))
print("WARNINGS:", len(errs)); [print(" ", e) for e in errs]

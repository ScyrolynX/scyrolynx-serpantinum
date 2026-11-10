import QtQuick
// Live host telemetry from /proc and /sys. QML can read local files only when the greeter runs with
// QML_XHR_ALLOW_FILE_READ=1 (see docs/AUTHENTICATION.md); otherwise every value stays "unavailable".
Item {
  id: si
  visible: false
  property bool running: true
  property bool ok: false
  property string uptime: "—"
  property real cpu: -1          // 0..1 (delta of /proc/stat)
  property real memUsed: -1      // 0..1
  property string memText: "—"
  property string load: "—"
  property int battery: -1
  property string batState: ""
  property real temp: -1
  property string kernel: "—"
  property var prev: null

  function rd(path, cb) {
    var x = new XMLHttpRequest()
    x.onreadystatechange = function () { if (x.readyState === XMLHttpRequest.DONE) cb(x.responseText ? String(x.responseText) : "") }
    try { x.open("GET", "file://" + path); x.send() } catch (e) { cb("") }
  }
  function gib(kb) { return (kb / 1048576).toFixed(1) }
  function poll() {
    rd("/proc/uptime", function (t) { var s = parseFloat(t); if (isNaN(s)) return; si.ok = true
      var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
      si.uptime = (d > 0 ? d + "d " : "") + h + "h " + m + "m" })
    rd("/proc/meminfo", function (t) { var a = /MemTotal:\s+(\d+)/.exec(t), b = /MemAvailable:\s+(\d+)/.exec(t); if (!a || !b) return
      var tot = +a[1], av = +b[1]; si.memUsed = 1 - av / tot; si.memText = gib(tot - av) + " / " + gib(tot) + " GiB" })
    rd("/proc/loadavg", function (t) { var p = t.split(" "); if (p.length >= 3) si.load = p[0] + " " + p[1] + " " + p[2] })
    rd("/proc/stat", function (t) { var m = /^cpu\s+(.*)/m.exec(t); if (!m) return
      var v = m[1].trim().split(/\s+/).map(Number), idle = v[3] + (v[4] || 0), tot = v.reduce(function (a, b) { return a + b }, 0)
      if (si.prev) { var dt = tot - si.prev.t, di = idle - si.prev.i; if (dt > 0) si.cpu = Math.max(0, Math.min(1, 1 - di / dt)) }
      si.prev = { t: tot, i: idle } })
    rd("/proc/sys/kernel/osrelease", function (t) { if (t.length) si.kernel = t.trim() })
    rd("/sys/class/thermal/thermal_zone0/temp", function (t) { var v = parseInt(t); if (!isNaN(v)) si.temp = v / 1000 })
    rd("/sys/class/power_supply/BAT0/capacity", function (t) { var v = parseInt(t); if (!isNaN(v)) si.battery = v })
    rd("/sys/class/power_supply/BAT0/status", function (t) { if (t.length) si.batState = t.trim() })
  }
  Timer { interval: 2000; running: si.running; repeat: true; triggeredOnStart: true; onTriggered: si.poll() }
}

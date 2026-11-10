# scyrolynx-serpantinum - SDDM theme (Qt6 / SDDM 0.21)
Two states: lock screen (checkerboard clock, corner cards, fingerprint) -> click/any key -> 3-column login dashboard. Esc / X goes back.
**Customize from the greeter itself**: top "Customize" button -> drag clock and fingerprint, blur, darkness, card opacity, clock size/layout, colour preset (incl. "Citrine" = your screenshot yellow), fingerprint style. Saved to /var/lib/sddm/.config/scyrolynx-serpantinum.conf.
Static options (wallpaper, avatar, 12/24h, power, texts): theme.conf. See docs/.
## Test status
Verified: QML loads with 0 warnings and renders at 1920x1080, 1600x900, 1366x768 (PySide6 6.12 offscreen/software, mocked SDDM; tools/preview.py); mock login calls reach sddm.login with the right session index.
NOT verified: real SDDM greeter, real PAM/fprintd, MultiEffect blur (software renderer can't draw it), persistence write as user `sddm`, multi-monitor, power actions, installed SDDM Qt version (check: `pacman -Q sddm qt6-base`).

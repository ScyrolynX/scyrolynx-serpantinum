# Authentication / fingerprint

**Password**: `sddm.login(user, password, sessionIndex)` - the normal SDDM path. Nothing is stored or logged.

**Fingerprint**: SDDM 0.21 exposes no API for the theme to talk to PAM or fprintd directly, and
a theme cannot start a second PAM process. So the Fingerprint button calls the *same*
`sddm.login(user, "", sessionIndex)` with an empty password. If `pam_fprintd.so` is first in the PAM
auth stack, PAM waits for your finger; the result comes back through `loginSucceeded`/`loginFailed`.
The scanner shows "accepted" only on `loginSucceeded`.

Limits (honest list):
- QML cannot tell "sensor missing" from "finger rejected" - both arrive as loginFailed. The "waiting" state is shown from the click until SDDM answers; there is no separate "in progress" signal.
- If pam_fprintd is not configured, the button just fails and the password still works.
- Fingerprint login is generally not combined with auto-unlocking KWallet/gnome-keyring (no password available).

## Enable (manual, with backup)
```
fprintd-list $USER || fprintd-enroll
sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
sudoedit /etc/pam.d/sddm
```
Add as the FIRST auth line (keep everything else):
```
auth       sufficient   pam_fprintd.so
```
Disable the button instead: `fingerprint_enabled=false` in theme.conf.

# Install (does NOT activate the theme)
```
sudo cp -r scyrolynx-serpantinum /usr/share/sddm/themes/
sudo chmod -R a+rX /usr/share/sddm/themes/scyrolynx-serpantinum
sudo mkdir -p /var/lib/sddm/.config && sudo chown sddm:sddm /var/lib/sddm/.config
```
Wallpapers: Customize -> Wallpaper -> type a folder path (absolute, readable by user `sddm`, e.g. /usr/share/backgrounds), or set `wallpaper_dir` in theme.conf. If a folder is under your $HOME: `sudo setfacl -m u:sddm:rx ~ ~/Pictures ~/Pictures/walls`.
Avatar: `avatar=` in theme.conf, or the account icon SDDM provides.
Recommended fonts: JetBrains Mono, Inter (`pacman -S ttf-jetbrains-mono inter-font`).

## Test (windowed, from your Hyprland session)
```
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/scyrolynx-serpantinum
```
In test mode sddm.login is simulated and the settings file may not be writable; for testing set
`settings_path=/tmp/scy.conf` in theme.conf.

## Logs
```
journalctl -b -u sddm --no-pager | tail -80
```
## Activate
First record what you use now:
```
grep -rH "Current" /etc/sddm.conf /etc/sddm.conf.d /usr/lib/sddm/sddm.conf.d 2>/dev/null
```
Then:
```
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=scyrolynx-serpantinum\n' | sudo tee /etc/sddm.conf.d/99-scyrolynx.conf
```
Keep a TTY (Ctrl+Alt+F3) logged in while you try it. Log out to see it.

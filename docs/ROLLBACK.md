# Rollback
```
sudo rm /etc/sddm.conf.d/99-scyrolynx.conf        # back to your previous theme
sudo rm -rf /usr/share/sddm/themes/scyrolynx-serpantinum   # optional: remove theme
sudo rm -f /var/lib/sddm/.config/scyrolynx-serpantinum.conf # optional: drop saved customization
```
If you edited PAM: `sudo cp /etc/pam.d/sddm.bak /etc/pam.d/sddm`.
If the greeter is broken, from a TTY run the same commands, then `sudo systemctl restart sddm`.

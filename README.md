# Radarr 4K Installer
### For Swizzin installs
Second Radarr Installation on Swizzin based systems

Uses existing install as a base. you must ``sudo box install radarr`` prior to running this script. 

Run install.sh as sudo
```bash
sudo su -
wget "https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4kinstall.sh"
chmod +x ~/radarr4kinstall.sh
~/radarr4kinstall.sh
```
Sometimes Radarr1 won't start due to another Radarr existing, use the panel to stop Radarr and Radarr4k, enable Radarr and wait a second before starting Radarr4k or

```bash
sudo systemctl stop radarr && sudo systemctl stop radarr4k
sudo systemctl start radarr
sudo systemctl start radarr4k
```

The log file should be located at ``/root/log/swizzin.log``.

# Uninstaller: 

```bash
sudo su -
wget "https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4kuninstall.sh"
chmod +x ~/radarr4kuninstall.sh
~/radarr4kuninstall.sh
```

# radarr4k
Second Radarr Installation on Swizzin debian based systems

Should work on ubuntu as well

Installs mono and Radarr, changes ports and url base to not conflict with base Radarr, adds nginx and swizzin inputs to be added to panel.

Run install.sh as sudo

wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/install.sh

chmod +x install.sh

sudo /path/to/file/install.sh

Sometimes Radarr1 won't start due to another Radarr existing, use the panel to stop Radarr and Radarr4k, enable Radarr and wait a second before starting Radarr4k or

sudo systemctl stop radarr.service && sudo systemctl stop radarr4k.service

sudo systemctl start radarr.service

sudo systemctl start radarr4k.service

log file should be located at /home/YOURNAME/install.log

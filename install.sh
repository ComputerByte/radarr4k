#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/mono
. /etc/swizzin/sources/functions/utils
varname=$(_get_master_username)
apt_install apt-transport-https dirmngr gnupg ca-certificates curl mediainfo
echo Updating mono
mono_repo_update > /home/$varname/install.log
echo Making directories
mkdir /home/$varname/scripts
cd /home/$varname/scripts
echo Downloading Radarr
wget https://github.com/Radarr/Radarr/releases/download/v3.0.2.4552/Radarr.master.3.0.2.4552.linux-core-x64.tar.gz   > /home/$varname/install.log
tar -xf Radarr*   > /home/$varname/install.log
chown -R $varname:$varname /home/$varname/scripts/Radarr   > /home/$varname/install.log
systemctl stop radarr.service
echo Downloading service files
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.service  > /home/$varname/install.log
sed -i "s/swizz/$varname/g" /home/$varname/scripts/radarr4k.service  > /home/$varname/install.log
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.conf  > /home/$varname/install.log
sed -i "s/swizz/$varname/g" /home/$varname/scripts/radarr4k.conf  > /home/$varname/install.log
mv radarr4k.service /etc/systemd/system  > /home/$varname/install.log
echo Starting Radarr4k for config creation
systemctl enable radarr4k.service  > /home/$varname/install.log
systemctl start radarr4k.service  > /home/$varname/install.log
echo Sleep For 10 seconds
sleep 10
echo Stop radarr4k
systemctl stop radarr4k.service  > /home/$varname/install.log
systemctl stop radarr.service  > /home/$varname/install.log
echo Modifying radarr4k configs to not conflict with radarr
sed -i "s/7878/9000/g" /home/$varname/config/Radarr4k/config.xml  > /home/$varname/install.log
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr4k<\/UrlBase>/g" /home/$varname/config/Radarr4k/config.xml  > /home/$varname/install.log
echo Installing nginx profiles
mv /home/$varname/scripts/radarr4k.conf /etc/nginx/apps
nginx -t && nginx -s reload  > /home/$varname/install.log
echo Starting radarr
systemctl start radarr.service  > /home/$varname/install.log
echo Sleep 10
sleep 10
echo Starting radarr4k
systemctl start radarr4k.service  > /home/$varname/install.log
echo Installing swizzin profile for panel
cd /opt/swizzin/core/custom/
cat << EOF >> /opt/swizzin/core/custom/profiles.py
class radarr4k_meta:
    name = "radarr4k"
    pretty_name = "Radarr4k"
    baseurl = "/radarr4k"
    systemd = "radarr4k"
    check_theD = True
    img = "radarr"
class radarr_meta(radarr_meta):
    check_theD = True
EOF
touch /install/.radarr4k.lock   > /home/$varname/install.log
systemctl restart panel   > /home/$varname/install.log

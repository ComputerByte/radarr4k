#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/mono
. /etc/swizzin/sources/functions/utils
export log=/root/logs/swizzin.log
touch $log
varname=$(_get_master_username)
#Updating Mono
echo Updating mono
apt_install apt-transport-https dirmngr gnupg ca-certificates curl mediainfo
mono_repo_update >> $log 2>&1
#Downloading and Unpacking Radarr
cd /tmp
echo Downloading Radarr
wget https://github.com/Radarr/Radarr/releases/download/v3.0.2.4552/Radarr.master.3.0.2.4552.linux-core-x64.tar.gz >> $log 2>&1
tar -xf Radarr* >> $log 2>&1
chown -R $varname:$varname /tmp/Radarr >> $log 2>&1
mv /tmp/Radarr /opt/Radarr4k
#Downloading Extra Files
echo Downloading service files
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.service  >> $log 2>&1
sed -i "s/swizz/$varname/g" /tmp/radarr4k.service  >> $log 2>&1
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.conf  >> $log 2>&1
sed -i "s/swizz/$varname/g" /tmp/radarr4k.conf  >> $log 2>&1
#Stop Radarr1 and Run Radar4k for Config creation
echo Stopping Radarr
systemctl stop radarr.service
mv radarr4k.service /etc/systemd/system  >> $log 2>&1
echo Starting Radarr4k for config creation
systemctl enable radarr4k.service  >> $log 2>&1
systemctl start radarr4k.service  >> $log 2>&1
echo Sleep For 10 seconds
sleep 10
echo Stop radarr4k
systemctl stop radarr4k.service  >> $log 2>&1
#Radarr4k Config changing
echo Modifying radarr4k configs to not conflict with radarr
sed -i "s/7878/9000/g" /home/$varname/.config/Radarr4k/config.xml  >> $log 2>&1
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr4k<\/UrlBase>/g" /home/$varname/.config/Radarr4k/config.xml  >> $log 2>&1
#Install Nginx profiles
echo Installing nginx profiles
mv /tmp/radarr4k.conf /etc/nginx/apps
nginx -t && nginx -s reload  >> $log 2>&1
echo Starting radarr
systemctl start radarr.service  >> $log 2>&1
echo Sleep 10
sleep 10
echo Starting radarr4k
systemctl start radarr4k.service  >> $log 2>&1
#Install Swizzin Panel Profiles
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
touch /install/.radarr4k.lock   >> $log 2>&1
systemctl restart panel   >> $log 2>&1

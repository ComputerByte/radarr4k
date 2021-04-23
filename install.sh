#!/bin/bash
echo Hello, input your swizzin username or this will break.
read varname
echo Installing mono
apt install apt-transport-https dirmngr gnupg ca-certificates curl mediainfo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt update
apt install mono-devel
mkdir /home/$varname/scripts
cd /home/$varname/scripts
wget https://github.com/Radarr/Radarr/releases/download/v3.0.2.4552/Radarr.master.3.0.2.4552.linux-core-x64.tar.gz
tar -xf Radarr*
chown -R $varname:$varname /home/$varname/scripts/Radarr
#Stop Radarr
systemctl stop radarr.service
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.service
sed -i "s/swizz/$varname/g" /home/$varname/scripts/radarr4k.service
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.conf
sed -i "s/swizz/$varname/g" /home/$varname/scripts/radarr4k.conf
mv radarr4k.service /etc/systemd/system
systemctl enable radarr4k.service
systemctl start radarr4k.service
echo Sleep For 10 seconds
sleep 10
systemctl stop radarr4k.service
systemctl stop radarr.service
sed -i "s/7878/9000/g" /home/$varname/config/Radarr4k/config.xml
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr4k<\/UrlBase>/g" /home/$varname/config/Radarr4k/config.xml
mv /home/$varname/scripts/radarr4k.conf /etc/nginx/apps
nginx -t && nginx -s reload
systemctl start radarr.service
echo Sleep 10
sleep 10
systemctl start radarr4k.service
cd /home/$varname/scripts
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/profiles.py
mv /opt/swizzin/core/custom/profiles.py /opt/swizzin/core/custom/profiles.py.backup
cp profiles.py /opt/swizzin/core/custom
touch /install/.radarr4k.lock
systemctl restart panel

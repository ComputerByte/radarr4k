#!/bin/bash
echo Hello, input your swizzin username or this will break.
read varname
echo Installing mono dependencies
apt install apt-transport-https dirmngr gnupg ca-certificates curl mediainfo > /dev/null 2>&1
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF > /dev/null 2>&1
echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list > /dev/null 2>&1
apt update > /dev/null 2>&1
echo installing mono
apt install mono-devel > /dev/null 2>&1
echo Making directories
mkdir /home/$varname/scripts
cd /home/$varname/scripts
echo Downloading Radarr
wget https://github.com/Radarr/Radarr/releases/download/v3.0.2.4552/Radarr.master.3.0.2.4552.linux-core-x64.tar.gz  > /dev/null 2>&1
tar -xf Radarr*  > /dev/null 2>&1
chown -R $varname:$varname /home/$varname/scripts/Radarr  > /dev/null 2>&1
systemctl stop radarr.service
echo Downloading service files
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.service > /dev/null 2>&1
sed -i "s/swizz/$varname/g" /home/$varname/scripts/radarr4k.service > /dev/null 2>&1
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/radarr4k.conf > /dev/null 2>&1
sed -i "s/swizz/$varname/g" /home/$varname/scripts/radarr4k.conf > /dev/null 2>&1
mv radarr4k.service /etc/systemd/system > /dev/null 2>&1
echo Starting Radarr4k for config creation
systemctl enable radarr4k.service > /dev/null 2>&1
systemctl start radarr4k.service > /dev/null 2>&1
echo Sleep For 10 seconds
sleep 10
echo Stop radarr4k
systemctl stop radarr4k.service > /dev/null 2>&1
systemctl stop radarr.service > /dev/null 2>&1
echo Modifying radarr4k configs to not conflict with radarr
sed -i "s/7878/9000/g" /home/$varname/config/Radarr4k/config.xml > /dev/null 2>&1
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr4k<\/UrlBase>/g" /home/$varname/config/Radarr4k/config.xml > /dev/null 2>&1
echo Installing nginx profiles
mv /home/$varname/scripts/radarr4k.conf /etc/nginx/apps
nginx -t && nginx -s reload > /dev/null 2>&1
echo Starting radarr
systemctl start radarr.service > /dev/null 2>&1
echo Sleep 10
sleep 10
echo Starting radarr4k
systemctl start radarr4k.service > /dev/null 2>&1
echo Installing swizzin profile for panel
cd /home/$varname/scripts
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/profiles.py  > /dev/null 2>&1
mv /opt/swizzin/core/custom/profiles.py /opt/swizzin/core/custom/profiles.py.backup  > /dev/null 2>&1
cp profiles.py /opt/swizzin/core/custom  > /dev/null 2>&1
touch /install/.radarr4k.lock  > /dev/null 2>&1
systemctl restart panel  > /dev/null 2>&1

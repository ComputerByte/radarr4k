#!/bin/bash
echo Hello, input your swizzin username or this will break.
read varname
echo Installing mono dependencies
apt install apt-transport-https dirmngr gnupg ca-certificates curl mediainfo  > /home/$varname/install.log
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF  > /home/$varname/install.log
echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list  > /home/$varname/install.log
apt update  > /home/$varname/install.log
echo installing mono
apt install mono-devel  > /home/$varname/install.log
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
cd /home/$varname/scripts
wget https://raw.githubusercontent.com/ComputerByte/radarr4k/main/profiles.py   > /home/$varname/install.log
mv /opt/swizzin/core/custom/profiles.py /opt/swizzin/core/custom/profiles.py.backup   > /home/$varname/install.log
cp profiles.py /opt/swizzin/core/custom   > /home/$varname/install.log
touch /install/.radarr4k.lock   > /home/$varname/install.log
systemctl restart panel   > /home/$varname/install.log

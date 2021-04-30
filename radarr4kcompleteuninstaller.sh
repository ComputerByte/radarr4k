#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/utils

# Script by @ComputerByte 
# For Radarr 4K Uninstalls

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log
# Set variables
user=$(_get_master_username)

systemctl disable --now -q radarr4k
rm /etc/systemd/system/radarr4k.service
systemctl daemon-reload -q
rm -rf /home/"$user"/.config/radarr4k

if [[ -f /install/.nginx.lock ]]; then
    rm /etc/nginx/apps/radarr4k.conf
    systemctl reload nginx
fi

rm /install/.radarr4k.lock

sed -e "s/class radarr4k_meta://g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    name = \"radarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    pretty_name = \"Radarr 4K\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    baseurl = \"\/radarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    systemd = \"radarr4k\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    check_theD = True//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/    img = \"radarr\"//g" -i /opt/swizzin/core/custom/profiles.py
sed -e "s/class radarr_meta(radarr_meta)://g" -i /opt/swizzin/core/custom/profiles.py
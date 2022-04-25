#!/bin/bash
. /etc/swizzin/sources/globals.sh
. /etc/swizzin/sources/functions/utils

# Script by @ComputerByte
# For Radarr 4K Installs
#shellcheck=SC1017

# Log to Swizzin.log
export log=/root/logs/swizzin.log
touch $log
# Set variables
user=$(_get_master_username)

echo_progress_start "Making data directory and owning it to ${user}"
mkdir -p "/home/$user/.config/radarr4k"
chown -R "$user":"$user" /home/$user/.config
echo_progress_done "Data Directory created and owned."

echo_progress_start "Installing systemd service file"
cat >/etc/systemd/system/radarr4k.service <<-SERV
[Unit]
Description=Radarr 4K
After=syslog.target network.target

[Service]
# Change the user and group variables here.
User=${user}
Group=${user}

Type=simple

# Change the path to Radarr or mono here if it is in a different location for you.
ExecStart=/opt/Radarr/Radarr -nobrowser --data=/home/${user}/.config/radarr4k
TimeoutStopSec=20
KillMode=process
Restart=on-failure

# These lines optionally isolate (sandbox) Radarr from the rest of the system.
# Make sure to add any paths it might use to the list below (space-separated).
#ReadWritePaths=/opt/Radarr /path/to/movies/folder
#ProtectSystem=strict
#PrivateDevices=true
#ProtectHome=true

[Install]
WantedBy=multi-user.target
SERV
echo_progress_done "Radarr 4K service installed"

# This checks if nginx is installed, if it is, then it will install nginx config for radarr4k
if [[ -f /install/.nginx.lock ]]; then
    echo_progress_start "Installing nginx config"
    cat >/etc/nginx/apps/radarr4k.conf <<-NGX
location /radarr4k {
  proxy_pass        http://127.0.0.1:9000/radarr4k;
  proxy_set_header Host \$host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_redirect off;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${user};

  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$http_connection;
}

location  /radarr4k/api {
  proxy_pass        http://127.0.0.1:9000/radarr4k/api;
  proxy_set_header Host \$host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host \$host;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_redirect off;
  auth_basic off;
  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$http_connection;
}
NGX
    # Reload nginx
    systemctl reload nginx
    echo_progress_done "Nginx config applied"
fi

echo_progress_start "Generating configuration"
# Start radarr to config
systemctl stop radarr.service >>$log 2>&1
cat > /home/${user}/.config/radarr4k/config.xml << EOSC
<Config>
  <LogLevel>info</LogLevel>
  <EnableSsl>False</EnableSsl>
  <Port>9000</Port>
  <SslPort>9898</SslPort>
  <UrlBase>/radarr4k</UrlBase>
  <BindAddress>127.0.0.1</BindAddress>
  <AuthenticationMethod>None</AuthenticationMethod>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>main</Branch>
</Config>
EOSC
chown -R ${user}:${user} /home/${user}/.config/radarr4k/config.xml
systemctl enable --now radarr.service >>$log 2>&1
sleep 20
systemctl enable --now radarr4k.service >>$log 2>&1

echo_progress_start "Patching panel."
systemctl start radarr4k.service >>$log 2>&1
#Install Swizzin Panel Profiles
if [[ -f /install/.panel.lock ]]; then
    cat <<EOF >>/opt/swizzin/core/custom/profiles.py
class radarr4k_meta:
    name = "radarr4k"
    pretty_name = "Radarr 4K"
    baseurl = "/radarr4k"
    systemd = "radarr4k"
    check_theD = True
    img = "radarr"
class radarr_meta(radarr_meta):
    check_theD = True
EOF
fi
touch /install/.radarr4k.lock >>$log 2>&1
echo_progress_done "Panel patched."
systemctl restart panel >>$log 2>&1
echo_progress_done "Done."

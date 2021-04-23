from core.profiles import *
class radarr4k_meta:
    name = "radarr4k"
    pretty_name = "Radarr4k"
    baseurl = "/radarr4k"
    systemd = "radarr4k"
    check_theD = True
    img = "radarr"
class radarr_meta(radarr_meta):
    check_theD = True

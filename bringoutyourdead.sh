#!/bin/bash
 # Requires Aria2, apt-get install aria2


 # BringOutYourDead.sh 

 if [ $# -ne 2 ]
 then
    echo Usage: $0 Path_of_Active_Torrents Path_of_Downloads
    exit -1
 fi

 # i.e. ~/.session (rtorrent) or ~/.config/deluge/state (deluge)
 TOR_DIR=$1
 # This doesn't handle nested download directories (i.e by tracker labels), has to be flat
 DOWNLOAD_DIR=$2

 cd $DOWNLOAD_DIR
 ls -1  >/tmp/RefList.$$

 echo "Number of Payloads in Download Directory: " $(wc -l < /tmp/RefList.$$)

 # Remove Active Payloads from List of All Payloads
 for torrent in $TOR_DIR/*.torrent
 do
    # Get Torrent File / Directory
    TARGET="$(aria2c -S $torrent |grep '^  1|'|sed 's/^  1|//' |cut -d"/" -f 2)"

    # Escape Special Characters for SED
    TARGET="$(<<< "$TARGET" sed -e 's`[][\\/.*^$]`\\&`g')"

    # Entire Line  (EDIT)
    TARGET="^$TARGET\$"

    # Remove the Active Torrent Path from the Reference List
    sed -i "/$TARGET/d" /tmp/RefList.$$

 done

 echo "Number of Unreferenced Payloads (DEAD): " $(wc -l < /tmp/RefList.$$)
 mv  /tmp/RefList.$$  ~/Results.theDEAD

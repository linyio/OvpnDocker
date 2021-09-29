#!/bin/sh

#variables
maxConfs=10 #for now up to two configurations are used (main and an optionall fallback) but in the future there might increase

. $(dirname $0)/common

#brief: helper function for extracting an id from a conf name. Useful for computing the supervisor services names
function IdFromConfName {
    local confName=$1
    [ -z "$confName" ] && return -1
    echo $confName | cut -d - -f 2,3 | cut -d . -f 1
}

#brief: initialize the supervisor directory with the config files for starting the openvpn services
function InitSuprvisorConfs {
    local supervisorConfsDir=$1
    shift
    local confs=$* #a conf has to be in the for of "server-<something>.conf"

    [ -z "$supervisorConfsDir" -o -z "$confs" ] && return -1
    rm $supervisorConfsDir/* &>/dev/null
    for conf in $confs; do
    confId=$(IdFromConfName $conf)
        echo "[program:openvpn-${confId}]
command = /usr/sbin/openvpn --cd /etc/liny/openvpn --config /etc/liny/openvpn/$conf --script-security 2 --up /usr/lib/liny/openvpn/OnUp-openvpn.sh
autostart = true
" > ${supervisorConfsDir}/openvpn-${confId}.conf
    done
}

#brief: check and creates the /dev/net/tun block char device
function CreateTunBlockChar {
  if [ ! -c /dev/net/tun ]; then
      mkdir -p /dev/net #create the /dev/net, if it doesn't exists
      mknod /dev/net/tun c 10 200
  fi
}

#main
CreateTunBlockChar #create the tun block character device, if missing

#create Openvpn log dir if inexistent
mkdir -p --mode=0755 /var/log/liny/openvpn

ovpnConfsTemplate="^server-.*\.conf$"
ovpnConfsDir="/etc/liny/openvpn"
ovpnConfsArgs="$ovpnConfsDir $ovpnConfsTemplate  $maxConfs"
noOvpnConfs=$(DirEntriesNo $ovpnConfsArgs)

[ "$noOvpnConfs" -eq "0" ] && { echo "No openvpn conf found, in the \"$ovpnConfsDir\"! They have to be in the form of \"$ovpnConfsTemplate\". Please add at least one ..."; exit 2; }

supervisorConfsDir="/etc/supervisor.d"
supervisorConfsTemplate="^openvpn-.*\.conf$"
supervisorConfsArgs="$supervisorConfsDir $supervisorConfsTemplate $maxConfs"
noSupervisorConfs=$(DirEntriesNo $supervisorConfsArgs)

if [ $noOvpnConfs -ne $noSupervisorConfs ]; then
    InitSuprvisorConfs $supervisorConfsDir $(DirEntries $ovpnConfsArgs)
else
    dirty=false
    confs=$(DirEntries $ovpnConfsArgs)
    for conf in $confs; do
        [ ! -f "$supervisorConfsDir/$conf" ] && { dirty=true; break; }
    done

    $dirty && InitSuprvisorConfs $supervisorConfsDir $confs
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf

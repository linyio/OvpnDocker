#!/bin/sh

. $(dirname $0)/../common

#add iptables rules for allowing internet access
tunIF=$1

#Note that the iptables rules are not deleted when the vpn interface goes down because the openvpn down script is ran as user (not as root)
#Options:
#   * execute with sudo, and instuct sudo to remove the rules without asking for password
#   * implement supervisord event listners and remove the rules when the service goes down or it's restarted
AllowInternatAccess $tunIF

exit 0

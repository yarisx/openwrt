#!/bin/sh
#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# common shell lib to obtain wifi mac address

. /lib/functions/system.sh
get_primary_macaddr(){
	local wifi_mac_addr=0x$(hexdump -n 6 -v -e '/1 "%02X"' /proc/device-tree/uccp@18480000/mac-address0)
	if [ $? -eq 0 ]
	then
		echo $wifi_mac_addr
	fi
}

get_lowpan_mac(){
	local PRIMARY_MAC_ADDR=$(get_primary_macaddr)
	if [ ! -z "$PRIMARY_MAC_ADDR" ]
	then
		# 6LOWPAN_MAC = PRIMARY_MAC_ADDR + 5
		local LOWPAN_OTP_OFFSET=0x5
		local LOWPAN_MAC=$(printf "%012X" $(($PRIMARY_MAC_ADDR + $LOWPAN_OTP_OFFSET)))
		LOWPAN_MAC=$(macaddr_setbit_la $(macaddr_canonicalize $LOWPAN_MAC))
		echo $LOWPAN_MAC
	fi
}

get_bluetooth_mac(){
	local PRIMARY_MAC_ADDR=$(get_primary_macaddr)
	if [ ! -z "$PRIMARY_MAC_ADDR" ]
	then
		local BT_OTP_OFFSET=0x2
		local BT_MAC=$(printf "%012x" $((PRIMARY_MAC_ADDR + BT_OTP_OFFSET)))
		BT_MAC=$(macaddr_canonicalize "$BT_MAC")
		echo $BT_MAC
	fi
}

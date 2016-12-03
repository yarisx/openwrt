#!/bin/sh
# netifd script for configuring 6lowpan interfaces
##

[ -n "$INCLUDE_ONLY" ] || {
        . /lib/functions.sh
        . /lib/functions/system.sh
        . /lib/functions/network.sh
        . ../netifd-proto.sh
        init_proto "$@"
}

proto_lowpan_setup() {
        local cfg="$1" #wpan.

        local ip6addr pan_id channel ifname
        json_get_vars ip6addr pan_id channel ifname

        local id=${ifname##*[[:alpha:]]}
        local interface="$cfg$id" # i.e wpan0

        ifconfig "$interface" down
        proto_init_update "$ifname" 1

        # Wifi mac address must be part of DTB to compute 6Lowpan MAC
        if [ ! -e /proc/device-tree/uccp@18480000/mac-address0 ]; then
                logger "lowpan: Could not find wifi STA MAC address"
        else
                local WIFI_STA_MAC=0x$(hexdump -n 6 -v -e '/1 "%02X"' /proc/device-tree/uccp@18480000/mac-address0)

                # 6LOWPAN_MAC = WIFI_STA_MAC + 5
                local LOWPAN_OTP_OFFSET=0x5
                local LOWPAN_MAC=$(printf "%012X" $((WIFI_STA_MAC + LOWPAN_OTP_OFFSET)))
                LOWPAN_MAC=$(macaddr_setbit_la $(macaddr_canonicalize $LOWPAN_MAC))

                # Compute EUI from MAC
                local WPAN_EUI=$(echo $LOWPAN_MAC | cut -d: -f1,2,3):ff:fe:$(echo $LOWPAN_MAC | cut -d: -f4,5,6)
                ip link set $interface address $WPAN_EUI
        fi

        iwpan dev "$interface" set pan_id "$pan_id"
        iwpan phy phy$id set channel 0 $channel
        ifconfig "$interface" up

        ip link add link "$interface" name "$ifname" type lowpan

        proto_add_ipv6_address "$ip6addr" "128"
        proto_send_update "$cfg"
}

proto_lowpan_teardown() {
        local cfg="$1"
        local iface="$2"

        local ifname
        json_get_var ifname

        local id=${ifname##*[[:alpha:]]}
        local interface="$cfg$id" # i.e wpan0

        ifconfig "$interface" down
        ip link del "$ifname"

        proto_kill_command "$cfg"
}

proto_lowpan_init_config() {
        no_device=1
        available=1
        proto_config_add_string "ip6addr"
        proto_config_add_string "pan_id"
        proto_config_add_string "channel"
}

[ -n "$INCLUDE_ONLY" ] || {
        add_protocol lowpan
}

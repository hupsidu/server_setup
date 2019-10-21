#!/bin/sh

# From https://gist.github.com/Atem18/4695539

IPT="/sbin/iptables" #Iptable's path

#Network interfaces :
interface=eth0   # Internet

start() {
    ### DELETE ALL ENTRIES ###
    $IPT -F
    $IPT -X
    ### BLOCK ALL BY DEFAULT ###
    $IPT -P INPUT DROP
    $IPT -P OUTPUT DROP
    $IPT -P FORWARD DROP
    ### Block needless IP
    ## RIPE Website https://apps.db.ripe.net/search/full-text.html
    $IPT -I INPUT  -s 85.116.217.200/29 -j DROP    # HADOPI
    $IPT -I INPUT  -s 193.107.240.0/22 -j DROP     # trident media guard (tmg)
    $IPT -I INPUT  -s 195.191.244.0/23 -j DROP     # trident media guard (tmg)
    $IPT -I INPUT  -s 193.105.197.0/24 -j DROP     # trident media guard (tmg)

    $IPT -I OUTPUT  -d 85.116.217.200/29 -j DROP   # HADOPI
    $IPT -I OUTPUT  -d 193.107.240.0/22 -j DROP     # trident media guard (tmg)
    $IPT -I OUTPUT  -d 195.191.244.0/23 -j DROP     # trident media guard (tmg) 
    $IPT -I OUTPUT  -d 193.105.197.0/24 -j DROP     # trident media guard (tmg)

    # Enable free use of loopback interfaces
    $IPT -A INPUT -i lo -j ACCEPT
    $IPT -A OUTPUT -o lo -j ACCEPT

    ###############
    ###    INPUT    ###
    ###############

    # === anti scan ===
    $IPT -N SCANS
    $IPT -A SCANS -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
    $IPT -A SCANS -p tcp --tcp-flags ALL ALL -j DROP
    $IPT -A SCANS -p tcp --tcp-flags ALL NONE -j DROP
    $IPT -A SCANS -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    ####################
    echo "Anti-scan is ready"

    #No spoofing
    if [ -e /proc/sys/net/ipv4/conf/all/ip_filter ] ;
    then
    for filtre in /proc/sys/net/ipv4/conf/*/rp_filter
    do
    echo > 1 $filtre
    done
    fi
    echo "[Anti-spoofing is ready]"

    #No synflood
    if [ -e /proc/sys/net/ipv4/tcp_syncookies ] ;
    then
    echo 1 > /proc/sys/net/ipv4/tcp_syncookies
    fi
    echo "[Anti-synflood is ready]"

    # === limited TCP, UDP, ICMP Flood ! ===

    # TCP Syn Flood
    $IPT -A INPUT -i $interface -p tcp --syn -m limit --limit 3/s -j ACCEPT
    # UDP Syn Flood
    $IPT -A INPUT -i $interface -p udp -m limit --limit 10/s -j ACCEPT
    # Ping Flood
    $IPT -A INPUT -i $interface -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
    $IPT -A INPUT -i $interface -p icmp --icmp-type echo-reply -m limit --limit 1/s -j ACCEPT
    #
    echo "TCP, UDP, ICMP Flood is now limited!"

    ####################
    # === Clean particulars paquets ===
    #Make sure NEW incoming tcp connections are SYN packets
    $IPT -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    # Packets with incoming fragments
    $IPT -A INPUT -f -j DROP
    # incoming malformed XMAS packets
    $IPT -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
    # Incoming malformed NULL packets
    $IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
    #limit the number of connection
    # $IPT -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --name BLACKLIST --set
    # $IPT -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --name BLACKLIST --update --seconds 10 --hitcount 10 --rttl -j DROP
    echo "Cleaned particulars paquets"

    #Drop icmp on WAN from serveur
    $IPT -A INPUT -i $interface -p icmp -j DROP
    echo "Ping (ICMP) is now blocked on the interface WAN"
    #Drop broadcast
    $IPT -A INPUT -m pkttype --pkt-type broadcast -j DROP

    # Accept inbound TCP packets
    $IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPT -A INPUT -p tcp --dport 20 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # FTP IN/OUT
    $IPT -A INPUT -p tcp --dport 21 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # FTP CONNECT
    $IPT -A INPUT -p tcp --dport 25 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # SMTP
    $IPT -A INPUT -p tcp --dport 80 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # HTTP
    $IPT -A INPUT -p tcp --dport 110 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # POP
    $IPT -A INPUT -p tcp --dport 443 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # HTTPS
    $IPT -A INPUT -p tcp --dport 47691 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT # SSH

    # Accept inbound UDP packets
    $IPT -A INPUT -p udp -m udp --dport 123 -s 0.0.0.0/0 -j ACCEPT # NTP
    $IPT -A INPUT -p udp -m udp --dport 67 -s 0.0.0.0/0 -j ACCEPT # BOOTSTRAP / DHCP
    $IPT -A INPUT -p udp -m udp --dport 53 -s 0.0.0.0/0 -j ACCEPT # DNS

    # Allow inbound access to Samba shares
    # $IPT -A INPUT -p udp -m udp --dport 137 -s 0.0.0.0/0 -j ACCEPT # NetBIOS
    # $IPT -A INPUT -p udp -m udp --dport 138 -s 0.0.0.0/0 -j ACCEPT # NetBIOS
    # $IPT -A INPUT -m state --state NEW -m tcp -p tcp --dport 139 -s 0.0.0.0/0 -j ACCEPT # NetBIOS
    # $IPT -A INPUT -m state --state NEW -m tcp -p tcp --dport 445 -s 0.0.0.0/0 -j ACCEPT # MS Active Directory

    # Accept inbound ICMP messages
    $IPT -A INPUT -p ICMP --icmp-type 8 -s 0.0.0.0/0 -j ACCEPT
    $IPT -A INPUT -p ICMP --icmp-type 11 -s 0.0.0.0/0 -j ACCEPT

    ####################
    ###    OUTPUT    ###
    ####################

    # == We do accept some protocols ==
    $IPT -A OUTPUT -o $interface -p UDP --dport 123 -j ACCEPT        # Port 123  (Time ntp udp)
    $IPT -A OUTPUT -o $interface -p TCP --dport 123 -j ACCEPT        # Port 123  (Time ntp tcp)
    $IPT -A OUTPUT -o $interface -p UDP --dport domain -j ACCEPT        # Port 53   (DNS)
    $IPT -A OUTPUT -o $interface -p TCP --dport domain -j ACCEPT        # Port 53   (DNS)
    $IPT -A OUTPUT -o $interface -p TCP --dport http -j ACCEPT        # Port 80   (Http)
    $IPT -A OUTPUT -o $interface -p TCP --dport https -j ACCEPT        # Port 443  (Https)
    $IPT -A OUTPUT -o $interface -p TCP --dport 47691 -j ACCEPT            # Port 47691 (SSH)
    $IPT -t filter -A OUTPUT -o $interface -m state --state NEW -s $serveur -d $UPNP_Broadcast -p udp --sport 1024: --dport $SSDP_port -j ACCEPT   # broadcast UPNP for ushare
    # Generic OUTPUT
    $IPT -A OUTPUT -o $interface --match state --state ESTABLISHED,RELATED -j ACCEPT

    echo "############ <START> ##############"
    $IPT -L -n  # comment to deactivate printing of the current rules
    echo "############ </START> ##############"
 }
stop() {
 ### OPEN ALL !!! ###
    $IPT -F
    $IPT -X
    $IPT -P INPUT ACCEPT
    $IPT -P OUTPUT ACCEPT
    $IPT -P FORWARD ACCEPT
    echo "############ <STOP> ##############"
    $IPT -L -n  # comment to deactivate printing of the current rules
    echo "############ </STOP> ##############"
 }

case "$1" in
  start)
    start
    ;;
  stop)
       stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    N=/etc/init.d/${0##*/}
    echo "Usage: $N {start|stop|restart}" >&2
    exit 1
    ;;
esac

exit 0

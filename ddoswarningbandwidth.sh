#!/bin/bash
figlet -c DDoS Warning Bandwidth
echo "Developed by Angry Agent"
webhook=$1
interface=$2
maxspeed=$3
countpacket=$4
avatar=$5
username=$6
if [[ ! $webhook ]]; then
    echo "./ddoswarningbandwidth.sh <webhook> <interface> <maxspeed(mbit/s)> <count packages tcpdump to stop capturing after [size] packages have been captured> <avatar(optional)> <username(optional)>"
    exit 1
fi
if [[ ! $interface ]]; then
    echo "./ddoswarningbandwidth.sh <webhook> <interface> <maxspeed(mbit/s)> <count packages tcpdump to stop capturing after [size] packages have been captured> <avatar(optional)> <username(optional)>"
    exit 1
fi
if [[ ! $maxspeed ]]; then
    echo "./ddoswarningbandwidth.sh <webhook> <interface> <maxspeed(mbit/s)> <count packages tcpdump to stop capturing after [size] packages have been captured> <avatar(optional)> <username(optional)>"
    exit 1
fi
if [[ ! $countpacket ]]; then
    echo "./ddoswarningbandwidth.sh <webhook> <interface> <maxspeed(mbit/s)> <count packages tcpdump to stop capturing after [size] packages have been captured> <avatar(optional)> <username(optional)>"
    exit 1
fi
while true
do
        if [ -e dumps ]
        then
            for((i=1; i < 15; i++))
            do
                date=$(date +%F -d "-$i day")
                rm -rf dumps/$date-*\:*\:*.pcap
            done
        fi
        if [ ! -e dumps ]
        then
            mkdir dumps
        fi
        R1=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        T1=$(cat /sys/class/net/$interface/statistics/tx_bytes)
        sleep 1
        R2=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        T2=$(cat /sys/class/net/$interface/statistics/tx_bytes)
        TBPS=$(( $T2 - $T1 ))
        RBPS=$(( $R2 - $R1 ))
        TKBPS=$(( $TBPS / 125000 ))
        RKBPS=$(( $RBPS / 125000 ))
        if [[ $RKBPS -gt $maxspeed && $ddos != 1 ]]; then
            ./libs/timer.sh &
            timerpid=$!
            sudo tcpdump -i $interface -c $countpacket -w dumps/$(date +%F-%T).pcap &
            rxdrop1=$(cat /sys/class/net/$interface/statistics/rx_dropped)
            txdrop1=$(cat /sys/class/net/$interface/statistics/tx_dropped)
            rxbyteattack1=$(cat /sys/class/net/$interface/statistics/rx_bytes)
            txbyteattack1=$(cat /sys/class/net/$interface/statistics/tx_bytes)
            date=$(date +%F-%T)
            echo "[$date] DDoS WARNING | tx $interface: $TKBPS mbit/s rx $interface: $RKBPS mbit/s"
            ddos=1
            date=$(date +%F-%T)
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --text "[$date] DDoS WARNING | tx $interface: $TKBPS mbit/s rx $interface: $RKBPS mbit/s"
        fi
        if [[ $RKBPS -lt $maxspeed && $ddos == 1 ]]; then
            rxdrop2=$(cat /sys/class/net/$interface/statistics/rx_dropped)
            txdrop2=$(cat /sys/class/net/$interface/statistics/tx_dropped)
            rxbyteattack2=$(cat /sys/class/net/$interface/statistics/rx_bytes)
            txbyteattack2=$(cat /sys/class/net/$interface/statistics/tx_bytes)
            rxdrop=$(( $rxdrop2 - $rxdrop1 ))
            txdrop=$(( $txdrop2 - $txdrop1 ))
            rxbyteattack=$(( $rxbyteattack2 - $rxbyteattack1 ))
            txbyteattack=$(( $txbyteattack2 - $txbyteattack1 ))
            rxbyteattack=$(( $rxbyteattack / 1024 ))
            txbyteattack=$(( $txbyteattack / 1024 ))
            rxbyteattack=$(( $rxbyteattack / 1024 ))
            txbyteattack=$(( $txbyteattack / 1024 ))
            kill $timerpid
            timesecond=$(cat second.txt)
            date=$(date +%F-%T)
            echo "[$date] DDoS END | tx $interface: $TKBPS mbit/s rx $interface: $RKBPS mbit/s"
            date=$(date +%F-%T)
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --text "[$date] DDoS END | tx $interface: $TKBPS mbit/s rx $interface: $RKBPS mbit/s"
            date=$(date +%F-%T)
            echo "[$date] DDoS TIME | $timesecond seconds"
            date=$(date +%F-%T)
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --text "[$date] DDoS TIME | $timesecond seconds"
            date=$(date +%F-%T)
            echo "[$date] DDoS STATS | RX Drop: $rxdrop, TX Drop: $txdrop, Data RX: $rxbyteattack MB, Data TX: $txbyteattack MB"
            date=$(date +%F-%T)
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --text "[$date] DDoS STATS | RX Drop: $rxdrop, TX Drop: $txdrop, Data RX: $rxbyteattack MB, Data TX: $txbyteattack MB"
            ddos=0
            vnstati -i $interface -5 -o 1.png
            vnstati -i $interface -h -o 2.png
            vnstati -i $interface -hs -o 3.png
            vnstati -i $interface -vs -o 4.png
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --file "1.png"
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --file "2.png"
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --file "3.png"
            ./libs/discord.sh --webhook-url="$webhook" --avatar "$avatar" --username "$username" --file "4.png"
            rm 1.png
            rm 2.png
            rm 3.png
            rm 4.png
            rm second.txt
            unset date
            unset timesecond
            unset rxdrop1
            unset txdrop1
            unset rxdrop2
            unset txdrop2
            unset rxdrop
            unset txdrop
            unset rxbyteattack
            unset txbyteattack
        fi
done

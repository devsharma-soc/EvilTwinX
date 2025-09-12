#!/bin/bash
# cleanup.sh - Manual cleanup for EvilTwinX
# Run if the main script crashes or doesn't exit cleanly

GREEN="\e[32m"
RESET="\e[0m"

echo -e "${GREEN}[+] Killing rogue processes...${RESET}"
pkill hostapd 2>/dev/null
pkill dnsmasq 2>/dev/null
pkill aireplay-ng 2>/dev/null
pkill airodump-ng 2>/dev/null
pkill php 2>/dev/null
pkill gnome-terminal 2>/dev/null

echo -e "${GREEN}[+] Flushing iptables...${RESET}"
iptables -F
iptables -t nat -F

echo -e "${GREEN}[+] Restoring network interfaces...${RESET}"
airmon-ng stop wlan0mon > /dev/null 2>&1
ip link set wlan0 down 2>/dev/null
ip link set wlan0 up 2>/dev/null
ip link set wlan1 down 2>/dev/null
ip link set wlan1 up 2>/dev/null

echo -e "${GREEN}[+] Removing temp configs...${RESET}"
rm -f hostapd.conf dnsmasq.conf
rm -f portal/captured.txt portal/requests.log portal/attempts.log

echo -e "${GREEN}[✔] EvilTwinX cleanup complete.${RESET}"

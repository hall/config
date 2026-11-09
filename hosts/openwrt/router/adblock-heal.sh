#!/bin/sh
# Reload adblock if its blocklist is empty (e.g. download failed during a WAN outage).
count="$(/etc/init.d/adblock status 2>/dev/null | awk -F": *" "/blocked_domains/ {print \$2; exit}" | tr -cd "0-9")"
if [ "${count:-0}" -eq 0 ]; then
	logger -t adblock-heal "blocklist empty (blocked_domains=${count:-?}), reloading"
	/etc/init.d/adblock reload
fi

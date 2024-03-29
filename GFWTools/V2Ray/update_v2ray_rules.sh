#!/bin/bash

cd $(dirname "$0")

let error_count=0
while true; do
	[ $error_count -lt 3 ] || break
	wget -qO geoip.new.dat https://proxy.111539.xyz/https://github.com/xiaokaixuan/v2ray-rules-dat/releases/latest/download/geoip.dat
	[ "$?" == "0" ] && break
	sleep 60
	let error_count+=1
done

[ -s geoip.new.dat ] && cp -f geoip.new.dat geoip.dat
rm -f geoip.new.dat

let error_count=0
while true; do
	[ $error_count -lt 3 ] || break
	wget -qO geosite.new.dat https://proxy.111539.xyz/https://github.com/xiaokaixuan/v2ray-rules-dat/releases/latest/download/geosite.dat
	[ "$?" == "0" ] && break
	sleep 60
	let error_count+=1
done

[ -s geosite.new.dat ] && cp -f geosite.new.dat geosite.dat
rm -f geosite.new.dat

systemctl restart v2ray.service v2ray-vless.service v2ray-vless-cf.service


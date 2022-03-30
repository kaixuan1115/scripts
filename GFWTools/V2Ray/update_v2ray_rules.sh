#!/bin/bash

cd $(dirname "$0")

let error_count=0
while true; do
	[ $error_count -lt 3 ] || exit 0
	wget -qO geoip.new.dat https://proxy.go-back.cf/https://github.com/xiaokaixuan/v2ray-rules-dat/releases/latest/download/geoip.dat
	[ "$?" = "0" ] && break
	sleep 60
	let error_count+=1
done

mv geoip.new.dat geoip.dat

let error_count=0
while true; do
	[ $error_count -lt 3 ] || exit 0
	wget -qO geosite.new.dat https://proxy.go-back.cf/https://github.com/xiaokaixuan/v2ray-rules-dat/releases/latest/download/geosite.dat
	[ "$?" = "0" ] && break
	sleep 60
	let error_count+=1
done

mv geosite.new.dat geosite.dat

systemctl restart v2ray.service v2ray-vless.service v2ray-vless-cf.service


#!/bin/bash

cd $(dirname "$0")

docker cp .lego/certificates/www.111111.xyz.crt hysteria:/hysteria/cert.pem
docker cp .lego/certificates/www.111111.xyz.key hysteria:/hysteria/key.pem

docker cp .lego/certificates/www.111111.xyz.crt gost-mwss:/gost/cert.pem
docker cp .lego/certificates/www.111111.xyz.key gost-mwss:/gost/key.pem

docker cp .lego/certificates/www.111111.xyz.crt v2ray-wss:/v2ray/cert.pem
docker cp .lego/certificates/www.111111.xyz.key v2ray-wss:/v2ray/key.pem

docker restart hysteria gost-mwss v2ray-wss


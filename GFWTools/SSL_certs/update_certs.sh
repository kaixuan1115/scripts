#!/bin/bash

cd $(dirname "$0")

exec 1> >(tee -a update_certs.log) 2>&1

./lego --email="kaixuan1115@126.com" --domains="www.111111.xyz" --http renew --renew-hook="./myscript1.sh"


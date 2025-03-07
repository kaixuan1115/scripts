#!/bin/bash

cd $(dirname "$0")

./lego --email="kaixuan1115@126.com" --domains="www.111111.xyz" --http renew --renew-hook="./myscript1.sh"


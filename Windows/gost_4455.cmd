@echo off

set "CMD=gost -D -L=tcp://:4455/127.0.0.1:445 -F=ss://chacha20:ss123456@home.test.win:7000?mbind=true"

title Forward TCP Port 4455 To 445

echo/
echo Create COMMAND: net use K: \\127.0.0.1\Root /TCPPORT:4455
echo/
echo Delete COMMAND: net use K: /DELETE
echo/

echo Executing: %CMD%
echo/ & %CMD%


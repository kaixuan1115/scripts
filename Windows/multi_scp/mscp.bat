@echo off

setlocal enabledelayedexpansion

:getParams
if "%~1"=="" goto :main
set target=%1
shift /1
if "%~1"=="" goto :main
set params=%params% %target%
goto :getParams

:main
set "servers[0]=ubuntu@118.24.141.52 123456"
set "servers[1]=ubuntu@118.24.141.53 123456"

for /l %%i in (0 1 20) do (
	if not defined servers[%%i] goto :EOF
	for /f "tokens=1,2" %%a in ("!servers[%%i]!") do (
		echo Copying%params% %%a:%target% && pscp.exe -pw "%%b"%params% %%a:%target%
	)
)


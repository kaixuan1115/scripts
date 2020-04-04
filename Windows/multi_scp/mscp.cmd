@echo off

setlocal

:getParams
if "%~1"=="" goto :main
set target=%1
shift /1
if "%~1"=="" goto :main
set params=%params% %target%
goto :getParams

:main
for /f "usebackq skip=20 tokens=1,2 delims=;" %%i in ("%~f0") do (
	echo Copying%params% %%j:%target% && pscp %%i%params% %%j:%target%
	echo.
)
exit /b

:consts
-pw "123456";ubuntu@118.24.141.52
-pw "123456";ubuntu@118.24.141.53


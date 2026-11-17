@echo off

pushd "%~dp0"
setlocal enabledelayedexpansion

echo @echo off > import_ignores.cmd
echo pushd "%%~dp0" >> import_ignores.cmd

for /f "usebackq tokens=* delims=" %%i in (`svn propget svn:ignore -R .`) do (
	set "line=%%i"
	set "line=!line: - =|!"
	for /f "tokens=1,* delims=|" %%a in ("!line!") do (
		echo ---%%a-------%%b---
		set "string0=%%a"
		set "string1=%%b"
		if defined string1 (
			if defined workdir (
				echo svn propset svn:ignore -F ignores.txt "!workdir!" >> import_ignores.cmd
				set "workdir="
			)
			set "workdir=!string0!"
			echo/ >> import_ignores.cmd
			>> import_ignores.cmd echo ^> ignores.txt echo !string1!
		) else (
			>> import_ignores.cmd echo ^>^> ignores.txt echo !string0!
		)
	)
)
if defined workdir (
	echo svn propset svn:ignore -F ignores.txt "!workdir!" >> import_ignores.cmd
	set "workdir="
	echo/ >> import_ignores.cmd
)
(
	echo del /f ignores.txt 2^>nul ^>nul
	echo echo/
	echo echo Press any key to quit...
	echo pause^>nul
) >> import_ignores.cmd

echo/
echo generate import_ignores.cmd success.
echo/
echo Press any key to quit...
pause>nul


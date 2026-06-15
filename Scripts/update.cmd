@echo off
setlocal enabledelayedexpansion
for /f "delims=" %%x in ('findstr /N "^" "update.txt"') do (
	set line=%%x
	set line=!line:*:=!
	cd /d %~dp0
	call :process "!line!"
)
exit /b
pause
:process
setlocal
set "ver="
set "pat="
rem echo. >%~1
for /f "delims=" %%a in ('findstr /N "^" "%~1"') do (
	set line=%%a
	set line=!line:*:=!
	set processline=!line:"=!
	echo !processline! | find "supported_version" >nul
	if !errorlevel!==0 (
		echo supported_version="3.8.*">>"%~1w"
		set ver=true
	) else (
		echo !line!>>"%~1w"
	)
	echo !processline! | find "path" >nul
	if !errorlevel!==0 (
		set pat=!line:path=!
		set pat=!pat:~1!
	)
)
del "%~1"
ren "%~1w" "%~1"
if defined pat (
	echo !pat!
	cd /d !pat!
	call :process descriptor.mod
)
endlocal&exit /b
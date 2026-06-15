@echo off
set version="2.3.*"
setlocal enabledelayedexpansion
echo note that this combines archives from subdirectories as well.
echo enable logging?
choice
set logging=%errorlevel%
echo What is the directory to merge? 
set /p steamdir="" || set steamdir="C:\Program Files (x86)\Steam\steamapps\workshop\content\281990"
echo would you like to make a .mod file?
choice
if %errorlevel% equ 2 goto nomod
echo What directory does the .mod file go in?
set /p moddir="" || set moddir="%userprofile%\Documents\Paradox Interactive\Stellaris\mod"
:nomod
echo what would you like the new name to be?
set /p name="" || set name="Merged Mod"
set name=%name:"=%
echo Merging...
if %logging% equ 1 call :merge
if %logging% equ 2 call :merge >mergemod.log
echo done merging
if defined moddir (
	cd %moddir%
	call :modfile > "%name%.mod"
)
exit
:modfile
cd %moddir%
echo name="%name%"
echo archive="%steamdir:"=%\%name: =%.zip"
echo tags = {
echo 	"mod collection"
for /d %%i in (%steamdir%\*) do (
	set number=%%i
	set number=!number:*0\=!
	set /p mods=<"ugc_!number!.mod"
	set mods=!mods:"=!
	echo 	"!mods:~5!"
)
echo }
echo supported_version=%version%
exit
:merge
cd %steamdir%
mkdir !temp >nul 2>&1
"C:\Program Files\7-zip\7z.exe" x * -y -o!temp
cd !temp
"C:\Program Files\7-zip\7z.exe" a "%name: =%.zip" * -y
cd %steamdir%
move /y "!temp\%name: =%.zip" "%cd%"
rmdir /s /q !temp
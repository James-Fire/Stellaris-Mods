@echo off
setlocal enabledelayedexpansion

:: Move up one level from the current folder
cd ..

for %%F in (*.mod) do (
    set "name=%%~nF"

    if exist "!name!\" (
        echo Processing !name!

        copy "%%F" "!name!\" >nul

        if exist "!name!\descriptor.mod" (
            del "!name!\descriptor.mod"
        )

        ren "!name!\%%F" descriptor.mod

        powershell -NoProfile -Command ^
            "$file='!name!\descriptor.mod';" ^
            "(Get-Content $file) | Where-Object { $_ -notmatch '^path' } | Set-Content $file"
    )
)

echo Done.
pause
@echo off
setlocal
title Crid Installer

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Crid.ps1" %*
set "CRID_EXIT_CODE=%ERRORLEVEL%"

if not "%CRID_EXIT_CODE%"=="0" (
  echo.
  echo Crid installation or update failed with exit code %CRID_EXIT_CODE%.
  pause
  exit /b %CRID_EXIT_CODE%
)

echo.
echo Crid installation or update completed successfully.
timeout /t 4 /nobreak >nul
exit /b 0

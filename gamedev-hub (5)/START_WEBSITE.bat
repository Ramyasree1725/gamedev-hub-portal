@echo off
title GameDev Hub - Local Gaming Server
echo ================================================================
echo             LAUNCHING GAMEDEV HUB LOCALHOST SERVER...
echo ================================================================
echo.
echo Starting built-in web server on http://localhost:8080 ...
echo Your default web browser will open automatically!
echo.
echo (Keep this window open while playing)
echo ================================================================
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause

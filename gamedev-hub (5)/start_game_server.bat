@echo off
title GameDev Hub Gaming Server
echo ========================================================
echo         STARTING GAMEDEV HUB GAMING SERVER...
echo ========================================================
echo.
cd /d "%~dp0gamedev-hub\backend"
echo Installing requirements (if needed)...
pip install -r requirements.txt
echo.
echo Starting Flask Server on http://localhost:8080 ...
echo.
echo Open your browser at: http://localhost:8080
echo.
python app.py
pause

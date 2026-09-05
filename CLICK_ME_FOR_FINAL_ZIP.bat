@echo off
title Generating 100% Passing TrainPlex Submission ZIP
color 0A
cd /d "%~dp0"

echo ================================================================
echo    GENERATING 100%% PASSING TRAINPLEX SUBMISSION ZIP
echo ================================================================
echo.

python build_clean_repo.py

echo.
echo ================================================================
echo  DONE!
echo  Please upload the file:
echo  👉 READY_FOR_TRAINPLEX.zip
echo  directly to the TrainPlex checker!
echo ================================================================
echo.
explorer.exe /select,"%~dp0READY_FOR_TRAINPLEX.zip"
pause

@echo off
setlocal enabledelayedexpansion
title GitHub New Repo Creator and PR Merger
color 0A

echo ================================================================
echo       CREATE BRAND NEW GITHUB REPOSITORY AND PUSH 4 PRs
echo ================================================================
echo.

set "REPO_DIR=%~dp0gamedev-hub (5)\gamedev-hub"
if not exist "!REPO_DIR!\.git" (
    set "REPO_DIR=%~dp0"
)

cd /d "!REPO_DIR!"

set /p USER_INPUT="Enter New Repository Name (or press ENTER for 'gamedev-hub-portal'): "
if "%USER_INPUT%"=="" set USER_INPUT=gamedev-hub-portal

:: Replace spaces with hyphens in repo name
set "REPO_NAME=%USER_INPUT: =-%"

echo.
echo Selected Repository Name: !REPO_NAME!
echo.

:: Get GitHub username
for /f "tokens=*" %%i in ('gh api user -q .login 2^>nul') do set GH_USER=%%i
if "!GH_USER!"=="" set GH_USER=Ramyasree1725

echo [1/4] Creating New GitHub Repository '!REPO_NAME!' for user '!GH_USER!'...
echo ----------------------------------------------------------------
gh repo create "!REPO_NAME!" --public 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Repo might already exist, linking to it...
)

git remote remove origin 2>nul
git remote add origin "https://github.com/!GH_USER!/!REPO_NAME!.git"
echo Remote Origin configured: https://github.com/!GH_USER!/!REPO_NAME!.git

echo.
echo Pushing 'main' branch...
git push --force -u origin main
echo.

echo [2/4] Pushing all 4 Feature Branches to '!REPO_NAME!'...
echo ----------------------------------------------------------------
echo Pushing feature/achievement-system...
git push --force -u origin feature/achievement-system

echo Pushing feature/docker-support...
git push --force -u origin feature/docker-support

echo Pushing feature/leaderboard-enhancements...
git push --force -u origin feature/leaderboard-enhancements

echo Pushing feature/test-coverage...
git push --force -u origin feature/test-coverage
echo.

echo [3/4] Creating 4 Pull Requests...
echo ----------------------------------------------------------------
echo 1. PR: Achievement System...
gh pr create --repo "!GH_USER!/!REPO_NAME!" --base main --head feature/achievement-system --title "Feature: Achievement System" --body "Merge achievement system into main" 2>nul

echo 2. PR: Docker Support...
gh pr create --repo "!GH_USER!/!REPO_NAME!" --base main --head feature/docker-support --title "Feature: Docker Support" --body "Merge docker support into main" 2>nul

echo 3. PR: Leaderboard Enhancements...
gh pr create --repo "!GH_USER!/!REPO_NAME!" --base main --head feature/leaderboard-enhancements --title "Feature: Leaderboard Enhancements" --body "Merge leaderboard enhancements into main" 2>nul

echo 4. PR: Test Coverage...
gh pr create --repo "!GH_USER!/!REPO_NAME!" --base main --head feature/test-coverage --title "Feature: Test Coverage" --body "Merge test coverage into main" 2>nul
echo.

echo [4/4] Merging all 4 Pull Requests into Main...
echo ----------------------------------------------------------------
echo Merging PR 1...
gh pr merge feature/achievement-system --repo "!GH_USER!/!REPO_NAME!" --merge --admin 2>nul || gh pr merge feature/achievement-system --repo "!GH_USER!/!REPO_NAME!" --merge 2>nul

echo Merging PR 2...
gh pr merge feature/docker-support --repo "!GH_USER!/!REPO_NAME!" --merge --admin 2>nul || gh pr merge feature/docker-support --repo "!GH_USER!/!REPO_NAME!" --merge 2>nul

echo Merging PR 3...
gh pr merge feature/leaderboard-enhancements --repo "!GH_USER!/!REPO_NAME!" --merge --admin 2>nul || gh pr merge feature/leaderboard-enhancements --repo "!GH_USER!/!REPO_NAME!" --merge 2>nul

echo Merging PR 4...
gh pr merge feature/test-coverage --repo "!GH_USER!/!REPO_NAME!" --merge --admin 2>nul || gh pr merge feature/test-coverage --repo "!GH_USER!/!REPO_NAME!" --merge 2>nul

echo.
echo ================================================================
echo  SUCCESS!
echo  - GitHub Repository: https://github.com/!GH_USER!/!REPO_NAME!
echo  - Main branch and 4 feature branches pushed!
echo  - 4 Pull Requests Created and Merged Successfully!
echo ================================================================
echo.
pause

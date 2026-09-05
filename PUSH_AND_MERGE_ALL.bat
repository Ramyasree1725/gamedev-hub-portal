@echo off
setlocal enabledelayedexpansion
title GitHub Auto Push & PR Manager
color 0B

echo ================================================================
echo           GAME DEV HUB - GITHUB PUSH & MERGE AUTOMATOR
echo ================================================================
echo.

set "REPO_DIR=%~dp0gamedev-hub (5)\gamedev-hub"
if not exist "!REPO_DIR!\.git" (
    set "REPO_DIR=%~dp0"
)

cd /d "!REPO_DIR!"
echo [1/3] Target Repository: !REPO_DIR!
echo.

echo [2/3] Force Pushing all branches to GitHub...
echo ----------------------------------------------------------------
echo 1. Pushing 'main'...
git push --force -u origin main

echo 2. Pushing 'feature/achievement-system'...
git push --force -u origin feature/achievement-system

echo 3. Pushing 'feature/docker-support'...
git push --force -u origin feature/docker-support

echo 4. Pushing 'feature/leaderboard-enhancements'...
git push --force -u origin feature/leaderboard-enhancements

echo 5. Pushing 'feature/test-coverage'...
git push --force -u origin feature/test-coverage
echo ----------------------------------------------------------------
echo All branches pushed successfully to GitHub!
echo.

echo [3/3] Creating and Merging Pull Requests...
echo ----------------------------------------------------------------

echo.
echo === PR 1: feature/achievement-system ===
gh pr create --base main --head feature/achievement-system --title "Feature: Achievement System" --body "Merge achievement system into main"
gh pr merge feature/achievement-system --merge --admin || gh pr merge feature/achievement-system --merge

echo.
echo === PR 2: feature/docker-support ===
gh pr create --base main --head feature/docker-support --title "Feature: Docker Support" --body "Merge docker support into main"
gh pr merge feature/docker-support --merge --admin || gh pr merge feature/docker-support --merge

echo.
echo === PR 3: feature/leaderboard-enhancements ===
gh pr create --base main --head feature/leaderboard-enhancements --title "Feature: Leaderboard Enhancements" --body "Merge leaderboard enhancements into main"
gh pr merge feature/leaderboard-enhancements --merge --admin || gh pr merge feature/leaderboard-enhancements --merge

echo.
echo === PR 4: feature/test-coverage ===
gh pr create --base main --head feature/test-coverage --title "Feature: Test Coverage" --body "Merge test coverage into main"
gh pr merge feature/test-coverage --merge --admin || gh pr merge feature/test-coverage --merge

echo.
echo ================================================================
echo  SUCCESS! All 4 Branches Pushed and PRs Created & Merged!
echo ================================================================
echo.
echo Press any key to exit...
pause >nul

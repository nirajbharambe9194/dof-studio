@echo off
echo Stopping DoF Studio development processes...
taskkill /FI "WINDOWTITLE eq DoF Studio - Backend API*" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq DoF Studio - Frontend*" /T /F >nul 2>&1
echo DoF Studio stopped. MySQL was left running.
pause

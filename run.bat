@echo off

:: Kiểm tra quyền admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...

    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

powershell -ExecutionPolicy Bypass -File "%~dp0auto.ps1"

pause

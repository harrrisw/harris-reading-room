@echo off
setlocal
cd /d "%~dp0"
set "BOOK_MANAGER_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%BOOK_MANAGER_BASH%" (
    echo Git Bash was not found at "%BOOK_MANAGER_BASH%".
    echo Install Git for Windows or run app.sh with your Git Bash executable in PowerShell.
    pause
    exit /b 1
)
"%BOOK_MANAGER_BASH%" app.sh
if errorlevel 1 pause

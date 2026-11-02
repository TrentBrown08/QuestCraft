@echo off
rem Double-click friendly wrapper: runs release.sh through Git Bash
set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%BASH%" (
  echo Git Bash not found at "%BASH%". Install Git for Windows.
  pause
  exit /b 1
)
"%BASH%" "%~dp0release.sh" %*
pause

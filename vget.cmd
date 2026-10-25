@echo off
rem ==============================================================================
rem vget - Windows Native Command Wrapper
rem Role: Permet d'exécuter vget directement depuis CMD, PowerShell et Windows Terminal
rem ==============================================================================
setlocal enabledelayedexpansion

set "BASH_BIN="

rem 1. Recherche dans les emplacements standards de Git for Windows
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    set "BASH_BIN=%ProgramFiles%\Git\bin\bash.exe"
) else if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    set "BASH_BIN=%ProgramFiles(x86)%\Git\bin\bash.exe"
) else if exist "%LocalAppData%\Programs\Git\bin\bash.exe" (
    set "BASH_BIN=%LocalAppData%\Programs\Git\bin\bash.exe"
) else if exist "%SystemDrive%\msys64\usr\bin\bash.exe" (
    set "BASH_BIN=%SystemDrive%\msys64\usr\bin\bash.exe"
)

rem 2. Recherche dans le PATH système
if "%BASH_BIN%"=="" (
    for /f "tokens=*" %%i in ('where bash.exe 2^>nul') do (
        if "%BASH_BIN%"=="" set "BASH_BIN=%%i"
    )
)

rem 3. Si aucun Bash natif n'est trouvé, tenter d'utiliser WSL
if "%BASH_BIN%"=="" (
    where wsl.exe >nul 2>&1
    if not errorlevel 1 (
        wsl.exe bash -c "vget $(wslpath -a '%~dp0bin/vget') %*"
        exit /b %errorlevel%
    )
    echo [vget] Erreur : Aucun interpreteur Bash 4+ (Git Bash ou WSL) detecte.
    echo [vget] Veuillez installer Git for Windows : winget install Git.Git
    exit /b 1
)

rem Conversion du chemin Windows en chemin Unix pour Git Bash
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:\=/%"
set "VGET_SCRIPT=/%SCRIPT_DIR:~0,1%%SCRIPT_DIR:~2%bin/vget"

"%BASH_BIN%" -l "%VGET_SCRIPT%" %*
exit /b %errorlevel%

@echo off
rem dotfiles CLI for Windows: runs the Python script linked next to this file.
rem Linked to ~/.local/bin/dotfiles.cmd so it works from PowerShell, cmd and WezTerm.
where py >nul 2>&1
if %errorlevel% equ 0 (
    py -3 "%USERPROFILE%\.local\bin\dotfiles" %*
) else (
    python "%USERPROFILE%\.local\bin\dotfiles" %*
)
exit /b %errorlevel%

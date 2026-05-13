@echo off
title Desinstalador - Agente de Wallpaper Corporativo
echo =======================================================
echo Iniciando Desinstalador do Wallpaper Corporativo...
echo =======================================================
echo.

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run
set REG_NAME=CorporateWallpaperAgent

echo [1/3] Encerrando o Agente, se estiver em execucao...
powershell -Command "Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like '*WallpaperAgent*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1
powershell -Command "Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like '*WallpaperLauncher*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1
timeout /t 3 /nobreak >nul

echo [2/3] Removendo o Agente da Inicializacao do Windows...
reg delete "%REG_KEY%" /v "%REG_NAME%" /f >nul 2>&1

echo [3/3] Removendo os Arquivos do Sistema...
if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%" >nul 2>&1
)

if exist "%TARGET_DIR%" (
    echo [AVISO] Alguns arquivos nao puderam ser removidos.
    echo         Tente reiniciar o PC e rodar o desinstalador novamente.
) else (
    echo         Arquivos removidos com sucesso.
)

echo.
echo =======================================================
echo SUCESSO! Agente removido completamente do seu notebook.
echo Seu papel de parede atual nao sera alterado.
echo =======================================================
pause

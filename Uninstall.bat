@echo off
title Desinstalador - Agente de Wallpaper Corporativo
echo =======================================================
echo Iniciando Desinstalador do Wallpaper Corporativo...
echo =======================================================
echo.

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run
set REG_NAME=CorporateWallpaperAgent

:: 1. Encerrar processos (tenta 2 metodos pra garantir)
echo [1/4] Encerrando processos do agente...
powershell -NoProfile -Command "Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like '*WallpaperAgent*' -or $_.CommandLine -like '*WallpaperLauncher*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1
taskkill /f /im wscript.exe /fi "WINDOWTITLE eq WallpaperLauncher*" >nul 2>&1
timeout /t 2 /nobreak >nul

:: 2. Remover do registro de inicializacao
echo [2/4] Removendo da inicializacao do Windows...
reg delete "%REG_KEY%" /v "%REG_NAME%" /f >nul 2>&1

:: 3. Restaurar ExecutionPolicy para o padrao (Restricted)
echo [3/4] Restaurando politica de execucao PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted -Force" >nul 2>&1

:: 4. Remover pasta e arquivos temporarios
echo [4/4] Removendo arquivos do sistema...
if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%" >nul 2>&1
)

:: Limpar arquivos temporarios do TEMP (logs, diagnostico, b64)
del /f /q "%TEMP%\CorpWallpaper_Install_*.log" >nul 2>&1
del /f /q "%TEMP%\CorpWallpaper_Diagnostic.txt" >nul 2>&1
del /f /q "%TEMP%\agent_ps1.b64" >nul 2>&1
del /f /q "%TEMP%\agent_vbs.b64" >nul 2>&1

:: Verificar resultado
set UNINSTALL_OK=1
if exist "%TARGET_DIR%" set UNINSTALL_OK=0
reg query "%REG_KEY%" /v "%REG_NAME%" >nul 2>&1 && set UNINSTALL_OK=0

echo.
if %UNINSTALL_OK%==1 (
    echo =======================================================
    echo SUCESSO! Agente removido completamente do seu computador.
    echo Seu papel de parede atual nao sera alterado.
    echo =======================================================
) else (
    echo =======================================================
    echo [AVISO] Alguns residuos nao puderam ser removidos.
    echo Tente reiniciar o PC e rodar o desinstalador novamente.
    echo =======================================================
)
pause

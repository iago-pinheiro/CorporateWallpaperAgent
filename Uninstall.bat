@echo off
title Desinstalador - Agente de Wallpaper Corporativo
echo =======================================================
echo Iniciando Desinstalador do Wallpaper Corporativo...
echo =======================================================
echo.

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set EXE_NAME=WallpaperAgent.exe

echo [1/4] Encerrando o Agente, se estiver em execucao...
taskkill /f /im "%EXE_NAME%" /t >nul 2>&1

echo [2/4] Removendo o Agente da Inicializacao do Windows (Startup)...
if exist "%STARTUP_DIR%\Wallpaper Corp.lnk" (
    del /f /q "%STARTUP_DIR%\Wallpaper Corp.lnk" >nul 2>&1
)
:: Remover também aquele criado pelo próprio C# autoinstalador 
if exist "%STARTUP_DIR%\CorporateWallpaper.lnk" (
    del /f /q "%STARTUP_DIR%\CorporateWallpaper.lnk" >nul 2>&1
)

echo [3/4] Removendo os Arquivos do Sistema...
if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%" >nul 2>&1
)

echo [4/4] Restaurando a configuracao do seu Wallpaper?
echo O sistema do papel de parede dinamico foi Removido. Tudo certo.

echo.
echo =======================================================
echo SUCESSO! Agente removido completamente do seu notebook.
echo =======================================================
pause

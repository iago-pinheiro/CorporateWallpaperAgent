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
:: Aguardar o processo liberar os arquivos
timeout /t 3 /nobreak >nul

echo [2/4] Removendo o Agente da Inicializacao do Windows (Startup)...
:: Remover atalho atual
if exist "%STARTUP_DIR%\CorporateWallpaper.lnk" (
    del /f /q "%STARTUP_DIR%\CorporateWallpaper.lnk" >nul 2>&1
)
:: Remover atalho de versões anteriores (nome antigo)
if exist "%STARTUP_DIR%\Wallpaper Corp.lnk" (
    del /f /q "%STARTUP_DIR%\Wallpaper Corp.lnk" >nul 2>&1
)

echo [3/4] Removendo os Arquivos do Sistema...
if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%" >nul 2>&1
)

:: Verificar se a pasta foi realmente removida
if exist "%TARGET_DIR%" (
    echo [AVISO] Alguns arquivos nao puderam ser removidos.
    echo         Isso pode acontecer se outro programa esta usando-os.
    echo         Tente reiniciar o PC e rodar o desinstalador novamente.
    echo.
    echo Pasta restante: %TARGET_DIR%
) else (
    echo         Arquivos removidos com sucesso.
)

echo [4/4] Limpeza finalizada.

echo.
echo =======================================================
echo SUCESSO! Agente removido completamente do seu notebook.
echo Seu papel de parede atual nao sera alterado.
echo =======================================================
pause

@echo off
title Diagnostico - Wallpaper Corporativo
color 0B
cd /d "%~dp0"

echo =======================================================
echo   DIAGNOSTICO DO AGENTE DE PAPEL DE PAREDE
echo =======================================================
echo.
echo Isso vai gerar um arquivo para o TI descobrir
echo o que esta acontecendo com a instalacao.
echo.
echo Aguarde alguns segundos...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "WallpaperDiagnostic.ps1"

echo.
echo =======================================================
echo   PRONTO! Arquivo gerado com sucesso!
echo.
echo   O arquivo esta em:
echo   %TEMP%\CorpWallpaper_Diagnostic.txt
echo.
echo   Pressione qualquer tecla para abrir a pasta...
echo =======================================================
pause >nul
start "" "%TEMP%"

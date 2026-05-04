@echo off
title Empacotando - Corporate Wallpaper Agent
color 0B
echo.
echo =================================================================
echo       CORPORATE WALLPAPER AGENT - EMPACOTAMENTO
echo =================================================================
echo.

cd /d "%~dp0"

:: 1. Criar pasta temporaria de distribuicao
echo [1/3] Montando arquivos do pacote...
if exist "dist_temp" rmdir /s /q "dist_temp"
mkdir "dist_temp"

copy /y "WallpaperAgent.ps1"  "dist_temp\WallpaperAgent.ps1"  >nul
copy /y "Install.bat"         "dist_temp\SOMENTE CLIQUE AQUI PARA INSTALAR.bat" >nul
copy /y "Uninstall.bat"       "dist_temp\Uninstall.bat"        >nul

if exist "config.txt" (
    copy /y "config.txt" "dist_temp\config.txt" >nul
    echo     config.txt incluido no pacote.
)
echo     OK! Arquivos copiados.

:: 2. Criar ZIP via PowerShell
echo [2/3] Compactando ZIP...
if exist "WallpaperCorporativo.zip" del /f /q "WallpaperCorporativo.zip"
powershell -NoProfile -Command "Compress-Archive -Path 'dist_temp\*' -DestinationPath 'WallpaperCorporativo.zip' -Force"

if not exist "WallpaperCorporativo.zip" (
    color 0C
    echo [ERRO] Falha ao criar o ZIP.
    pause
    exit /b
)
echo     OK! ZIP criado.

:: 3. Limpar temporarios
echo [3/3] Limpando arquivos temporarios...
rmdir /s /q "dist_temp"
echo     OK!

echo.
echo =================================================================
echo.
echo  PRONTO! Arquivo gerado: WallpaperCorporativo.zip
echo.
echo  Conteudo do ZIP:
echo    - SOMENTE CLIQUE AQUI PARA INSTALAR.bat
echo    - WallpaperAgent.ps1
if exist "config.txt" echo    - config.txt
echo    - Uninstall.bat
echo.
echo  Envie este ZIP para os colaboradores!
echo.
echo =================================================================
pause

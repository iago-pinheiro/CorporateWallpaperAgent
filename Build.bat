@echo off
title Empacotando - Corporate Wallpaper Agent
color 0B
echo.
echo =================================================================
echo       CORPORATE WALLPAPER AGENT - EMPACOTAMENTO
echo =================================================================
echo.

cd /d "%~dp0"

:: 1. Verificar arquivos essenciais de origem
echo [1/3] Verificando e montando pacote...

set BUILD_ERROR=0
for %%F in ("WallpaperAgent.ps1" "WallpaperLauncher.vbs" "Install.bat" "Uninstall.bat") do (
    if not exist "%%~F" (
        echo [ERRO] %%~F nao encontrado!
        set BUILD_ERROR=1
    )
)
if %BUILD_ERROR%==1 (
    color 0C
    echo.
    echo [ERRO] Arquivos essenciais ausentes. Abortando.
    pause
    exit /b
)

if exist "dist_temp" rmdir /s /q "dist_temp"
mkdir "dist_temp"

copy /y "WallpaperAgent.ps1"   "dist_temp\WallpaperAgent.ps1"  >nul
copy /y "WallpaperLauncher.vbs" "dist_temp\WallpaperLauncher.vbs" >nul
copy /y "Install.bat"           "dist_temp\SOMENTE CLIQUE AQUI PARA INSTALAR.bat" >nul
copy /y "Uninstall.bat"         "dist_temp\Uninstall.bat"         >nul
copy /y "WallpaperDiagnostic.ps1" "dist_temp\WallpaperDiagnostic.ps1" >nul
copy /y "Diagnostico.bat"          "dist_temp\Diagnostico.bat"          >nul

if exist "config.txt" (
    copy /y "config.txt" "dist_temp\config.txt" >nul
    echo     config.txt incluido no pacote.
) else (
    echo     AVISO: config.txt nao encontrado - URL padrao sera usada.
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
echo    - WallpaperLauncher.vbs
echo    - WallpaperDiagnostic.ps1
echo    - Diagnostico.bat
if exist "config.txt" echo    - config.txt
echo    - Uninstall.bat
echo.
echo  Envie este ZIP para os colaboradores!
echo.
echo =================================================================
pause

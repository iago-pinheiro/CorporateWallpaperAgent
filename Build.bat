@echo off
title Compilando e Empacotando - Corporate Wallpaper Agent
color 0B
echo.
echo =================================================================
echo       CORPORATE WALLPAPER AGENT - BUILD E EMPACOTAMENTO
echo =================================================================
echo.

:: 1. Compilar o EXE
echo [1/4] Compilando WallpaperAgent.cs...
set CSC_PATH=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe

if not exist "%CSC_PATH%" (
    set CSC_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe
)

if not exist "%CSC_PATH%" (
    color 0C
    echo [ERRO] Compilador C# nao encontrado.
    echo Certifique-se de ter o .NET Framework 4.x instalado.
    pause
    exit /b
)

if exist "WallpaperAgent.exe" del "WallpaperAgent.exe" >nul 2>&1
"%CSC_PATH%" /nologo /target:winexe /optimize /out:WallpaperAgent.exe WallpaperAgent.cs

if errorlevel 1 goto erro_compilacao
if not exist "WallpaperAgent.exe" goto erro_compilacao
echo     OK! WallpaperAgent.exe gerado.
goto empacotamento

:erro_compilacao
color 0C
echo.
echo [ERRO] Compilacao falhou! Verifique os erros acima.
pause
exit /b

:empacotamento

:: 2. Criar pasta temporaria de distribuicao
echo [2/4] Montando arquivos do pacote...
if exist "dist_temp" rmdir /s /q "dist_temp"
mkdir "dist_temp"

copy /y "WallpaperAgent.exe" "dist_temp\WallpaperAgent.exe" >nul
copy /y "Install.bat" "dist_temp\SOMENTE CLIQUE AQUI PARA INSTALAR.bat" >nul
copy /y "Uninstall.bat" "dist_temp\Uninstall.bat" >nul

:: Inclui config.txt se existir na pasta (opcional)
if exist "config.txt" (
    copy /y "config.txt" "dist_temp\config.txt" >nul
    echo     config.txt incluido no pacote.
)

echo     OK! Arquivos copiados.

:: 3. Criar o ZIP final via PowerShell
echo [3/4] Compactando o ZIP...
if exist "WallpaperCorporativo.zip" del /f /q "WallpaperCorporativo.zip"
powershell -NoProfile -Command "Compress-Archive -Path 'dist_temp\*' -DestinationPath 'WallpaperCorporativo.zip' -Force"

if not exist "WallpaperCorporativo.zip" (
    color 0C
    echo [ERRO] Falha ao criar o ZIP.
    pause
    exit /b
)
echo     OK! WallpaperCorporativo.zip criado.

:: 4. Limpar temporarios
echo [4/4] Limpando arquivos temporarios...
rmdir /s /q "dist_temp"
echo     OK!

echo.
echo =================================================================
echo.
echo  PRONTO! Arquivo gerado: WallpaperCorporativo.zip
echo.
echo  Conteudo do ZIP:
echo    - SOMENTE CLIQUE AQUI PARA INSTALAR.bat
echo    - WallpaperAgent.exe
if exist "config.txt" echo    - config.txt
echo    - Uninstall.bat
echo.
echo  Envie este ZIP para os colaboradores!
echo.
echo =================================================================
pause

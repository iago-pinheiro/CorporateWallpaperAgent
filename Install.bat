@echo off
title Instalador - Agente de Wallpaper Corporativo
echo =======================================================
echo Iniciando Instalador Silencioso de Wallpaper...
echo =======================================================
echo.

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set EXE_NAME=WallpaperAgent.exe

:: 1. Verificar se o EXE foi compilado
if not exist "%EXE_NAME%" (
    echo [ERRO] O aplicativo %EXE_NAME% nao foi encontrado nesta pasta.
    echo Por favor, rode o script 'Build.bat' primeiro para criar o executavel!
    echo.
    pause
    exit /b
)

:: 2. Criar a pasta escondida do Agente
echo [1/4] Criando pasta de destino escondida do usuario...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 3. Copiar o executavel
echo [2/4] Copiando e Instalando o executavel...
copy /y "%EXE_NAME%" "%TARGET_DIR%\%EXE_NAME%" >nul

:: 4. Criar atalho no Startup do MS Windows nativamente (usando VBScript em memoria para n ter complicoes)
echo [3/4] Registrando no Startup do Windows (sem admin)...
set VBS_SCRIPT="%temp%\CreateShortcut.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") > %VBS_SCRIPT%
echo sLinkFile = "%STARTUP_DIR%\Wallpaper Corp.lnk" >> %VBS_SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %VBS_SCRIPT%
echo oLink.TargetPath = "%TARGET_DIR%\%EXE_NAME%" >> %VBS_SCRIPT%
echo oLink.WorkingDirectory = "%TARGET_DIR%" >> %VBS_SCRIPT%
echo oLink.Description = "Sincronizador Silencioso do Wallpaper Corporativo" >> %VBS_SCRIPT%
echo oLink.Save >> %VBS_SCRIPT%

cscript /nologo %VBS_SCRIPT%
del %VBS_SCRIPT%

:: 5. Start inicial do script para aplicar na mesma hora, sem precisar de logoff.
echo [4/4] Executando o motor para aplicar o primeiro wallpaper...
start "" "%TARGET_DIR%\%EXE_NAME%"

echo.
echo =======================================================
echo.
echo SUCESSO! A instalacao acabou e funcionou perfeitamente.
echo O fundo de tela mudara sozinho em alguns segundos...
echo Esse script podera ser enviado para os funcionarios rodarem 
echo sem precisarem de senha/Admin da maquina!
echo.
echo =======================================================
pause

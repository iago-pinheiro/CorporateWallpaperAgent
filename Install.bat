@echo off
title Ativando o Papel de Parede Corporativo
color 0B
echo.
echo =================================================================
echo       BEM-VINDO: AGENTE DE PAPEL DE PAREDE
echo =================================================================
echo.
echo Ola! Estamos configurando o seu novo papel de parede dinamico.
echo Este processo e 100%% seguro e nao pedira senhas.
echo.

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set EXE_NAME=WallpaperAgent.exe
set SHORTCUT_NAME=CorporateWallpaper.lnk

:: 1. Verificar se o EXE foi compilado
if not exist "%EXE_NAME%" (
    color 0C
    echo [ERRO] O aplicativo %EXE_NAME% nao esta na mesma pasta.
    echo Certifique-se de extrair todos os arquivos do ZIP antes de rodar!
    echo.
    pause
    exit /b
)

:: 2. Encerrar instancia anterior (evita "Acesso negado" ao copiar)
echo [+] Preparando o sistema local...
taskkill /f /im "%EXE_NAME%" /t >nul 2>&1
timeout /t 2 /nobreak >nul

:: 3. Criar a pasta do Agente
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 4. Copiar o executavel (com 3 tentativas em caso de lock)
echo [+] Instalando o agente silencioso na maquina...
set RETRIES=0

:retry_copy
copy /y "%EXE_NAME%" "%TARGET_DIR%\%EXE_NAME%" >nul 2>&1
if exist "%TARGET_DIR%\%EXE_NAME%" goto copy_ok

set /a RETRIES+=1
if %RETRIES% GEQ 3 goto copy_fail
echo     Tentativa %RETRIES% falhou, aguardando...
timeout /t 2 /nobreak >nul
goto retry_copy

:copy_fail
color 0C
echo.
echo [ERRO] Nao foi possivel copiar o agente apos 3 tentativas.
echo Possíveis causas:
echo   - Antivirus bloqueando a copia
echo   - Outra instancia do programa ainda travada
echo   - Permissao de pasta negada
echo.
echo Tente fechar programas e rodar novamente.
pause
exit /b

:copy_ok

:: 5. Copiar config.txt se existir na pasta de instalacao
if exist "config.txt" (
    echo [+] Aplicando configuracoes personalizadas...
    copy /y "config.txt" "%TARGET_DIR%\config.txt" >nul 2>&1
)

:: 6. Limpar atalho de versao anterior (nome diferente)
if exist "%STARTUP_DIR%\Wallpaper Corp.lnk" (
    del /f /q "%STARTUP_DIR%\Wallpaper Corp.lnk" >nul 2>&1
)

:: 7. Criar atalho no Startup do Windows
echo [+] Registrando rotina silenciosa de atualizacao automatica...
set VBS_SCRIPT="%temp%\CreateShortcut.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") > %VBS_SCRIPT%
echo sLinkFile = "%STARTUP_DIR%\%SHORTCUT_NAME%" >> %VBS_SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %VBS_SCRIPT%
echo oLink.TargetPath = "%TARGET_DIR%\%EXE_NAME%" >> %VBS_SCRIPT%
echo oLink.WorkingDirectory = "%TARGET_DIR%" >> %VBS_SCRIPT%
echo oLink.Description = "Sincronizador Silencioso do Wallpaper Corporativo" >> %VBS_SCRIPT%
echo oLink.Save >> %VBS_SCRIPT%

cscript /nologo %VBS_SCRIPT%
del %VBS_SCRIPT% >nul 2>&1

:: 8. Verificar se o atalho foi criado
if not exist "%STARTUP_DIR%\%SHORTCUT_NAME%" (
    echo [AVISO] Atalho de inicializacao nao foi criado. O wallpaper funcionara,
    echo         mas nao atualizara automaticamente apos reiniciar o PC.
)

:: 9. Executar o agente pela primeira vez
echo [+] Finalizando integracoes e configuracoes...
start "" "%TARGET_DIR%\%EXE_NAME%"

echo.
echo =================================================================
echo.
echo TUDO PRONTO! O programa corporativo foi ativado com sucesso!
echo O seu fundo de tela mudara sozinho agorinha mesmo :)
echo.
echo Essa tela fechara sozinha em instantes... Tenha um otimo dia!
echo.
echo =================================================================
:: Aguarda 4 segundos e fecha sozinho
timeout /t 4 >nul

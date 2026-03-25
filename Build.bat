@echo off
echo Compilando codigo C# do Wallpaper de forma nativa e sem precisar instalar ferramentas extras...
echo ======================================================================================

:: Buscar o compilador C# nativo do Windows 10/11
set CSC_PATH=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe

if not exist "%CSC_PATH%" (
    set CSC_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe
)

if not exist "%CSC_PATH%" (
    echo [ERROR] Compilador C# nao encontrado (Impossivel). Verifique se este eh um PC com Windows.
    pause
    exit /b
)

:: O parametro /target:winexe eh MAGICO: Significa que o app criado vai rodar TOTALMENTE sem janela de prompt! 
"%CSC_PATH%" /nologo /target:winexe /optimize /out:WallpaperAgent.exe WallpaperAgent.cs

if errorlevel 1 goto erro

echo.
echo SUCESSO!
echo O arquivo "WallpaperAgent.exe" foi compilado perfeitamente!
echo.
echo Agora voce pode executar o "Install.bat" para testar no seu PC!
echo.
goto fim

:erro
echo.
echo Encontramos algum erro no fechamento do app C#, verifique ali em cima!

:fim
pause

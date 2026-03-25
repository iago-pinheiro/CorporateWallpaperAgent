using System;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Threading;

namespace CorporateWallpaper
{
    class Program
    {
        // Import da API do Windows para manipular a Área de Trabalho (Wallpaper)
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

        private const int SPI_SETDESKWALLPAPER = 0x0014;
        private const int SPIF_UPDATEINIFILE = 0x01;
        private const int SPIF_SENDWININICHANGE = 0x02;

        // O LINK ESTÁTICO DO GITHUB PAGES
        private const string WALLPAPER_URL = "https://iago-pinheiro.github.io/wallpaper-download/wallpaper.jpg";

        static void Main(string[] args)
        {
            try
            {
                // Este diretório sempre existe no Windows 10/11: C:\Users\[Usuario]\AppData\Local
                string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string workDir = Path.Combine(localAppData, "CorpWallpaperSystem");
                string localImagePath = Path.Combine(workDir, "wallpaper.jpg");

                if (!Directory.Exists(workDir))
                {
                    Directory.CreateDirectory(workDir);
                }

                string exePath = System.Reflection.Assembly.GetExecutingAssembly().Location;
                string targetExePath = Path.Combine(workDir, "WallpaperAgent.exe");

                // SE FOR EXECUTADO FORA DA PASTA DE DESTINO (EX: DA PASTA DOWNLOADS), FUNCIONA COMO INSTALADOR!
                if (!exePath.Equals(targetExePath, StringComparison.OrdinalIgnoreCase))
                {
                    // Copia o próprio .exe para a pasta do sistema escondida
                    File.Copy(exePath, targetExePath, true);

                    // Cria um atalho na pasta Inicializar (Startup) usando um script VBS temporário (nativamente no Windows)
                    string startupDir = Environment.GetFolderPath(Environment.SpecialFolder.Startup);
                    string shortcutPath = Path.Combine(startupDir, "CorporateWallpaper.lnk");
                    string vbsPath = Path.Combine(Path.GetTempPath(), "CreateShortcut.vbs");
                    
                    string vbsCode = "Set oWS = WScript.CreateObject(\"WScript.Shell\")\r\n" +
                                     "sLinkFile = \"" + shortcutPath + "\"\r\n" +
                                     "Set oLink = oWS.CreateShortcut(sLinkFile)\r\n" +
                                     "oLink.TargetPath = \"" + targetExePath + "\"\r\n" +
                                     "oLink.WorkingDirectory = \"" + workDir + "\"\r\n" +
                                     "oLink.Description = \"Wallpaper Corporativo\"\r\n" +
                                     "oLink.Save";
                    
                    File.WriteAllText(vbsPath, vbsCode);
                    var process = System.Diagnostics.Process.Start("cscript.exe", "/nologo \"" + vbsPath + "\"");
                    process.WaitForExit();
                    File.Delete(vbsPath);

                    // Executa a versão instalada para já aplicar o wallpaper e encerra este instalador
                    System.Diagnostics.Process.Start(targetExePath);
                    return;
                }

                // Garante que apenas uma instância rode por vez (evita vazamento de memória com vários loops)
                bool createdNew;
                using (Mutex mutex = new Mutex(true, "CorporateWallpaperAgentMutex", out createdNew))
                {
                    if (!createdNew)
                    {
                        return; // Já existe um agente rodando
                    }

                    // Loop infinito para atualizar o wallpaper periodicamente
                    while (true)
                    {
                        try
                        {
                            // Download da imagem silenciosamente (Tolerância a faltas de rede embutida via try/catch)
                            // Força o uso do TLS 1.2, necessário para baixar do GitHub Pages
                            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
                            using (WebClient client = new WebClient())
                            {
                                client.Headers.Add("User-Agent", "Mozilla/5.0 CorporateWallpaperAgent/1.0");
                                client.DownloadFile(WALLPAPER_URL, localImagePath);
                            }

                            // Se passou da linha acima, a imagem nova (ou mesma) já foi baixada.
                            // Agora, forçamos o Windows a aplicar a imagem sem precisar de permissões de Administrador.
                            if (File.Exists(localImagePath))
                            {
                                SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, localImagePath, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
                            }
                        }
                        catch (Exception)
                        {
                            // Silenciamos os erros de propósito (falta de rede, etc).
                        }

                        // Aguarda 4 horas antes de tentar atualizar de novo (4 horas = 14400000 ms)
                        Thread.Sleep(TimeSpan.FromHours(4));
                    }
                }
            }
            catch (Exception)
            {
                // Erro geral silencioso
            }
        }
    }
}

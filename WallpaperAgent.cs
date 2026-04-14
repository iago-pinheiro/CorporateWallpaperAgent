using System;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Threading;
using System.Security.Cryptography;

namespace CorporateWallpaper
{
    /// <summary>
    /// WebClient com timeout configurável para evitar travamento em conexões lentas.
    /// </summary>
    class TimedWebClient : WebClient
    {
        public int TimeoutMs { get; set; }

        public TimedWebClient(int timeoutMs = 30000)
        {
            TimeoutMs = timeoutMs;
        }

        protected override WebRequest GetWebRequest(Uri address)
        {
            WebRequest request = base.GetWebRequest(address);
            request.Timeout = TimeoutMs;
            return request;
        }
    }

    class Program
    {
        // Import da API do Windows para manipular a Área de Trabalho (Wallpaper)
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

        private const int SPI_SETDESKWALLPAPER = 0x0014;
        private const int SPIF_UPDATEINIFILE = 0x01;
        private const int SPIF_SENDWININICHANGE = 0x02;

        // URL padrão (fallback caso config.txt não exista)
        private const string DEFAULT_WALLPAPER_URL = "https://iago-pinheiro.github.io/wallpaper-download/wallpaper.jpg";

        // Intervalo entre verificações (em horas)
        private const int CHECK_INTERVAL_HOURS = 4;

        // Máximo de linhas no arquivo de log (rotação automática)
        private const int MAX_LOG_LINES = 100;

        // Versão do agente (para rastreamento)
        private const string AGENT_VERSION = "2.0.0";

        // Caminhos globais (inicializados no Main)
        private static string workDir;
        private static string logPath;

        static void Main(string[] args)
        {
            try
            {
                // Diretório padrão: C:\Users\[Usuario]\AppData\Local\CorpWallpaperSystem
                string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                workDir = Path.Combine(localAppData, "CorpWallpaperSystem");
                logPath = Path.Combine(workDir, "wallpaper_agent.log");

                string localImagePath = Path.Combine(workDir, "wallpaper.jpg");
                string tempImagePath = Path.Combine(workDir, "wallpaper_download.tmp");
                string configPath = Path.Combine(workDir, "config.txt");

                if (!Directory.Exists(workDir))
                {
                    Directory.CreateDirectory(workDir);
                }

                Log("=== Agente iniciado (v" + AGENT_VERSION + ") ===");

                // Garante que apenas uma instância rode por vez
                bool createdNew;
                using (Mutex mutex = new Mutex(true, "CorporateWallpaperAgentMutex", out createdNew))
                {
                    if (!createdNew)
                    {
                        Log("Outra instancia ja esta rodando. Encerrando esta.");
                        return;
                    }

                    // Loop infinito para atualizar o wallpaper periodicamente
                    while (true)
                    {
                        try
                        {
                            // Ler URL do config.txt (ou usar fallback hardcoded)
                            string wallpaperUrl = LoadConfigUrl(configPath);
                            Log("Verificando wallpaper em: " + wallpaperUrl);

                            // Habilitar TLS 1.2 + TLS 1.3 para compatibilidade futura
                            ServicePointManager.SecurityProtocol =
                                (SecurityProtocolType)3072 |   // TLS 1.2
                                (SecurityProtocolType)12288;   // TLS 1.3

                            // Download para arquivo temporário (nunca sobrescreve o wallpaper diretamente)
                            using (TimedWebClient client = new TimedWebClient(30000))
                            {
                                // Herdar proxy do sistema (essencial em ambientes corporativos)
                                client.Proxy = WebRequest.GetSystemWebProxy();
                                client.Proxy.Credentials = CredentialCache.DefaultCredentials;
                                client.Headers.Add("User-Agent", "Mozilla/5.0 CorporateWallpaperAgent/" + AGENT_VERSION);

                                client.DownloadFile(wallpaperUrl, tempImagePath);
                            }

                            // Validar: arquivo deve ser JPEG válido (magic bytes: FF D8 FF)
                            if (!IsValidJpeg(tempImagePath))
                            {
                                Log("AVISO: Arquivo baixado nao e uma imagem JPEG valida. Ignorando.");
                                SafeDelete(tempImagePath);
                                goto waitAndRetry;
                            }

                            // Comparar hash para evitar re-aplicar o mesmo wallpaper
                            if (FilesAreEqual(tempImagePath, localImagePath))
                            {
                                Log("Wallpaper verificado. Sem alteracoes.");
                                SafeDelete(tempImagePath);
                                goto waitAndRetry;
                            }

                            // Tudo validado: substituir o wallpaper antigo pelo novo
                            File.Copy(tempImagePath, localImagePath, true);
                            SafeDelete(tempImagePath);

                            // Aplicar como papel de parede do Windows
                            if (File.Exists(localImagePath))
                            {
                                int result = SystemParametersInfo(
                                    SPI_SETDESKWALLPAPER, 0, localImagePath,
                                    SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
                                );

                                if (result != 0)
                                {
                                    Log("Wallpaper atualizado com sucesso.");
                                }
                                else
                                {
                                    Log("AVISO: SystemParametersInfo retornou 0. Wallpaper pode nao ter sido aplicado.");
                                }
                            }
                        }
                        catch (WebException ex)
                        {
                            Log("Erro de rede: " + ex.Message);
                            SafeDelete(tempImagePath);
                        }
                        catch (Exception ex)
                        {
                            Log("Erro no ciclo: " + ex.Message);
                            SafeDelete(tempImagePath);
                        }

                        waitAndRetry:
                        Thread.Sleep(TimeSpan.FromHours(CHECK_INTERVAL_HOURS));
                    }
                }
            }
            catch (Exception ex)
            {
                try { Log("Erro fatal: " + ex.Message); } catch { }
            }
        }

        /// <summary>
        /// Lê a URL do wallpaper a partir do config.txt.
        /// Formato esperado: url=https://exemplo.com/wallpaper.jpg
        /// Se o arquivo não existir ou não tiver URL válida, retorna a URL padrão.
        /// </summary>
        static string LoadConfigUrl(string configPath)
        {
            try
            {
                if (File.Exists(configPath))
                {
                    string[] lines = File.ReadAllLines(configPath);
                    foreach (string line in lines)
                    {
                        string trimmed = line.Trim();

                        // Ignorar comentários e linhas vazias
                        if (string.IsNullOrEmpty(trimmed) || trimmed.StartsWith("#"))
                            continue;

                        if (trimmed.StartsWith("url=", StringComparison.OrdinalIgnoreCase))
                        {
                            string url = trimmed.Substring(4).Trim();
                            if (!string.IsNullOrEmpty(url) && url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                            {
                                return url;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Log("Aviso: Erro ao ler config.txt: " + ex.Message);
            }

            return DEFAULT_WALLPAPER_URL;
        }

        /// <summary>
        /// Verifica se o arquivo é um JPEG válido checando os magic bytes (FF D8 FF).
        /// </summary>
        static bool IsValidJpeg(string filePath)
        {
            try
            {
                FileInfo fi = new FileInfo(filePath);
                if (fi.Length < 3) return false;

                using (FileStream fs = new FileStream(filePath, FileMode.Open, FileAccess.Read))
                {
                    byte[] header = new byte[3];
                    fs.Read(header, 0, 3);
                    return header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF;
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Compara dois arquivos por hash MD5 para detectar se houve mudança.
        /// </summary>
        static bool FilesAreEqual(string path1, string path2)
        {
            if (!File.Exists(path1) || !File.Exists(path2))
                return false;

            try
            {
                byte[] hash1, hash2;

                using (MD5 md5 = MD5.Create())
                using (FileStream stream = File.OpenRead(path1))
                {
                    hash1 = md5.ComputeHash(stream);
                }

                using (MD5 md5 = MD5.Create())
                using (FileStream stream = File.OpenRead(path2))
                {
                    hash2 = md5.ComputeHash(stream);
                }

                if (hash1.Length != hash2.Length) return false;

                for (int i = 0; i < hash1.Length; i++)
                {
                    if (hash1[i] != hash2[i]) return false;
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Deleta um arquivo de forma segura (ignora erros).
        /// </summary>
        static void SafeDelete(string path)
        {
            try
            {
                if (File.Exists(path))
                    File.Delete(path);
            }
            catch { }
        }

        /// <summary>
        /// Registra uma mensagem no log com timestamp.
        /// Faz rotação automática mantendo apenas as últimas MAX_LOG_LINES linhas.
        /// </summary>
        static void Log(string message)
        {
            try
            {
                string logLine = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " | " + message;
                File.AppendAllText(logPath, logLine + Environment.NewLine);

                // Rotação: manter apenas as últimas N linhas
                if (File.Exists(logPath))
                {
                    string[] lines = File.ReadAllLines(logPath);
                    if (lines.Length > MAX_LOG_LINES)
                    {
                        string[] trimmed = new string[MAX_LOG_LINES];
                        Array.Copy(lines, lines.Length - MAX_LOG_LINES, trimmed, 0, MAX_LOG_LINES);
                        File.WriteAllLines(logPath, trimmed);
                    }
                }
            }
            catch
            {
                // Falha no log não é crítica
            }
        }
    }
}

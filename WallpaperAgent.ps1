# =============================================================
# WallpaperAgent.ps1 - Corporate Wallpaper Agent v3.0
# Atualiza o papel de parede corporativo silenciosamente.
# =============================================================

$version          = "3.0.0"
$checkIntervalHrs = 4
$maxLogLines      = 100

$workDir        = Join-Path $env:LOCALAPPDATA "CorpWallpaperSystem"
$logPath        = Join-Path $workDir "wallpaper_agent.log"
$localImage     = Join-Path $workDir "wallpaper.jpg"
$tempImage      = Join-Path $workDir "wallpaper_download.tmp"
$configPath     = Join-Path $workDir "config.txt"
$defaultUrl     = "https://iago-pinheiro.github.io/wallpaper-download/wallpaper.jpg"

if (-not (Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force | Out-Null }

# --- Helpers ---

function Write-Log($msg) {
    try {
        Add-Content $logPath "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $msg" -Encoding UTF8
        $lines = Get-Content $logPath -ErrorAction SilentlyContinue
        if ($lines.Count -gt $maxLogLines) {
            $lines | Select-Object -Last $maxLogLines | Set-Content $logPath -Encoding UTF8
        }
    } catch {}
}

function Get-WallpaperUrl {
    try {
        if (Test-Path $configPath) {
            foreach ($line in (Get-Content $configPath)) {
                $t = $line.Trim()
                if ($t -like '#*' -or $t -eq '') { continue }
                if ($t -match '^url=(.+)$') {
                    $url = $matches[1].Trim()
                    if ($url -like 'http*') { return $url }
                }
            }
        }
    } catch { Write-Log "Aviso: Erro ao ler config.txt: $_" }
    return $defaultUrl
}

function Test-ImageValid($path) {
    try {
        $b = [IO.File]::ReadAllBytes($path)
        if ($b.Length -lt 8) { return $false }
        $jpg = ($b[0] -eq 0xFF -and $b[1] -eq 0xD8 -and $b[2] -eq 0xFF)
        $png = ($b[0] -eq 0x89 -and $b[1] -eq 0x50 -and $b[2] -eq 0x4E -and $b[3] -eq 0x47)
        return ($jpg -or $png)
    } catch { return $false }
}

function Get-MD5($path) {
    try {
        $md5 = [Security.Cryptography.MD5]::Create()
        $s   = [IO.File]::OpenRead($path)
        $h   = [BitConverter]::ToString($md5.ComputeHash($s))
        $s.Close(); return $h
    } catch { return "" }
}

function Set-DesktopWallpaper($path) {
    try {
        Add-Type -TypeDefinition @"
using System; using System.Runtime.InteropServices;
public class WP {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int a, int b, string c, int d);
}
"@ -ErrorAction SilentlyContinue
        return ([WP]::SystemParametersInfo(0x14, 0, $path, 0x03) -ne 0)
    } catch { Write-Log "Erro ao aplicar wallpaper: $_"; return $false }
}

# --- Loop Principal ---

Write-Log "=== Agente iniciado (v$version) ==="

while ($true) {
    try {
        $url = Get-WallpaperUrl
        Write-Log "Verificando wallpaper em: $url"

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $wc = New-Object Net.WebClient
        $wc.Proxy = [Net.WebRequest]::GetSystemWebProxy()
        $wc.Proxy.Credentials = [Net.CredentialCache]::DefaultCredentials
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 CorporateWallpaperAgent/$version")
        $wc.DownloadFile($url, $tempImage)
        $wc.Dispose()

        if (-not (Test-ImageValid $tempImage)) {
            Write-Log "AVISO: Arquivo baixado nao e uma imagem JPEG/PNG valida. Ignorando."
            Remove-Item $tempImage -Force -ErrorAction SilentlyContinue
        } else {
            if ((Get-MD5 $tempImage) -eq (Get-MD5 $localImage) -and (Get-MD5 $tempImage) -ne "") {
                Write-Log "Wallpaper verificado. Sem alteracoes."
                Remove-Item $tempImage -Force -ErrorAction SilentlyContinue
            } else {
                Copy-Item $tempImage $localImage -Force
                Remove-Item $tempImage -Force -ErrorAction SilentlyContinue
                if (Set-DesktopWallpaper $localImage) {
                    Write-Log "Wallpaper atualizado com sucesso."
                } else {
                    Write-Log "AVISO: Wallpaper pode nao ter sido aplicado."
                }
            }
        }
    } catch {
        Write-Log "Erro no ciclo: $_"
        Remove-Item $tempImage -Force -ErrorAction SilentlyContinue
    }

    Start-Sleep -Seconds ($checkIntervalHrs * 3600)
}

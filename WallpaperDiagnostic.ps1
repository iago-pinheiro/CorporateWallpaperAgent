# =============================================================
# WallpaperDiagnostic.ps1 - Ferramenta de Troubleshooting
# Uso: Navegue ate a pasta extraida do ZIP e execute:
#    powershell -NoProfile -ExecutionPolicy Bypass -File "WallpaperDiagnostic.ps1"
# Ou clique com botao direito e "Executar com PowerShell"
#
# Gera um relatorio em: %TEMP%\CorpWallpaper_Diagnostic.txt
# Envie esse arquivo para o TI.
# =============================================================

$outputPath = Join-Path $env:TEMP "CorpWallpaper_Diagnostic.txt"
$targetDir  = Join-Path $env:LOCALAPPDATA "CorpWallpaperSystem"

function Write-Diag($msg) {
    $line = "$(Get-Date -Format 'HH:mm:ss') | $msg"
    Write-Host $line
    Add-Content $outputPath $line
}

# Clean start
Remove-Item $outputPath -ErrorAction SilentlyContinue

Write-Diag "========================================================"
Write-Diag " CorporateWallpaperAgent - Diagnostic Report"
Write-Diag " Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Diag " Usuario: $env:USERNAME"
Write-Diag " Computador: $env:COMPUTERNAME"
Write-Diag " OS: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)"
Write-Diag "========================================================"
Write-Diag ""

# ====================================
# 1. Pasta de instalacao
# ====================================
Write-Diag "[1] Pasta de instalacao: $targetDir"
if (Test-Path $targetDir) {
    Write-Diag "  PASTA: EXISTE"
    $files = Get-ChildItem $targetDir -Force
    if ($files.Count -eq 0) {
        Write-Diag "  ARQUIVOS: (vazia)"
    } else {
        Write-Diag "  ARQUIVOS:"
        foreach ($f in $files) {
            $size = if ($f.Length -gt 0) { "$($f.Length) bytes" } else { "0 bytes" }
            Write-Diag "    $($f.Name) -> $size (mod: $($f.LastWriteTime))"
        }
    }
    # Permissoes (icacls)
    try {
        $perms = & icacls $targetDir 2>&1 | Out-String
        Write-Diag "  PERMISSOES:"
        $perms -split "`r`n" | Where-Object { $_ -match '^(.*?)\s' } | ForEach-Object {
            Write-Diag "    $_"
        }
    } catch {
        Write-Diag "  PERMISSOES: (nao foi possivel ler)"
    }
} else {
    Write-Diag "  PASTA: NAO EXISTE (instalacao nunca foi concluida)"
}
Write-Diag ""

# ====================================
# 2. Arquivos na pasta atual (onde o diagnostic esta rodando)
# ====================================
Write-Diag "[2] Pasta atual (origem do diagnostic): $PWD"
$srcFiles = Get-ChildItem -Path $PWD -Force | Where-Object { -not $_.PSIsContainer }
foreach ($f in $srcFiles) {
    $size = if ($f.Length -gt 0) { "$($f.Length) bytes" } else { "0 bytes" }
    Write-Diag "    $($f.Name) ($size)"
}
Write-Diag ""

# ====================================
# 3. Registry (HKCU\Run)
# ====================================
Write-Diag "[3] Registro de inicializacao (HKCU\\Run)"
try {
    $reg = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CorporateWallpaperAgent" -ErrorAction Stop
    Write-Diag "  CorporateWallpaperAgent = $($reg.CorporateWallpaperAgent)"
} catch {
    Write-Diag "  CorporateWallpaperAgent: (AUSENTE)"
}
Write-Diag ""

# ====================================
# 4. PowerShell ExecutionPolicy
# ====================================
Write-Diag "[4] PowerShell ExecutionPolicy"
try {
    $ep = Get-ExecutionPolicy -Scope CurrentUser
    Write-Diag "  CurrentUser: $ep"
    $epM = Get-ExecutionPolicy -Scope MachinePolicy -ErrorAction SilentlyContinue
    if ($epM) { Write-Diag "  MachinePolicy: $epM" }
    $epU = Get-ExecutionPolicy -Scope UserPolicy -ErrorAction SilentlyContinue
    if ($epU) { Write-Diag "  UserPolicy: $epU" }
} catch {
    Write-Diag "  (nao foi possivel ler)"
}
Write-Diag ""

# ====================================
# 5. Windows Defender Status
# ====================================
Write-Diag "[5] Windows Defender / Antivirus"
try {
    $mp = Get-MpComputerStatus -ErrorAction Stop
    Write-Diag "  AntivirusEnabled: $($mp.AntivirusEnabled)"
    Write-Diag "  RealTimeProtectionEnabled: $($mp.RealTimeProtectionEnabled)"
    Write-Diag "  AMServiceEnabled: $($mp.AMServiceEnabled)"
    Write-Diag "  DefenderSignaturesOutOfDate: $($mp.AntivirusSignatureAge)"
} catch {
    Write-Diag "  (nao foi possivel acessar - pode ser AV corporativo diferente)"
}
Write-Diag ""

# ====================================
# 6. Controlled Folder Access
# ====================================
Write-Diag "[6] Controlled Folder Access (Ransomware Protection)"
try {
    $cfa = Get-MpPreference -ErrorAction Stop
    Write-Diag "  EnableControlledFolderAccess: $($cfa.EnableControlledFolderAccess)"
    Write-Diag "  ControlledFolderAccessProtectedFolders:"
    $cfa.ControlledFolderAccessProtectedFolders | ForEach-Object { Write-Diag "    $_" }
    Write-Diag "  ControlledFolderAccessAllowedApplications:"
    $cfa.ControlledFolderAccessAllowedApplications | ForEach-Object { Write-Diag "    $_" }
} catch {
    Write-Diag "  (nao foi possivel acessar)"
}
Write-Diag ""

# ====================================
# 7. Processos rodando
# ====================================
Write-Diag "[7] Processos relacionados"
$procs = Get-Process | Where-Object {
    $_.ProcessName -match 'powershell|wscript|cscript|WallpaperAgent' -and
    ($_.CommandLine -match 'WallpaperAgent|WallpaperLauncher' -or $_.ProcessName -eq 'wscript')
}
if ($procs) {
    foreach ($p in $procs) {
        Write-Diag "  PID $($p.Id): $($p.ProcessName) - $($p.CommandLine)"
    }
} else {
    Write-Diag "  Nenhum processo relacionado encontrado"
}
Write-Diag ""

# ====================================
# 8. Log do agente
# ====================================
Write-Diag "[8] Log do agente (wallpaper_agent.log)"
$logPath = Join-Path $targetDir "wallpaper_agent.log"
if (Test-Path $logPath) {
    Write-Diag "  ARQUIVO: EXISTE ($((Get-Item $logPath).Length) bytes)"
    Write-Diag "  ULTIMAS 20 LINHAS:"
    Get-Content $logPath -Tail 20 | ForEach-Object { Write-Diag "    $_" }
} else {
    Write-Diag "  ARQUIVO: NAO EXISTE"
}
Write-Diag ""

# ====================================
# 9. Install log
# ====================================
Write-Diag "[9] Log de instalacao"
$installLogs = Get-ChildItem "$env:TEMP\CorpWallpaper_Install_*.log" -ErrorAction SilentlyContinue
if ($installLogs) {
    foreach ($log in $installLogs) {
        Write-Diag "  $($log.Name) ($($log.Length) bytes)"
        Write-Diag "  CONTEUDO:"
        Get-Content $log.FullName | ForEach-Object { Write-Diag "    $_" }
    }
} else {
    Write-Diag "  Nenhum log de instalacao encontrado em %TEMP%"
}
Write-Diag ""

# ====================================
# 10. OneDrive / Path Issues
# ====================================
Write-Diag "[10] Variaveis de ambiente e paths"
Write-Diag "  LOCALAPPDATA: $env:LOCALAPPDATA"
Write-Diag "  TEMP: $env:TEMP"
Write-Diag "  PATH (primeiros 200 chars): $($env:Path.Substring(0, [Math]::Min(200, $env:Path.Length)))"
try {
    $knownFolder = [Environment]::GetFolderPath('Desktop')
    Write-Diag "  Desktop: $knownFolder"
    if ($knownFolder -match 'OneDrive') {
        Write-Diag "  !!! ATENCAO: Desktop redirecionado para OneDrive!"
    }
} catch {
    Write-Diag "  Desktop: (nao foi possivel determinar)"
}
Write-Diag ""

# ====================================
# 11. Disk space
# ====================================
Write-Diag "[11] Espaco em disco"
try {
    $drive = (Get-Item $env:LOCALAPPDATA).PSDrive
    Write-Diag "  Unidade: $($drive.Name)"
    Write-Diag "  Livre: $([math]::Round($drive.Free / 1MB, 1)) MB"
    Write-Diag "  Total: $([math]::Round(($drive.Used + $drive.Free) / 1MB, 1)) MB"
} catch {
    Write-Diag "  (nao foi possivel ler)"
}
Write-Diag ""

# ====================================
# 12. Resumo
# ====================================
Write-Diag "========================================================"
Write-Diag " RESUMO"
Write-Diag "========================================================"

if (Test-Path $targetDir) {
    $allFiles = @("WallpaperAgent.ps1", "WallpaperLauncher.vbs", "config.txt")
    $missingFiles = $allFiles | Where-Object { -not (Test-Path (Join-Path $targetDir $_)) }
    if ($missingFiles.Count -eq 0) {
        Write-Diag "  INSTALACAO: PARECE COMPLETA"
    } else {
        Write-Diag "  INSTALACAO: INCOMPLETA - faltam: $($missingFiles -join ', ')"
    }
} else {
    Write-Diag "  INSTALACAO: NAO ENCONTRADA"
}

try {
    $reg = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "CorporateWallpaperAgent" -ErrorAction SilentlyContinue
    if ($reg) { Write-Diag "  REGISTRO: PRESENTE" } else { Write-Diag "  REGISTRO: AUSENTE" }
} catch { Write-Diag "  REGISTRO: AUSENTE" }

Write-Diag ""
Write-Diag "Relatorio salvo em: $outputPath"
Write-Diag "Envie este arquivo para o TI."
Write-Diag "========================================================"

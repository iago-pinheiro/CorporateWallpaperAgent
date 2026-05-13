' WallpaperLauncher.vbs
' Lanca o WallpaperAgent.ps1 de forma 100% invisivel (sem janela preta).
' O WScript.Shell com parametro 0 suprime completamente a janela,
' contornando o Windows Terminal que ignora -WindowStyle Hidden.
Dim fso, shell, scriptPath
Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\WallpaperAgent.ps1"

shell.Run "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & scriptPath & """", 0, False

Set shell = Nothing
Set fso   = Nothing

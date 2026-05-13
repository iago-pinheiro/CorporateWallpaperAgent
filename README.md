# Corporate Wallpaper Agent

Agente silencioso para atualizacao automatizada do papel de parede corporativo em Windows 10/11 — **sem necessidade de privilegios de Administrador**.

---

## Como funciona

```
[TI sobe imagem no servidor]
         ↓
[Servidor com link publico direto (ex: AWS S3)]
         ↓
[WallpaperAgent.ps1 — roda invisivel em cada maquina]
         ↓
[Papel de parede atualizado automaticamente]
```

O agente e instalado uma unica vez por colaborador. A partir dai:
- **Quando o PC liga**: o agente inicia automaticamente e verifica se ha um wallpaper novo
- **A cada 2 horas**: verifica novamente enquanto o PC estiver ligado
- **Quando o RH troca a imagem no servidor**: em ate 2 horas todos os PCs atualizam

---

## =======================
## PARA O TI (IAGO)
## =======================

### Fluxo de distribuicao

```
1. Rode Build.bat aqui no seu PC
        ↓
2. Envie o WallpaperCorporativo.zip para a colaboradora
        ↓
3. Ela extrai o ZIP e executa o instalador
        ↓
4. Se der problema: peca para ela rodar o diagnostico
        ↓
5. Com o diagnostico em maos, analise a causa raiz
```

### Passo 1 — Configurar a URL

Crie ou edite o `config.txt` na raiz do projeto:

```
url=https://seu-servidor.com/pasta/wallpaper.jpg
```

### Passo 2 — Gerar o ZIP

De dois cliques em **`Build.bat`**. Ele gera o `WallpaperCorporativo.zip`.

### Passo 3 — Enviar para a colaboradora

Mande o ZIP por email, Teams, ou pasta compartilhada.

### Passo 4 — Se der problema (instalacao incompleta)

Peca para a colaboradora rodar o diagnostico:

```
Clique com botao direito no WallpaperDiagnostic.ps1 → "Executar com PowerShell"
```

Ela vai gerar o arquivo `%TEMP%\CorpWallpaper_Diagnostic.txt`. Peca para te enviar.

Com esse arquivo, voce descobre rapidinho a causa:
- Log passo a passo da instalacao
- Se o antivirus/Defender deletou os arquivos
- Se Controlled Folder Access bloqueou
- Status do registro e permissões da pasta

### Passo 5 — Trocar o wallpaper no futuro

1. Suba nova imagem no servidor com o mesmo nome
2. Em ate 2 horas todos os PCs atualizam
3. Para aplicar na hora: peca para a colaboradora rodar o instalador de novo

---

## =======================
## PARA A COLABORADORA
## =======================

### Instalacao (se for a primeira vez)

```
1. Clique com BOTAO DIREITO no "WallpaperCorporativo.zip"
2. Escolha "Extrair tudo..." (ou "Extract all...")
3. Escolha uma pasta (ex: Area de Trabalho) e clique em "Extrair"
4. Dentro da pasta que apareceu, de DOIS CLIQUES em:
      "SOMENTE CLIQUE AQUI PARA INSTALAR.bat"
5. Uma janela azul abre e fecha sozinha em alguns segundos
      → O papel de parede ja vai mudar!
```

> **Importante:** Nao rode o instalador de dentro do ZIP. Extraia primeiro!

### Se der problema (papel de parede nao mudou)

**Nao se preocupe.** Faca isso:

```
1. Dentro da pasta extraida, procure o arquivo "WallpaperDiagnostic.ps1"
2. Clique com BOTAO DIREITO nele → escolha "Executar com PowerShell"
3. Uma janela preta vai aparecer com varias informacoes
4. Quando terminar, vai aparecer o caminho de um arquivo gerado
5. Me envie esse arquivo (por email ou Teams)
```

Com esse arquivo eu descubro rapidinho o que houve e resolvo.

### O que acontece depois que instala?

- O programa e **invisivel** — sem icone, sem janela
- Inicia **automaticamente com o Windows**
- Atualiza o wallpaper **a cada 2 horas**
- Se estiver **sem internet**, tenta de novo depois

### Onde fica instalado?

```
C:\Usuarios\[SeuUsuario]\AppData\Local\CorpWallpaperSystem\
```

> Pode apagar o ZIP e a pasta extraida depois que instalar.

### Desinstalar (se quiser remover)

De dois cliques em **`Uninstall.bat`** dentro da pasta.

---

## 🛡️ Requisitos e Compatibilidade

| Item | Requisito |
|---|---|
| Sistema Operacional | Windows 10 / Windows 11 |
| Privilegios | Nao requer Administrador |
| Runtime | Nativo do Windows (PowerShell ja incluso) |
| Antivirus | Sem conflito (nao usa .exe) |
| Proxy corporativo | Usa configuracao do sistema automaticamente |

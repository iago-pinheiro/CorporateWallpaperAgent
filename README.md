# Corporate Wallpaper Agent

Agente silencioso para atualização automatizada do papel de parede corporativo em Windows 10/11 — **sem necessidade de privilégios de Administrador**.

---

## Como funciona

```
[TI sobe imagem no servidor]
         ↓
[Servidor com link público direto (ex: AWS S3)]
         ↓
[WallpaperAgent.ps1 — roda invisível em cada máquina]
         ↓
[Papel de parede atualizado automaticamente]
```

O agente é instalado uma única vez por colaborador. A partir daí:
- **Quando o PC liga**: o agente inicia automaticamente e verifica se há um wallpaper novo
- **A cada 2 horas**: verifica novamente enquanto o PC estiver ligado
- **Quando o RH troca a imagem no servidor**: em até 2 horas todos os PCs atualizam

---

## Arquivos do Projeto

| Arquivo | Para quem | Função |
|---|---|---|
| `WallpaperAgent.ps1` | TI | Agente principal — faz o download e aplica o wallpaper |
| `WallpaperLauncher.vbs` | TI | Lança o agente de forma 100% invisível (sem janela preta) |
| `Install.bat` | TI | Script de instalação |
| `Uninstall.bat` | TI / Colaborador | Remove tudo do computador |
| `Build.bat` | TI | Gera o ZIP de distribuição |
| `config.txt` | TI (não sobe pro GitHub) | Define a URL do wallpaper |

---

## 🔧 Guia para o TI

### Passo 1 — Configurar a URL do wallpaper

Crie (ou edite) o arquivo `config.txt` na pasta do projeto:

```
# URL pública do wallpaper (qualquer servidor com link direto)
url=https://seu-servidor.com/pasta/wallpaper.jpg
```

> O agente baixa a imagem desta URL. O servidor precisa servir o arquivo diretamente (sem login, sem redirecionamento de página).
> Para trocar o wallpaper no futuro, basta substituir a imagem no servidor pelo mesmo nome. Em até 4 horas todos os PCs atualizam.

### Passo 2 — Gerar o pacote de distribuição

1. Dê duplo clique em **`Build.bat`**
2. Ele gera automaticamente o **`WallpaperCorporativo.zip`** pronto para distribuição

O ZIP conterá:
```
📁 WallpaperCorporativo.zip
 ├── SOMENTE CLIQUE AQUI PARA INSTALAR.bat
 ├── WallpaperAgent.ps1
 ├── WallpaperLauncher.vbs
 ├── config.txt
 └── Uninstall.bat
```

### Passo 3 — Distribuir

Envie o ZIP por e-mail, intranet ou compartilhamento de rede.

> ⚠️ **Nunca distribuir sem o `config.txt`** — sem ele o agente não sabe onde buscar o wallpaper.

### Passo 4 — Trocar o wallpaper no futuro

1. Faça upload da nova imagem no servidor **com o mesmo nome de arquivo**
2. Aguarde até 4 horas — todos os PCs atualizam automaticamente
3. Para aplicar imediatamente em um PC: peça para o colaborador rodar o instalador novamente

---

## 👤 Guia para o Colaborador

### Instalação

1. **Extraia** o ZIP em uma pasta nova na Área de Trabalho
   > ⚠️ Não rode o instalador de dentro do ZIP. Extraia primeiro!
2. Dê duplo clique em **`SOMENTE CLIQUE AQUI PARA INSTALAR.bat`**
3. Uma tela azul aparecerá por alguns segundos e fechará sozinha
4. O papel de parede mudará automaticamente — **pronto!**

### O que acontece depois?

- O programa é **invisível** — sem ícone, sem janela, sem barra de tarefas
- Inicia **automaticamente com o Windows**
- Atualiza o wallpaper **a cada 4 horas** sem nenhuma ação do colaborador
- Se estiver **sem internet**, tenta novamente na próxima vez

### Onde fica instalado?

```
C:\Users\[SeuUsuario]\AppData\Local\CorpWallpaperSystem\
```

> Pode apagar o ZIP e a pasta extraída após instalar. O programa já está salvo no lugar certo.

### Desinstalação

1. Dê duplo clique em **`Uninstall.bat`**
2. Pronto — tudo é removido, o wallpaper atual **não é alterado**

---

## 🔍 Verificando se está funcionando (TI)

Após instalar, verifique o log em:

```
%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log
```

**Log saudável:**
```
2026-05-05 10:44:00 | === Agente iniciado (v3.0.0) ===
2026-05-05 10:44:01 | Verificando wallpaper em: https://...
2026-05-05 10:44:03 | Wallpaper atualizado com sucesso.
2026-05-05 14:44:03 | Verificando wallpaper em: https://...
2026-05-05 14:44:04 | Wallpaper verificado. Sem alteracoes.
```

**Verificar processo rodando:**

Gerenciador de Tarefas → aba **Detalhes** → procurar `powershell.exe`

---

## 🛡️ Requisitos e Compatibilidade

| Item | Requisito |
|---|---|
| Sistema Operacional | Windows 10 / Windows 11 |
| Privilégios | ❌ Não requer Administrador |
| .NET / Runtime | ✅ Nativo do Windows (PowerShell já incluído) |
| Antivírus | ✅ Sem conflito (usa PowerShell nativo, sem .exe externo) |
| Proxy corporativo | ✅ Usa as configurações de proxy do sistema automaticamente |

---

## 🐛 Troubleshooting

| Problema | Causa provável | Solução |
|---|---|---|
| Wallpaper não mudou após instalar | Agente ainda iniciando ou sem internet | Aguarde 30 segundos e verifique o log |
| Extração do ZIP pede admin | Pasta com o mesmo nome já existe de outro usuário | Delete a pasta antiga e extraia novamente em local novo |
| Log vazio ou inexistente | Script bloqueado pelo Windows | O instalador já executa `Unblock-File` automaticamente. Se persistir, peça ao TI para verificar política de execução |
| Wallpaper para de atualizar | Processo foi encerrado | Reinstalar ou reiniciar o PC resolve |
| Proxy corporativo bloqueando | Servidor não acessível pela rede da empresa | Verifique se a URL do config.txt é acessível pelo navegador do colaborador |

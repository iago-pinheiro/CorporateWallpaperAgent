# Corporate Wallpaper Agent

Agente silencioso em C# para atualização automatizada do papel de parede corporativo em Windows 10/11, voltado para campanhas de endomarketing e avisos de TI/RH — **sem necessidade de privilégios de Administrador**.

---

## Funcionalidades

- **Sem Admin**: Opera 100% no espaço do usuário (`AppData\Local`). Nenhum UAC, nenhuma senha.
- **Invisível**: Compilado como `winexe` — roda sem janela preta, sem ícone na barra de tarefas.
- **Resiliente**: Tolera quedas de rede, proxy corporativo, e reconexões sem erros visíveis.
- **Atualização Automática**: Checa a cada 4 horas se o wallpaper mudou (comparando hash MD5).
- **Sem conflitos**: Mutex impede execução duplicada.
- **Log interno**: Registra atividades em `wallpaper_agent.log` com rotação automática (últimas 100 linhas).
- **Validação de imagem**: Só aplica o wallpaper se o arquivo baixado for um JPEG válido.

---

## Arquivos do Projeto

| Arquivo | Para quem | Função |
|---|---|---|
| `WallpaperAgent.cs` | TI / Dev | Código-fonte C# do agente |
| `Build.bat` | TI / Dev | Compila o `.cs` em `.exe` usando o compilador nativo do Windows |
| `Install.bat` | Colaborador | Instalador amigável — duplo clique e pronto |
| `Uninstall.bat` | Colaborador / TI | Remove tudo do computador |
| `config.txt` | TI (opcional) | Personaliza a URL do wallpaper sem recompilar |

---

## 🔧 Guia para o TI (Preparação e Distribuição)

### Passo 1: Configurar a URL do Wallpaper

A URL padrão está em `WallpaperAgent.cs`:

```csharp
private const string DEFAULT_WALLPAPER_URL = "https://iago-pinheiro.github.io/wallpaper-download/wallpaper.jpg";
```

**Opção A** — Alterar no código e recompilar (permanente).

**Opção B** — Criar um `config.txt` para distribuir junto (não precisa recompilar):

```ini
# URL do wallpaper corporativo
url=https://seu-servidor.com/wallpaper.jpg
```

### Passo 2: Compilar

1. Dê duplo clique em **`Build.bat`**
2. Ele usa o compilador C# nativo do Windows (`csc.exe` do .NET Framework 4.x) — não precisa instalar nada
3. Se tudo der certo, aparece `SUCESSO!` e o arquivo `WallpaperAgent.exe` é gerado

### Passo 3: Testar no seu PC

1. Rode **`Install.bat`** com duplo clique
2. A tela mostrará o progresso e fechará sozinha
3. Verifique se o papel de parede mudou
4. Para conferir os logs: abra `%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log`

```
Caminho completo (exemplo):
C:\Users\SeuUsuario\AppData\Local\CorpWallpaperSystem\wallpaper_agent.log
```

### Passo 4: Distribuir para os Colaboradores

Monte um **ZIP** contendo:

```
📁 WallpaperCorporativo.zip
├── Install.bat
├── WallpaperAgent.exe
└── config.txt          ← (opcional, se quiser trocar a URL)
```

Envie por e-mail, intranet, pendrive ou compartilhamento de rede.

> **Dica**: O `Uninstall.bat` e os arquivos `.cs` / `Build.bat` são internos do TI — **não** envie para os colaboradores.

### Passo 5: Atualizar o Wallpaper no Futuro

1. Suba a nova imagem `wallpaper.jpg` no servidor/GitHub Pages configurado
2. Em até **4 horas**, todos os PCs com o agente sincronizam automaticamente
3. Para aplicar imediatamente: peça para o colaborador **reiniciar o PC** ou rodar o `Install.bat` novamente

---

## 👤 Guia para o Colaborador (Usuário Final)

### Instalação

1. **Extraia** o ZIP recebido para qualquer pasta (ex: Área de Trabalho)
2. Dê **duplo clique** em `Install.bat`
3. Uma tela azul aparecerá mostrando o progresso:

```
=================================================================
      BEM-VINDO: AGENTE DE PAPEL DE PAREDE
=================================================================

Ola! Estamos configurando o seu novo papel de parede dinamico.
Este processo e 100% seguro e nao pedira senhas.

[+] Preparando o sistema local...
[+] Instalando o agente silencioso na maquina...
[+] Registrando rotina silenciosa de atualizacao automatica...
[+] Finalizando integracoes e configuracoes...

TUDO PRONTO! O programa corporativo foi ativado com sucesso!
```

4. A tela fecha sozinha em 4 segundos
5. Seu papel de parede será atualizado em instantes — **pronto!**

> **Importante**: Você precisa **extrair os arquivos do ZIP primeiro**. Não rode o `Install.bat` de dentro do ZIP.

### O que acontece depois?

- O wallpaper será atualizado **automaticamente** a cada poucas horas
- O programa é **invisível** — não aparece na barra de tarefas nem consome memória perceptível
- Funciona mesmo se o notebook for **desligado e religado** (inicia com o Windows)
- Se estiver **sem internet** (num avião, por exemplo), nada acontece — tenta novamente mais tarde

### Desinstalação

1. Dê **duplo clique** em `Uninstall.bat` (peça ao TI se não tiver o arquivo)
2. Pronto — o agente é removido completamente, sem deixar rastros
3. Seu papel de parede atual **não será alterado** após a desinstalação

---

## 🔍 Troubleshooting (Para o TI)

| Problema | Causa Provável | Solução |
|---|---|---|
| Wallpaper não muda após instalar | Sem internet ou URL incorreta | Cheque `wallpaper_agent.log` e teste a URL no navegador |
| "Acesso negado" no Install.bat | Agente anterior ainda rodando (arquivo travado) | O Install.bat tenta 3 vezes automaticamente. Se persistir, reinicie o PC |
| Wallpaper fica preto/corrompido | Não deveria acontecer na v2.0 | O agente valida JPEG antes de aplicar. Cheque o log |
| Funciona no PC mas não no notebook | Proxy corporativo | O agente usa proxy do sistema automaticamente. Verifique se o navegador acessa a URL |
| Antivírus bloqueando | Falso positivo (EXE que baixa arquivos) | Adicione exceção para `%LOCALAPPDATA%\CorpWallpaperSystem\` |

### Verificar logs

```
%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log
```

Exemplo de log saudável:
```
2026-04-13 11:22:34 | === Agente iniciado (v2.0.0) ===
2026-04-13 11:22:34 | Verificando wallpaper em: https://iago-pinheiro.github.io/wallpaper-download/wallpaper.jpg
2026-04-13 11:22:36 | Wallpaper atualizado com sucesso.
2026-04-13 15:22:36 | Verificando wallpaper em: https://iago-pinheiro.github.io/wallpaper-download/wallpaper.jpg
2026-04-13 15:22:37 | Wallpaper verificado. Sem alteracoes.
```

---

## Desinstalação Remota (Opcional)

Para remover de vários PCs via rede, execute remotamente:

```batch
taskkill /f /im WallpaperAgent.exe /t
rmdir /s /q "%LOCALAPPDATA%\CorpWallpaperSystem"
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\CorporateWallpaper.lnk"
```

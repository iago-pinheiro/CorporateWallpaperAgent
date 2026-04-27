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
- **Validação de imagem**: Só aplica o wallpaper se o arquivo baixado for um JPEG ou PNG válido.
- **Configurável**: URL do wallpaper definida via `config.txt`, sem necessidade de recompilar.

---

## Arquivos do Projeto

| Arquivo | Para quem | Função |
|---|---|---|
| `WallpaperAgent.cs` | TI / Dev | Código-fonte C# do agente |
| `Build.bat` | TI / Dev | Compila o `.cs` e gera o ZIP de distribuição pronto |
| `Install.bat` | Interno | Script de instalação (empacotado dentro do ZIP) |
| `Uninstall.bat` | Colaborador / TI | Remove tudo do computador |
| `config.txt` | TI (opcional) | Personaliza a URL do wallpaper sem recompilar |

---

## 🔧 Guia para o TI (Preparação e Distribuição)

### Passo 1: Configurar a URL do Wallpaper

A URL padrão está em `WallpaperAgent.cs`:

```csharp
private const string DEFAULT_WALLPAPER_URL = "https://seu-servidor.com/wallpaper.jpg";
```

**Opção A** — Alterar no código e recompilar (permanente).

**Opção B** — Criar um `config.txt` na mesma pasta do `Build.bat` (não precisa recompilar):

```ini
# URL do wallpaper corporativo (qualquer servidor com link público direto)
url=https://seu-servidor.com/wallpaper.jpg
```

> O agente suporta qualquer URL pública que devolva diretamente um arquivo `.jpg` ou `.png`. O `config.txt` sobrescreve a URL padrão do código sem necessidade de recompilação.

### Passo 2: Compilar e Empacotar

1. Dê duplo clique em **`Build.bat`**
2. Ele compila o agente e gera automaticamente o arquivo **`WallpaperCorporativo.zip`** pronto para distribuição
3. Se houver um `config.txt` na pasta, ele é incluído automaticamente no ZIP

### Passo 3: Testar no seu PC

Extraia o ZIP gerado, dê duplo clique em `SOMENTE CLIQUE AQUI PARA INSTALAR.bat` e verifique se o papel de parede mudou.

Para conferir os logs:
```
%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log
```

### Passo 4: Distribuir para os Colaboradores

Envie o **`WallpaperCorporativo.zip`** gerado pelo `Build.bat` por e-mail, intranet, pendrive ou compartilhamento de rede.

Conteúdo do ZIP:
```
📁 WallpaperCorporativo.zip
 ├── SOMENTE CLIQUE AQUI PARA INSTALAR.bat
 ├── WallpaperAgent.exe
 ├── config.txt   ← (incluído automaticamente se existir)
 └── Uninstall.bat
```

> **Dica**: Os arquivos `.cs` e `Build.bat` são internos do TI — **não** envie para os colaboradores.

### Passo 5: Atualizar o Wallpaper no Futuro

1. Suba a nova imagem no servidor configurado (com o mesmo nome de arquivo)
2. Em até **4 horas**, todos os PCs com o agente sincronizam automaticamente
3. Para aplicar imediatamente: peça para o colaborador **reiniciar o PC** ou rodar o instalador novamente

---

## 👤 Guia para o Colaborador (Usuário Final)

### Instalação

1. **Extraia** o ZIP recebido para qualquer pasta (ex: Área de Trabalho)
2. Dê **duplo clique** em `SOMENTE CLIQUE AQUI PARA INSTALAR.bat`
3. Uma tela azul aparecerá mostrando o progresso e fechará sozinha em segundos
4. Seu papel de parede será atualizado em instantes — **pronto!**

> **Importante**: Você precisa **extrair os arquivos do ZIP primeiro**. Não rode o instalador de dentro do ZIP.

### O que acontece depois?

- O wallpaper será atualizado **automaticamente** a cada poucas horas
- O programa é **invisível** — não aparece na barra de tarefas nem consome memória perceptível
- Funciona mesmo se o notebook for **desligado e religado** (inicia com o Windows)
- Se estiver **sem internet**, nada acontece — tenta novamente mais tarde

### Onde fica instalado?

O agente se instala permanentemente em:
```
C:\Users\[SeuUsuario]\AppData\Local\CorpWallpaperSystem\
```
Você pode apagar o ZIP e a pasta de extração após a instalação sem problema algum.

### Desinstalação

1. Dê **duplo clique** em `Uninstall.bat` (peça ao TI se não tiver o arquivo)
2. Pronto — o agente é removido completamente, sem deixar rastros
3. Seu papel de parede atual **não será alterado** após a desinstalação

---

## 🔍 Troubleshooting (Para o TI)

| Problema | Causa Provável | Solução |
|---|---|---|
| Wallpaper não muda após instalar | Sem internet ou URL incorreta | Cheque `wallpaper_agent.log` e teste a URL no navegador |
| "Acesso negado" no instalador | Agente anterior ainda rodando | O instalador tenta 3 vezes automaticamente. Se persistir, reinicie o PC |
| Wallpaper fica preto/corrompido | Não deveria acontecer na v2.0 | O agente valida JPEG/PNG antes de aplicar. Cheque o log |
| Funciona no PC mas não no notebook | Proxy corporativo | O agente usa proxy do sistema automaticamente |
| Antivírus bloqueando | Falso positivo (EXE que baixa arquivos) | Adicione exceção para `%LOCALAPPDATA%\CorpWallpaperSystem\` |

### Verificar logs

```
%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log
```

Exemplo de log saudável:
```
2026-04-27 09:00:00 | === Agente iniciado (v2.0.0) ===
2026-04-27 09:00:01 | Verificando wallpaper em: https://seu-servidor.com/wallpaper.jpg
2026-04-27 09:00:03 | Wallpaper atualizado com sucesso.
2026-04-27 13:00:03 | Verificando wallpaper em: https://seu-servidor.com/wallpaper.jpg
2026-04-27 13:00:04 | Wallpaper verificado. Sem alteracoes.
```

---

## Desinstalação Remota (Opcional)

Para remover de vários PCs via rede, execute remotamente:

```batch
taskkill /f /im WallpaperAgent.exe /t
rmdir /s /q "%LOCALAPPDATA%\CorpWallpaperSystem"
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\CorporateWallpaper.lnk"
```

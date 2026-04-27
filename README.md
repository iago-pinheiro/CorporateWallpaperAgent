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

## Arquitetura

```
[RH sobe imagem no S3]
        ↓
[AWS S3 - Link público fixo]
        ↓
[WallpaperAgent.exe - roda em background nas máquinas]
        ↓
[Papel de parede atualizado silenciosamente]
```

O agente consome uma URL pública configurada no `config.txt`. Quando o RH quiser trocar o wallpaper, basta fazer upload de uma nova imagem com o mesmo nome no S3 — todas as máquinas atualizam em até 4 horas automaticamente.

---

## Arquivos do Projeto

| Arquivo | Para quem | Função |
|---|---|---|
| `WallpaperAgent.cs` | TI / Dev | Código-fonte C# do agente |
| `Build.bat` | TI / Dev | Compila o `.cs` em `.exe` usando o compilador nativo do Windows |
| `Install.bat` | Colaborador | Instalador amigável — duplo clique e pronto |
| `Uninstall.bat` | Colaborador / TI | Remove tudo do computador |
| `config.txt` | TI (não sobe pro GitHub) | Define a URL pública do wallpaper (S3 ou outro servidor) |

> ⚠️ O `config.txt` com a URL corporativa está no `.gitignore` e **não é versionado**. Ele é gerado internamente pela TI antes de empacotar o ZIP de distribuição.

---

## 🔧 Guia para o TI (Preparação e Distribuição)

### Passo 1: Configurar o servidor de imagens

A URL do wallpaper é definida no `config.txt` (não versionado):

```ini
# URL pública do wallpaper (AWS S3, GitHub Pages, ou outro servidor público)
url=https://seu-bucket.s3.amazonaws.com/public/wallpaper.jpg
```

**Requisito do servidor:** A URL precisa ser de acesso público e anônimo (sem autenticação), para que o agente nas máquinas dos colaboradores consiga fazer o download sem precisar de login.

### Passo 2: Compilar

1. Dê duplo clique em **`Build.bat`**
2. Ele usa o compilador C# nativo do Windows (`csc.exe` do .NET Framework 4.x) — não precisa instalar nada
3. Se tudo der certo, aparece `Compilação OK!` e o arquivo `WallpaperAgent.exe` é gerado

### Passo 3: Testar no seu PC

1. Rode **`Install.bat`** com duplo clique
2. A tela mostrará o progresso e fechará sozinha
3. Verifique se o papel de parede mudou
4. Para conferir os logs:

```
%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log
```

### Passo 4: Distribuir para os Colaboradores

Monte um **ZIP** contendo:

```
📁 WallpaperCorporativo.zip
 ├── CLIQUE AQUI PARA INSTALAR.bat   ← renomeado do Install.bat
 ├── WallpaperAgent.exe
 ├── config.txt                       ← com a URL do S3
 └── Uninstall.bat
```

Envie por e-mail, intranet, pendrive ou compartilhamento de rede.

> **Dica**: Os arquivos `.cs`, `Build.bat` e `Build_e_Empacotar.bat` são internos do TI — **não** envie para os colaboradores.

### Passo 5: Atualizar o Wallpaper no Futuro

1. Faça upload da nova imagem no servidor (ex: S3), **com o mesmo nome de arquivo**
2. Em até **4 horas**, todos os PCs com o agente sincronizam automaticamente
3. Para aplicar imediatamente: peça para o colaborador **reiniciar o PC** ou rodar o instalador novamente

---

## 👤 Guia para o Colaborador (Usuário Final)

### Instalação

1. **Extraia** o ZIP recebido para qualquer pasta (ex: Área de Trabalho)
2. Dê **duplo clique** em `CLIQUE AQUI PARA INSTALAR.bat`
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

---

## 🔍 Troubleshooting (Para o TI)

| Problema | Causa Provável | Solução |
|---|---|---|
| Wallpaper não muda após instalar | Sem internet ou URL incorreta | Cheque `wallpaper_agent.log` e teste a URL no navegador |
| "Acesso negado" no instalador | Agente anterior ainda rodando | O instalador tenta 3 vezes automaticamente. Se persistir, reinicie o PC |
| Wallpaper fica preto/corrompido | Não deveria acontecer na v2.0 | O agente valida JPEG/PNG antes de aplicar. Cheque o log |
| Funciona no PC mas não no notebook | Proxy corporativo | O agente usa proxy do sistema automaticamente |
| Antivírus bloqueando | Falso positivo | Adicione exceção para `%LOCALAPPDATA%\CorpWallpaperSystem\` |
| URL do S3 retorna erro 403 | Bucket sem permissão pública | Verifique a Bucket Policy do S3 (leitura pública nos objetos) |

### Verificar logs

```
%LOCALAPPDATA%\CorpWallpaperSystem\wallpaper_agent.log
```

Exemplo de log saudável:
```
2026-04-27 09:00:00 | === Agente iniciado (v2.0.0) ===
2026-04-27 09:00:01 | Verificando wallpaper em: https://bucket.s3.amazonaws.com/public/wallpaper.jpg
2026-04-27 09:00:03 | Wallpaper atualizado com sucesso.
2026-04-27 13:00:03 | Verificando wallpaper em: https://bucket.s3.amazonaws.com/public/wallpaper.jpg
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

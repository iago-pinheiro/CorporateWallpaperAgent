# Corporate Wallpaper Agent

Agente silencioso em C# para atualização automatizada e periódica do Wallpaper Corporativo em computadores Windows (10/11), voltado para campanhas de endomarketing e avisos importantes de TI ou RH, **sem a necessidade de privilégios de Administrador**.

## Funcionalidades
- **Instalação Silenciosa e Sem Admin**: Copia o binário para o diretório local do usuário (`AppData\Local`) e registra a inicialização atuando no menu "Startup" do usuário. Nenhuma permissão elevada é requerida.
- **Transparente e Invisível**: Compilado na plataforma `.NET` nativa de forma mágica, ele não abre telas pretas (`CMD`) durante a operação (utilizando o modo `winexe`).
- **Resiliente a Falhas de Rede**: Entende quando o notebook está fora da internet (como num voo) ou com baixa conectividade e falha silenciosamente sem emitir janelas de erro para o funcionário.
- **Atualização Contínua**: O Agente executa num loop rodando uma vez a cada 4 horas checando a URL e baixando eventuais atualizações no aviso/papel de parede silenciosamente.
- **Sem conflitos**: Adicionado mecanismo (`Mutex`) impedindo a execução duplicada sobrecarregando a máquina.

## Componentes do Sistema (Repositório)

1. `WallpaperAgent.cs`: O código-fonte C# nativo e lógico. 
2. `Build.bat`: Script de compilação C# usando o compilador pré-existente e padrão do Windows 10/11 (`csc.exe`). 
3. `Install.bat`: Script em Batch amigável que atua como o setup de instalação para as máquinas (embora o próprio `WallpaperAgent.exe` consiga se "auto-instalar" se dado os 2 cliques diretamente nele).
4. `Uninstall.bat`: Script limpador, encerra as instâncias rodando e apaga o agente da máquina do funcionário sem deixar rastros.

## Como Distribuir (Guia Rápido)

Para realizar a distribuição:
1. Altere o *link* (URL) do Wallpaper dentro de `WallpaperAgent.cs` (`WALLPAPER_URL`) se necessário. 
2. Dê duplo clique em `Build.bat`. Ele vai compilar e gerar um `WallpaperAgent.exe` invisível.
3. Para distribuir pela rede/intranet, envie num *.zip* o **`Install.bat`** junto com o executável **`WallpaperAgent.exe`**.
4. Peça para o funcionário abrir o `Install.bat`. Fim!

## Manutenção em Produção
Ao subir um novo `wallpaper.jpg` no servidor/github pages configurado, em até 4h o PC de todos os funcionários que o estão rodando sincronizará sozinho. Caso precisem aplicar de imediato, podem reiniciar a máquina ou re-rodar o app.

## Desinstalação
Os funcionários (ou o departamento de TI) podem rodar o script `Uninstall.bat` diretamente ou através de um disparo remoto. Ele finaliza a árvore do aplicativo na memória RAM e limpa as pastas de arquivos escondidas do AppData (Startup & Workspace).

# Changelog

Resumo das alterações para usuários. Detalhes técnicos e política de versões em [RELEASE.md](RELEASE.md); progresso de desenvolvimento em [OUTLINE.md](OUTLINE.md).

## Em desenvolvimento

Nenhum recurso de gameplay está anunciado como concluído.

## 1.1.10 — Patch — 2026-10-15

- Release consolidado da abertura: roteiro, seis ilustrações/cartões,
  compressão ZX0, cache mapper e trilha PSG/FM/SCC mais pesada da 1.1.9.
- README com tela de título em destaque, acesso ao release e início rápido.
- Manual do jogo revisado com premissa, instalação, requisitos, controles,
  áudio adaptativo e limitações da demonstração.
- Mantém os nomes Raccoon City / Alexandria — Fundações e abertura.
- Pacote público sem DOS2; disco de boot privado continua somente em `temp`.

## 1.1.9 — Patch — 2026-10-15

- Trilha mais pesada: ataque do baixo PSG reforçado e bumbo duplo em galope.
- Guitarra FM com instrumento original de alto feedback e operadores
  retificados, em lugar do timbre de fábrica; quintas com corte tipo palm mute.
- SCC com onda assimétrica saturada, riffs uma oitava abaixo e envelope
  curto, preservando a melodia, os 136 BPM e o loop de 32 compassos.
- Disco privado de teste com nome fixo `temp\bloodstrain-current.dsk`,
  substituído pelo gerador somente após sucesso.

## 1.1.8 — Patch — 2026-10-15

- Trilha original "Madrugada de Ferrugem": heavy metal sombrio, 136 BPM,
  32 compassos em loop, PSG com camadas adicionais de MSX-Music/FM e SCC.
- Detecção automática dos chips opcionais; música residente no COM, iniciada
  após a pré-carga, contínua nas transições e silenciada ao sair.
- Tela de carga com geração do MSX, mapper principal total/livre e tiques
  de PSG/FM/SCC; nenhum novo arquivo de execução.
- Sequenciador por interrupção, andamento para 50/60 Hz, restauração do hook
  anterior e manutenção do cache de imagens sem novas leituras.
- Testes de PSG, PSG+FM e PSG+FM+SCC no openMSX, incluindo passagem do loop,
  indicadores, continuidade e silêncio no DOS. Hardware real ainda pendente.

## 1.1.7 — Patch — 2026-10-15

- Documentação do formato ZX0 v2 utilizado pela MSXgl e dos novos requisitos
  de cache, sem alterar a resolução ou a arte.
- Teste mede as transições com limite de 1,5 segundo em Z80 emulado a 100%,
  comprova ausência de leituras após a pré-carga e devolução dos 14 segmentos.
  Medições com disquete no openMSX: 0,56 a 0,86 segundo por transição.
- Disco inicializável local atualizado em `temp`, fora do Git e do release.

## 1.1.6 — Patch — 2026-10-15

- Imagens comprimidas com ZX0 v2: 189.952 para 20.546 bytes (89,2% menos).
- Pré-carga única e descompressão para 224 KiB de RAM mapper reservados pelo
  DOS2; transições e replay não abrem nem leem arquivos.
- Seis cartões curtos de texto intercalados com as seis ilustrações.
- Verificação CRC16 antes de descomprimir, checagem de RAM disponível e
  liberação dos segmentos ao sair; arte e resolução preservadas.
- Pacote de execução simplificado para COM e `INTRO.PAK`; SC5 mantidos nos
  fontes como referência e para testes de igualdade da imagem.

## 1.1.5 — Patch — 2026-10-15

### Adicionado

- Roteiro em Markdown, dividido em cenas, com revisão de atmosfera de filme B
  dos anos 1980; TXT original preservado.
- Introdução em seis quadros ilustrados com legendas, avanço por SPACE/ENTER,
  salto ao título com S e saída ao DOS com ESC.
- Tela original de carregamento/título, inspirada nas ilustrações de jogos
  da época do ZX Spectrum, em SCREEN 5 de 256 × 212 e paleta de 16 cores.
- Gerador reproduzível de bitmaps e previews PNG, sem dependências adicionais.
- Leitura de imagens via DOS2 em blocos de 512 bytes, erros explícitos e
  inclusão/verificação dos sete SC5 no pacote e no DSK.
- Smoke test da sequência, dos bitmaps na VRAM, replay, salto e retorno ao DOS.

### Corrigido

- Limpeza do buffer de teclado da BIOS ao sair, evitando que os comandos
  usados na introdução sejam executados acidentalmente no prompt do DOS.

Ainda sem gameplay ou áudio; FM e SCC não são necessários. Continua no ciclo Alexandria.

## 1.1.4 — Patch — 2026-10-13

### Melhorado

- Teste de screenshot verifica as cores no PNG e não depende de preferências de turbo do emulador.
- Configuração de IntelliSense para editar os fontes SDCC no Visual Studio Code.
- Pacote final da fundação com documentação, capturas e verificações revisadas.

Sem novo recurso de gameplay e sem apelido próprio; continua no ciclo Alexandria.

## 1.1.3 — Patch — 2026-10-13

### Melhorado

- Captura automatizada agora aguarda a abertura antes de enviar ESC.

### Adicionado

- Teste de abertura também verifica as faixas coloridas na VRAM.
- Pacote recomendado com documentação e capturas revisadas.

Sem novo recurso de gameplay e sem apelido próprio; continua no ciclo Alexandria.

## 1.1.2 — Patch — 2026-10-13

### Corrigido

- ESC agora retorna corretamente ao DOS, que continua aceitando comandos.
- Ajustes de empacotamento e verificação para Windows PowerShell.

### Adicionado

- Teste automatizado de abertura e saída no openMSX.
- Screenshots reais da abertura e do retorno ao DOS.
- Verificação do conteúdo do ZIP final.

Este patch não tem apelido próprio; permanece no ciclo **Alexandria — Fundações e abertura**. É a versão recomendada no lugar da 1.1.1.

## 1.1.1 — Alexandria — Fundações e abertura — 2026-10-13

### Adicionado

- Primeira abertura de Bloodstrain, com faixas coloridas, título e versão.
- ESC para voltar ao MSX-DOS.
- Pacote com executável, DSK de dados, manual, licença e fontes.
- Documentação inicial para acompanhar o projeto entre computadores.

### Limitações

- Ainda não há gameplay, arte própria, música, combate, diálogos ou salvamento.
- O DSK não inclui MSX-DOS e não é inicializável sozinho.
- Validação em hardware físico permanece pendente.

Os próximos patches não recebem apelido próprio: pertencem ao ciclo Alexandria enquanto X e Y não mudarem.

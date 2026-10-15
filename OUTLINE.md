# Bloodstrain — guia vivo do projeto

**Última atualização:** 2026-10-15
**Versão fundadora:** 1.1.1 — Alexandria — Fundações e abertura  
**Versão atual:** 1.1.10 — release consolidado da abertura do ciclo Alexandria
**Linha principal:** 1 — Raccoon City  
**Fonte da versão numérica:** [version.json](version.json)

## Retomada rápida em outro computador ou com outra IA

1. Leia este documento, [README.md](README.md) e [kickstart.md](kickstart.md).
2. Confira [version.json](version.json), [CHANGELOG.md](CHANGELOG.md) e [RELEASE.md](RELEASE.md).
3. Preserve os fontes e as dependências `MSXgl` e `msxDiskUtil`. Elas já estavam disponíveis no computador original.
4. No Windows, em uma pasta sem espaços, execute `.\scripts\setup.ps1`.
5. Para uma nova compilação, execute `.\build.bat` — ela avançará o patch. Não sobrescreva releases.
6. Não confunda sugestões técnicas com decisões do criador. Consulte a lista de questões abertas antes de implementar comportamento novo.
7. Ao encerrar uma sessão, atualize estado, decisões, testes, pendências, bugs e próximo passo neste documento.

**Transferência:** copie a pasta do projeto completa para continuar o desenvolvimento. O ZIP em `dist` é para distribuição; seu `SOURCE.zip` não inclui compiladores, ROMs ou o executável do msxDiskUtil. Repositório: wilsonpilon/bloodstrain.

## Visão e escopo confirmados

Adventure de ação com elementos de RPG para MSX2, MSX-DOS 2, máquina de referência com 512 KiB, SCC, FM e PSG. Um bairro de São Paulo, sete ou oito pontos principais e backtracking. Três classes selecionáveis; pet com evolução; inventário limitado; facções amigas e inimigas; aliada importante; dois ou três tipos de zumbis; chefe final. Poucos inimigos simultâneos e bastante diálogo e caminhos alternativos.

O criador já tem ideias e roteiro. **Não inventar nem declarar aprovado o conteúdo que ainda não foi registrado.**

## O que temos

| Área | Estado |
|---|---|
| Dependências | MSXgl e msxDiskUtil presentes; SDCC 4.6.0 e openMSX 21.0 identificados localmente. |
| Base C | Entrada DOS2 e módulo de abertura separados. |
| Vídeo | SCREEN 5, 256 × 212, paleta própria; tela ilustrada de carregamento/título e seis quadros de introdução. |
| Entrada | ESC para retornar ao MSX-DOS; saída corrigida com `BIOS_Exit` na 1.1.2. |
| Pipeline | Preparação, compilação, montagem, link, COM, DSK de dados, fontes correspondentes e ZIP. |
| Documentação | Kickstart, README, guia vivo, changelog, releases, manual, licenças e créditos. |
| Gameplay | Não implementado. |
| Arte, animação e áudio | Sete ilustrações estáticas originais; trilha original PSG com camadas FM/SCC opcionais. Sem animação. Fonte MSXgl atribuída. |
| Dados de campanha | Introdução em docs/roteiro.md, original TXT preservado; demais eventos ainda em aberto. |
| Mapper e save | Cache da introdução: 14 segmentos DOS2 (224 KiB). Save ainda não implementado. |

## Passos realizados

- [x] Preparar release 1.1.10 com título no README, manual do jogo e notas,
  mantendo Raccoon City / Alexandria — Fundações e abertura.

- [x] Inspecionar template MSX2 e ferramentas da MSXgl.
- [x] Inspecionar interface CLI e licença do msxDiskUtil.
- [x] Definir estrutura segmentada sem criar sistemas fictícios.
- [x] Criar abertura mínima Bloodstrain.
- [x] Registrar política de versões e apelidos.
- [x] Criar documentação e licença GPLv3, preservando licenças de terceiros.
- [x] Validar build, DSK, ZIP e execução em emulador; registrar evidências abaixo.
- [x] Corrigir chamada de BIOS incompatível com DOS na saída e verificar comando após ESC.
- [x] Adicionar smoke test repetível e capturas reais.
- [x] Configurar include paths e extensões SDCC para IntelliSense do VS Code.
- [x] Verificar também dimensões e cores no PNG, não apenas registradores do VDP.
- [ ] Confirmar execução no MSX2 físico.

## Decisões adotadas nesta fundação

| Decisão | Motivo |
|---|---|
| Executável DOS2 `BLOODSTR.COM` | Corresponde à plataforma solicitada e respeita nomes 8.3. |
| SCREEN 5 na abertura | Ponto de partida do template MSX2; não fecha o formato de todos os cenários. |
| Área inicial de 192 linhas | Fundação histórica; a introdução 1.1.5 passa a 212 linhas, com rodapé para legendas. |
| DSK sem arquivos de DOS | Evitar redistribuir sistema operacional sem condições de licença verificadas. |
| GPL-3.0-only para trabalho original | Pedido do criador; dependências mantêm seus avisos. |
| 1.1.1 como fundação | Exceção inicial escolhida pelo criador, sem alegação de campanha pronta. |
| X: Raccoon City; Y: Alexandria | Referências a locais de Resident Evil e The Walking Dead; apelidos editoriais iniciais, substituíveis pelo criador. |
| Z avança em build completo bem-sucedido | Não registrar como release um pacote incompleto ou compilação falhada. |

## Sugestões técnicas ainda não aprovadas como design definitivo

- Telas fixas ou pequenas áreas em vez de bairro inteiro com rolagem contínua.
- Cenários bitmap construídos com peças reutilizáveis.
- Personagens com sprites de hardware, respeitando oito sprites por linha.
- Dados e flags para diálogos, facções e alterações persistentes no bairro.
- Para gameplay, definir divisão entre música e efeitos; intro já usa PSG/FM/SCC.
- Carregamento por área e uso posterior do mapper como bancos/cache.

## Próximos passos

1. **Revisar com o criador a abertura implementada** e registrar classes, pet, aliada e facções. A introdução agora define o surto e a jovem que sai ao mercado.
2. Escolher uma rua e um interior para a primeira fatia jogável.
3. Definir tamanho do personagem, pet, área de jogo e espaço de diálogo/UI.
4. Criar movimento, colisão e transição entre essas duas áreas.
5. Adicionar pet básico e um único inimigo.
6. Implementar interação, diálogo com escolha, item e inventário limitado.
7. Persistir uma consequência ao sair e voltar; depois salvar/carregar.
8. Produzir primeiro conjunto de arte própria, tema curto e efeitos.
9. Medir desempenho, uso de RAM/VRAM e limites de sprites antes de expandir.

**Não começar os nove passos ao mesmo tempo.** O próximo trabalho de design depende do roteiro que o criador vai fornecer.

## Pendências e questões abertas

| ID | Pendência | Impacto |
|---|---|---|
| P-001 | Introdução registrada; confirmar primeira rua, mercado e continuação | Mapas, diálogos e campanha |
| P-002 | Definir classes e capacidades do pet | Interações e progressão |
| P-003 | Confirmar modelo de MSX2, VRAM, DOS 2 e SCC | Orçamento e compatibilidade |
| P-004 | Escolher modo de navegação e combate | Movimento, câmera e sprites |
| P-005 | Intro usa partitura C residente e PSG/FM/SCC; definir áudio de gameplay | Produção e reprodução |
| P-006 | Confirmar nome público do criador e demais créditos | Publicação |
| P-007 | Resolvido: Git e remoto wilsonpilon/bloodstrain presentes | Continuidade entre computadores |
| P-008 | Validar máquina física, 50/60 Hz e distribuição | Release público |
| P-009 | Definir regras para aumentar X/Y e início do patch seguinte | Hoje a regra documentada usa Z=1 no novo ciclo |

## Bugs e limitações rastreados

| ID | Tipo | Estado | Descrição |
|---|---|---|---|
| L-001 | Ferramenta | Aberto | Build upstream usa caminhos sem aspas; script rejeita raiz com espaços explicitamente. |
| L-002 | Escopo | Conhecido | Abertura ilustrada sem gameplay, música, sprites de personagens ou save. |
| L-003 | Distribuição | Documentado | DSK de dados exige DOS 2 externo; não dá boot sozinho. |
| L-004 | Portabilidade | Aberto | Pipeline validado inicialmente no Windows; outros sistemas ainda não certificados. |
| B-001 | Runtime | Corrigido em 1.1.2 | Na 1.1.1, ESC chamava uma rotina BIOS diretamente em página 0 com RAM do DOS mapeada, travando a saída. Substituída por `BIOS_Exit`, que faz a transição apropriada via interslot. Reprodução: iniciar, pressionar ESC; esperado: prompt utilizável. Verificado com ECHO após sair. |
| W-001 | Dependência | Conhecido | SDCC emite warning 357 em `MSXgl/engine/src/vdp.c:949`; não é código de Bloodstrain, não impede build e não foi alterado. |
| L-005 | Teste/captura | Mitigado | Captura depende de renderização, não apenas de registradores. Na 1.1.5, o teste compara a arte completa na VRAM e a paleta, espera o quadro pronto e verifica as cores/dimensões do PNG. Throttle ligado, velocidade 100%, sem salvar preferências pessoais. |

A 1.1.1 é um registro histórico local, **não a versão recomendada para execução**.
Acrescentar bugs reais com reprodução, resultado esperado, versão, responsável
e evidência; não usar “nenhum bug” como sinônimo de ausência de testes.

## Evidências de validação da fundação (1.1.4)

Configuração: openMSX 21.0, Philips NMS 8255, V9938/128 KiB VRAM, mapper externo 512 KiB (além dos 128 KiB internos), cartucho MSX-DOS 2 e duas unidades. Os arquivos de sistema são privados e não integram o release.

| Teste | Resultado |
|---|---|
| SDCC / montagem / link | Aprovado; um warning upstream conhecido |
| COM extraído do DSK idêntico ao original | Aprovado; SHA-256 idêntico |
| ZIP, fontes e SHA-256 | Aprovado; verificação automatizada inclui o ZIP final |
| Abertura em MSX2 com DOS2 emulado | Aprovado; captura real, confirmação de SCREEN 5 e verificação das faixas na VRAM |
| ESC e retorno utilizável ao DOS | Aprovado; SCREEN 0 restaurada e `ECHO RETURN_OK` executado |
| Screenshot da abertura | Aprovado; PNG 320×240 com bordas, faixas vermelha/azul medidas no arquivo e inspeção do conteúdo |
| Diagnósticos do código de aplicação no VS Code | Sem erros após configurar include paths e anotações de chamada SDCC no IntelliSense |
| Hardware real | Pendente |

Scripts: `verify.ps1` valida arquivos sem recompilar; `smoke.ps1` valida runtime sem mudar Z. O pacote 1.1.4 repete o smoke test e a inspeção dos pixels do PNG antes de fechar os artefatos. A configuração de IntelliSense só adapta a análise do editor; a compilação efetiva permanece no SDCC.

Problemas de ambiente resolvidos na fundação: ZIP do Windows PowerShell gerava separadores invertidos; compactação agora normaliza entradas. SHA-256 usa .NET diretamente para não depender do autoload de `Get-FileHash` entre PowerShell 5 e 7. A mídia privada de teste usa setor de boot existente fornecido pelo usuário; o setor padrão do DSK de dados não é tratado como bootável.

O build preserva um snapshot intermediário dos fontes em `build/source-X.Y.Z`, fora do pacote. Isso evita remover headers enquanto o editor ou antivírus os está lendo. O pacote contém apenas `SOURCE.zip`, não uma cópia descompactada duplicada. Após uma tentativa falhada, inspecionar os diretórios de staging/snapshot indicados pelo erro antes de removê-los e repetir.

## Abertura narrativa (1.1.5)

- Introdução recebida em `docs/roteiro.txt`, preservada sem alterações, e
  adaptada em `docs/roteiro.md`. Revisão de atmosfera, sem inventar a campanha.
- Seis quadros e uma montagem de carregamento/título, com fonte editável
  `assets/art/source/intro.js`, exportações SC5, paleta e previews PNG.
- SCREEN 5 de 256 × 212: ilustração nas primeiras 160 linhas e legendas no
  rodapé. Paleta própria; o modo não determina ainda o vídeo do gameplay.
- Arquivos externos 8.3 ao lado do COM, carregados em blocos de 512 bytes.
  Não é preciso alocar uma imagem inteira na RAM nem usar mapper, FM ou SCC.
- SPACE/ENTER avança e revê, S pula ao título, ESC sai ao DOS. Leitura sem
  temporizador; não há “iniciar campanha” fictício. Antes de devolver o
  controle ao DOS, aguarda soltar as teclas e limpa o buffer da BIOS.
- Verificação atualizada para os oito arquivos do DSK, seis imagens completas
  na VRAM, paleta exata, controles e DOS após ESC. Capturas reais ficam em
  `build/smoke`; a arte de storyboard não é screenshot do emulador.
- A MSXgl está configurada para 15 entradas em `VDP_SetPalette`: a aplicação
  passa as entradas 1–15 e mantém a entrada 0 preta. Não alterar o upstream.
- Próximo passo: revisão visual/narrativa do criador; depois escolher a primeira
  rua e o mercado antes de implementar movimento ou colisão.

**Resultado registrado:** build SDCC, montagem e link aprovados; COM de 18.517
bytes, DSK de 737.280 bytes e ZIP 1.1.5 gerados. Smoke test aprovado nos seis
quadros, paleta, SPACE/ENTER, replay, S, ESC e `ECHO RETURN_OK` após o retorno
ao DOS. Os oito arquivos extraídos do DSK têm SHA-256 idêntico aos originais;
fontes, manifesto e ZIP final verificados. Gerador passou em `--check` e
fontes da aplicação sem diagnósticos no VS Code. Permanece somente o warning
357 já conhecido da MSXgl; hardware físico continua pendente.

## Compressão e cache (1.1.6 / 1.1.7)

Na 1.1.9, a pedido do criador, a trilha ganhou mais peso: bumbo duplo e
ataque PSG, guitarra FM original de alto feedback, ondas SCC saturadas e
articulação curta nas quintas. Melodia, harmonia, andamento e duração preservados.
O disco de teste local usa nome fixo `temp\bloodstrain-current.dsk`.

A partir da 1.1.8, a carga mostra geração MSX, mapper total/livre e tiques
PSG/FM/SCC. "Madrugada de Ferrugem" (136 BPM, 32 compassos, ~56 s) toca após
a pré-carga em PSG e usa camadas opcionais YM2413/SCC, detectadas pela MSXgl.
Partitura e ondas originais em `src/audio/intro_music.c`, sem arquivo externo.
O hook H_TIMI é preservado/restaurado; atualizações SCC no ISR usam WRSLT
sem EI, para não reabilitar interrupções dentro do callback. Código/dados
continuam abaixo de 0x8000; música não toca na página 2 do cache.
Testes: PSG a 50 Hz, PSG+FM a 60 Hz e PSG+FM+SCC a 50 Hz, incluindo loop,
continuidade, silêncio na saída e ausência de leitura após carga. A inspeção
do mapper usa RAM física para não confundir remapeamentos temporários do DOS.
O criador considerou aceitável a carga em FDD; HD no MSX real será testado depois.

- Pesquisa na MSXgl: ZX0, Pletter, RLEp e DOS mapper. ZX0 v2 escolhido; o
  decoder atual não é compatível com `zx0 -c` (formato clássico).
- INTRO.PAK: 20.546 bytes, 89,2% menos que os sete SC5 (189.952 bytes).
  Dois blocos por imagem, round-trip no build, CRC16 antes da descompressão.
- Pré-carga única em 14 segmentos de usuário do mapper principal (224 KiB).
  A janela em 0x8000 é restaurada antes das chamadas DOS; guarda no mapa de
  link impede código/dados de invadir a janela.
- Helper local de ALL_SEG sem parâmetros na pilha evita a saída de erro
  sem desempilhar do wrapper de alocação upstream, sem alterar a biblioteca.
- Cada imagem é seguida de quatro linhas de contexto em cartão preto;
  mesmos controles, sem temporizador. Nenhum conteúdo de campanha inventado.
- Em 1.1.6, teste aprovado para imagens exatas, seis cartões, paleta, ausência
  de OPEN/READ após a pré-carga, replay, salto, devolução dos 14 segmentos e DOS.
- 1.1.7 acrescenta medição de tempo e exige transições de até 1,5 s em emulador
  a 100%. Não confundir a redução de bytes com igual redução no tempo:
  o primeiro título aguarda a pré-carga e descompressão de todas as imagens.
- Pacotes anteriores preservados. Disco DOS2 privado é gerado em `temp`
  usando `scripts/local-disk.ps1 -Test`; pasta ignorada pelo Git.

## Rotina de encerramento — checklist

- Registrar versão e artefatos realmente gerados.
- Atualizar changelog para usuários; detalhes técnicos no guia/releases.
- Registrar testes e limitações sem exagerar o que foi verificado.
- Atualizar resumo de roteiro somente com conteúdo aprovado.
- Registrar origem/licença de novos assets e dependências.
- Deixar um próximo passo específico e listar perguntas ao criador.
- Preservar fontes editáveis, não apenas exportações e binários.

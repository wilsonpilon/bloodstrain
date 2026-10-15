# Bloodstrain — releases

## Política de versões

Formato **X.Y.Z**, definido pelo criador. É uma política própria do projeto, não uma promessa de compatibilidade SemVer.

| Componente | Quando muda | Nome |
|---|---|---|
| **X** | Fechamento de porções maiores do jogo | Referência forte/importante do universo zumbi |
| **Y** | Introdução ou conclusão de recurso, ou nova ideia incorporada ao projeto | Referência do universo zumbi e subtítulo curto |
| **Z** | Cada compilação completa bem-sucedida do pipeline | Sem apelido próprio; patch |

Referências podem vir de filmes, séries ou quadrinhos, dos clássicos até The Walking Dead. Usar **locais, personagens ou elementos ficcionais**; **não usar nomes de atores ou diretores**. Evitar repetir apelidos. Referenciar nomes não autoriza copiar assets das obras.

### Convenções operacionais iniciais

- Fonte numérica e editorial: [version.json](version.json).
- Primeiro release: **1.1.1**, por solicitação expressa, apesar do estágio inicial.
- `build.bat` incrementa somente Z. Uma falha não atualiza a versão registrada e não constitui release.
- `build.bat -InitialRelease` compila o número exato de `version.json`, sem incremento. Usar somente para inaugurar o número escolhido; o script recusa sobrescrever artefatos existentes.
- Ao iniciar novo Y, editar `version.json`, aumentar Y, definir Z=1 e escolher `minorName` e `subtitle`. Gerar com `-InitialRelease`.
- Ao iniciar novo X, aumentar X, reiniciar Y=1 e Z=1 e escolher nomes de linha e ciclo. Gerar com `-InitialRelease`.
- Essas convenções de reinício podem ser revistas pelo criador; registrar a mudança antes de aplicá-la.
- Não dar um nome diferente ao patch: **1.1.2** é patch do ciclo Alexandria, não outro codinome.
- Atualizar README, changelog, manual e este registro ao introduzir recursos; o build não inventa notas de mudança.

## Linha 1 — Raccoon City

Referência: cidade do universo Resident Evil. Linha inicial de construção do projeto; o nome não significa que uma grande porção da campanha já foi concluída.

### Ciclo 1.1 — Alexandria — Fundações e abertura

Referência: comunidade de The Walking Dead. Tema editorial: estabelecer a base para o desenvolvimento.

### Release 1.1.1

**Registro histórico local; substituído pela 1.1.2.** O pacote inicial compilou e passou na verificação de arquivos, mas a validação de runtime detectou falha ao sair com ESC. Não usar essa versão como release recomendado.

| Campo | Valor |
|---|---|
| Data | 2026-10-13 |
| Tipo | Fundação técnica / abertura mínima |
| Alvo | MSX2, MSX-DOS 2 |
| Executável | `BLOODSTR.COM` |
| Vídeo | SCREEN 5, abertura de 256 × 192 |
| Áudio | Nenhum nesta versão |
| Entrada | ESC para sair |
| Pacote | `dist\Bloodstrain-1.1.1.zip` |
| DSK | `Bloodstrain-1.1.1.dsk`, FAT12, 720 KiB, somente dados |
| Licença original | GPL-3.0-only |
| Licenças externas | MSXgl/fonte CC BY-SA 4.0; avisos preservados |

**Conteúdo:** faixas coloridas, moldura, título, número da versão e instrução de saída. Estrutura de fontes, assets, dados, documentos, scripts e testes preparada.

**Não incluído:** seleção de classe, movimento, pet, inimigos, inventário, diálogos, campanha, música, efeitos, mapper e saves.

**Ferramentas identificadas:** SDCC 4.6.0; openMSX 21.0; Node fornecido pela MSXgl; msxDiskUtil extraído do ZIP 1.8b.

**Testes:** consultar a tabela de evidências atualizada em [OUTLINE.md](OUTLINE.md). A compilação e verificação de arquivos não substituem um teste em máquina física.

### Conteúdo do pacote

- COM e DSK de dados.
- README, MANUAL, LICENSE, CHANGELOG e RELEASE.
- THIRD_PARTY e textos de licença em `licenses`.
- `version.json` e `SHA256SUMS.txt`.
- `SOURCE.zip`: fontes do jogo, scripts, documentação e fontes correspondentes da MSXgl usados no projeto.

Não inclui compiladores, emulador, ROMs, arquivos do MSX-DOS ou o executável msxDiskUtil. Para desenvolvimento em outro computador, preferir a cópia completa da pasta de trabalho.

## Checklist para cada release

- [ ] Conteúdo corresponde ao escopo anunciado.
- [ ] Versão na abertura, COM, nomes de artefatos e manifesto é consistente.
- [ ] Compilação, montagem, link e conversão terminaram sem erro.
- [ ] DSK tem 737280 bytes e COM extraído tem SHA-256 idêntico.
- [ ] ZIP inclui documentação, licenças e fontes correspondentes.
- [ ] Testar em emulador e registrar configuração e screenshot.
- [ ] Testar saída ao DOS e controles implementados.
- [ ] Verificar máquina física ou declarar teste pendente.
- [ ] Revisar créditos, origens dos assets e condições de distribuição.
- [ ] Atualizar guia vivo, changelog e notas de release.

## Registro de patches posteriores

### 1.1.2 — 2026-10-13

Patch sem apelido próprio, pertencente ao ciclo Alexandria.

- Saída corrigida usando `BIOS_Exit`, helper apropriado da MSXgl para retorno ao DOS.
- Mantém somente a abertura colorida; não acrescenta gameplay.
- Smoke test confirma SCREEN 5, injeta ESC, confirma SCREEN 0 e exige resposta a `ECHO RETURN_OK` no DOS.
- Capturas reais incluídas em `docs/screenshots`.
- COM, DSK FAT12 de 720 KiB, fontes, checksums e conteúdo do ZIP final verificados.
- Configuração: openMSX 21.0, Philips NMS 8255, cartucho DOS 2 e mapper externo de 512 KiB.
- Ainda não testado em hardware físico.
- Warning 357 no módulo VDP da MSXgl permanece registrado, sem alterações na biblioteca.

Artefatos históricos: `dist\Bloodstrain-1.1.2\BLOODSTR.COM`, `dist\Bloodstrain-1.1.2\Bloodstrain-1.1.2.dsk` e `dist\Bloodstrain-1.1.2.zip`. Preferir o pacote atual.

### 1.1.3 — 2026-10-13

Patch sem apelido próprio, pertencente ao ciclo Alexandria.

- Mesma abertura e saída da 1.1.2, com o número de versão atualizado.
- Reforça a temporização da screenshot no smoke test antes de injetar ESC.
- Confere bytes das faixas superior e inferior na VRAM, além do modo gráfico.
- Repete validação de COM, DSK, fontes, checksums, ZIP, abertura e retorno ao DOS.
- Inclui screenshots revisadas da versão atual.
- Hardware físico e configurações alternativas permanecem pendentes.

Artefatos históricos: `dist\Bloodstrain-1.1.3.zip` e `dist\Bloodstrain-1.1.3`.

### 1.1.4 — 2026-10-13

Patch sem apelido próprio, pertencente ao ciclo Alexandria.

- Mantém a abertura e a saída corrigida, sem gameplay adicional.
- Smoke test com throttle ligado e espera em tempo real para renderização, sem salvar preferências do usuário.
- Verifica também tamanho 320×240 e cores das faixas no PNG.
- Include paths e anotações SDCC configurados no IntelliSense; fontes da aplicação sem diagnósticos de erro no VS Code.
- Repete compilação, validação de artefatos, abertura, ESC, comando no DOS e capturas.
- COM com 15698 bytes; DSK com 737280 bytes.
- Hardware físico ainda pendente; warning upstream da MSXgl continua documentado.

Artefatos históricos: `dist\Bloodstrain-1.1.4.zip` e `dist\Bloodstrain-1.1.4`.

### 1.1.5 — 2026-10-15

Patch do ciclo Alexandria, sem novo apelido.

- Roteiro original preservado e adaptação em Markdown por cenas.
- Seis quadros narrativos e tela ilustrada de carregamento/título, com arte
  original reproduzível, SCREEN 5 de 256 × 212 e paleta própria.
- SPACE/ENTER avança e revê, S pula, ESC retorna ao DOS. O buffer de teclado
  da BIOS é limpo na saída, sem executar teclas antigas no prompt.
- Sete arquivos SC5 externos, de 27.136 bytes cada, lidos em blocos de 512 bytes.
  Devem ficar junto do COM. Não exige FM/SCC e ainda não usa o mapper.
- Smoke test aprovado: seis ilustrações completas na VRAM, paleta exata,
  controles, replay, salto e `ECHO RETURN_OK` após sair de um quadro.
- COM de 18.517 bytes, DSK de 737.280 bytes; oito arquivos extraídos e comparados
  por SHA-256. Fontes, manifesto e ZIP final verificados.
- Ainda sem gameplay, áudio ou validação em hardware físico. Warning 357
  upstream permanece conhecido.

Pacote anterior: `dist\Bloodstrain-1.1.5.zip`.
Executável, imagens e DSK também estão em `dist\Bloodstrain-1.1.5`.

### 1.1.6 / 1.1.7 — 2026-10-15

- A 1.1.6 incorpora ZX0 v2 e cache no mapper: 20.546 bytes em disco, contra
  189.952 bytes dos bitmaps anteriores. 14 segmentos de 16 KiB reservados via
  DOS2, restaurados/liberados ao sair. COM da 1.1.6: 20.464 bytes.
- Seis cartões de quatro linhas intercalados com as ilustrações, ampliando a
  narrativa sem exigir releituras de disco ou mudar a arte.
- Round-trip ZX0 no gerador, CRC16 por bloco no MSX, verificação do mapa de
  link e comparação da imagem inteira na VRAM.
- Smoke da 1.1.6 aprovado: seis imagens, cartões, paleta, replay, salto, ESC,
  ausência de chamadas OPEN/READ após pré-carga e devolução dos 14 segmentos.
- A 1.1.7 documenta o formato v2 e acrescenta limite medido de 1,5 s para cada
  transição a 100% no emulador. Esse limite não inclui o boot/carga inicial.
- Para executar, copiar somente COM e `INTRO.PAK` da mesma versão.
  O cache exige 224 KiB livres no mapper principal. Sem áudio ou gameplay.
- Hardware físico e HD/SD reais ainda não medidos; warning 357 da MSXgl
  permanece conhecido.

### 1.1.8 — 2026-10-15

- "Madrugada de Ferrugem": trilha original em loop de 32 compassos, 136 BPM,
  baixo/melodia/percussão PSG, guitarras e cordas FM, timbres adicionais SCC.
- Detecção MSX-Music/YM2413 e SCC; partitura residente no COM, sem novos arquivos.
- Diagnóstico na carga: geração do MSX, mapper principal total/livre e tiques
  PSG/FM/SCC. A música começa após a pré-carga e continua nas transições.
- H_TIMI preservado/restaurado; todos os chips usados silenciados ao sair.
- Testes openMSX de PSG a 50 Hz, PSG+FM a 60 Hz e PSG+FM+SCC a 50 Hz,
  incluindo passagem do loop, transições, cache sem disco e retorno ao DOS.
- Música e HD/SD ainda não validados no MSX real. O criador aprovou o tempo
  de carga da abertura 1.1.7 em FDD.

### 1.1.9 — 2026-10-15

- Revisão mais pesada da trilha: baixo PSG com mais ataque, bumbo duplo,
  instrumento FM original distorcido e quintas com articulação tipo palm mute.
- SCC com onda saturada e riffs uma oitava abaixo; melodia, 136 BPM e loop
  preservados. Não depende de novas expansões ou arquivos externos.
- Disco local com nome fixo `temp\bloodstrain-current.dsk`, substituído
  somente após geração e teste bem-sucedidos quando usado `-Test`.

### 1.1.10 — 2026-10-15

**Bloodstrain 1.1.10 — Alexandria — Fundações e abertura**  
Linha 1 — Raccoon City. Patch de consolidação, sem novo apelido.

- Introdução em seis ilustrações originais alternadas com seis cartões de
  texto, roteiro revisado e tela de título SCREEN 5, 256 × 212, 16 cores.
- Imagens ZX0: 189.952 para 20.546 bytes, pré-carga em 224 KiB de mapper,
  sem leitura de disco durante transições e replay.
- "Madrugada de Ferrugem": trilha original heavy metal sombrio, 136 BPM,
  PSG com guitarras FM distorcidas e camadas SCC opcionais.
- Diagnóstico na carga com geração MSX, mapper total/livre e tiques PSG/FM/SCC.
- README com tela de título real em destaque, início rápido e manual revisado.
- SPACE/ENTER avança/revê, S pula ao título, ESC retorna ao DOS com os chips
  silenciados e os segmentos de cache liberados.

**Distribuição:** ZIP completo, DSK de dados de 720 KiB e manifesto SHA-256.
O ZIP inclui manual, documentação, licenças e fontes correspondentes.
Nenhum arquivo de DOS2, ROM de máquina ou disco privado acompanha o release.

**Validação:** build/empacotamento, checksums, igualdade das ilustrações na
VRAM, paleta, cartões, controles, replay, ausência de OPEN/READ após pré-carga,
liberação de 14 segmentos, hook e saída funcional ao DOS no openMSX.
Áudio PSG/FM/SCC validado em emulador; testes 50/60 Hz e loop registrados
nos patches anteriores. Hardware físico, mixagem real e HD/SD seguem pendentes.

**Limitações:** esta versão apresenta a abertura, não a campanha jogável.
Ainda sem exploração, combate, classes, pet, inventário ou salvamento.
Requer MSX2/MSX-DOS2 e 224 KiB livres no mapper principal; referência de 512 KiB.
FM/SCC são opcionais; PSG é o áudio básico. Warning 357 upstream da MSXgl
permanece conhecido e não impede o build.

**Pacote atual:** `dist\Bloodstrain-1.1.10.zip`.
Disco privado com DOS2: `temp\bloodstrain-current.dsk`, gerado separadamente
e substituído a cada execução do gerador local. Não incluído no Git ou no release.

Acrescentar próximos patches com versão, data, alterações, artefatos e testes. O pipeline gera números e arquivos, mas cabe à sessão de desenvolvimento registrar aqui o significado de cada patch.

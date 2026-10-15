# Validação

O pipeline executa `scripts/verify.ps1` antes de concluir um release:

- verifica arquivos obrigatórios;
- exige DSK de 737280 bytes;
- extrai COM, INTRO.PAK e WORLD.PAK do DSK e compara SHA-256;
- confere os pacotes de arte contra as exportações validadas;
- exige que o fim de código/dados no mapa de link fique abaixo de 0x8000,
  deixando a página 2 livre para a janela de mapper;
- verifica o manifesto de checksums;
- confere fontes essenciais no SOURCE.zip.

Para repetir sem compilar e sem aumentar Z:

```powershell
.\scripts\verify.ps1 -PackagePath .\dist\Bloodstrain-1.1.7 -ArchivePath .\dist\Bloodstrain-1.1.7.zip
```

Para testar runtime sem compilar:

```powershell
.\scripts\smoke.ps1 -PackagePath .\dist\Bloodstrain-1.1.7 -DosFilesPath .\MSXgl\tools\build\DOS -BootTemplatePath .\msxDiskUtil\msxdos.dsk
```

O smoke test exige openMSX e suas ROMs legítimas, usa MSX2 com duas unidades e
DOS2, verifica SCREEN 5 com 212 linhas, display ligado e **todos os 20.480 bytes
da ilustração na VRAM**, comparando cada quadro com seu arquivo SC5. Compara
também os 32 bytes da paleta do VDP com a paleta exportada. Percorre os
seis quadros e seis cartões alternando SPACE e ENTER, revê a introdução, pula
com S e sai com ESC de dentro de um cartão. Exige que o DOS execute
`ECHO RETURN_OK` após a saída. Um breakpoint na entrada BDOS falha o teste
se houver OPEN/READ depois do primeiro título: comprova o cache inclusive no replay.
O número de segmentos livres deve aumentar em 14 após sair ao DOS. Cada
transição deve concluir em até 1,5 segundo de tempo emulado, com velocidade 100%;
as medições por quadro ficam em `trace.txt`. Esse limite não é certificação em
hardware real nem inclui o boot ou a pré-carga inicial.

Na validação 1.1.7 com Philips NMS 8255, ram512k e MSX-DOS2, as transições
medidas ficaram entre 0,56 e 0,86 segundo emulado. O primeiro título apareceu
aproximadamente 44 segundos após ligar a máquina emulada; esse tempo inclui
boot do DOS, carga do programa, leitura, verificação e descompressão do pacote.
HD/SD e hardware físico ainda não foram medidos.

Captura título, seis quadros, seis cartões e DOS em `build/smoke`, mede as dimensões e exige ao
menos oito cores em cada ilustração renderizada. As legendas devem caber em duas
linhas de até 40 caracteres; cartões têm quatro linhas de até 40 caracteres.
O gerador verifica os limites e o round-trip de cada bloco ZX0. A mídia privada de
sistema é removida ao terminar e nunca incluída no pacote. O teste fixa a
velocidade do emulador em 100%, sem gravar preferências pessoais.

Para verificar arte, paleta, legendas e previews sem recompilar:

```powershell
.\MSXgl\tools\build\Node\node.exe .\assets\art\source\intro.js --check
```

Hardware físico e configurações alternativas devem ser registrados
separadamente em OUTLINE; testes de áudio 50/60 Hz abaixo.

## Quadra explorável (1.1.11 local)

```powershell
.\MSXgl\tools\build\Node\node.exe .\assets\art\source\block.js --check
.\scripts\smoke.ps1 -PackagePath .\dist\Bloodstrain-1.1.11 -DosFilesPath .\MSXgl\tools\build\DOS -BootTemplatePath .\msxDiskUtil\msxdos.dsk -BlockTest
```

O gerador verifica round-trip ZX0, spawns com a mesma pegada dos pés do runtime,
conectividade por pixel e chegadas fora das portas de retorno.
O smoke abre o mapa com M e usa somente teclas de direção, sem escrever
posições no estado do jogo. Percorre cinco áreas, portas principal/lateral do
mercado, farmácia, retornos, obstáculos e limites oeste/sul. Retorna pelo título
ao DOS e exige resposta a `ECHO BLOCK_OK`. Capturas e rastreamento das ações
ficam em `build/smoke/block-*`.

As posições são lidas da RAM física após identificar o segmento do aplicativo:
ler apenas `memory` durante chamadas BIOS/DOS pode observar outro slot e gerar
falsas transições. O teste padrão de intro continua separado e ambos fazem
parte do build com `-SmokeTest`.

## Áudio e diagnóstico (1.1.8)

O smoke padrão agora exige PSG ativo após a carga e silencioso ao sair,
restauração exata dos cinco bytes do H_TIMI, painel capturado e tiques corretos.
Amostra os registros a cada 0,1 s para verificar progressão da trilha durante
as transições. A tabela do mapper é lida na RAM física porque DOS/BIOS podem
remapear a página 3 durante interrupções. Os mappers conhecidos desta configuração
de teste são `Main RAM` e `512k External RAM`.

```powershell
.\scripts\smoke.ps1 -PackagePath .\dist\Bloodstrain-1.1.8 -DosFilesPath .\MSXgl\tools\build\DOS -BootTemplatePath .\msxDiskUtil\msxdos.dsk -SoundExtensions fmpac,scc -MusicSeconds 65
.\scripts\smoke.ps1 -PackagePath .\dist\Bloodstrain-1.1.8 -DosFilesPath .\MSXgl\tools\build\DOS -BootTemplatePath .\msxDiskUtil\msxdos.dsk -SoundExtensions fmpac -VideoHz 60 -MusicSeconds 60
```

As extensões opcionais usam um slot expander, exigindo ROM FM-PAC legítima.
`-MusicSeconds` mantém o título e grava `build/smoke/intro.wav` antes de percorrer
a intro. 65 s excedem o loop de ~56 s. `-VideoHz` força a frequência no VDP e
seu backup antes de iniciar a música, sem alterar ROMs ou preferências pessoais.
Foram validados PSG/50 Hz, PSG+FM/60 Hz e PSG+FM+SCC/50 Hz; o teste inspeciona
as camadas detectadas e seu desligamento. A captura conjunta de 65 s é PCM mono
44,1 kHz/16 bits e não apresentou clipping digital. Isso não substitui a
avaliação musical nem teste dos volumes/mixagem no computador físico.

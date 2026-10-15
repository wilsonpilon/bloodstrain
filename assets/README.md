# Assets

Preservar sempre o original editável e a exportação usada pelo jogo.

- `art/source`: pixel art, paletas, sprites e cenários editáveis.
- `art/export`: conversões para formatos usados pela MSXgl.
- `audio/music`: composições originais e projetos de tracker.
- `audio/sfx`: fontes editáveis dos efeitos.
- `audio/export`: músicas e efeitos convertidos para reprodução.

## Arte da introdução

- **Origem/autoria:** arte original produzida para Bloodstrain com assistência
  do Copilot, a partir do roteiro e direção do criador. Sem imagens externas.
- **Licença:** GPL-3.0-only.
- **Original editável:** [art/source/intro.js](art/source/intro.js), incluindo
  desenho, paleta, lettering original para placas e textos das legendas.
- **Ferramentas:** Node.js (apenas módulos nativos) e ZX0/DZX0 v2.2 fornecidos
  com a MSXgl. Sem novas dependências instaladas.
- **Exportação:** seis `INTRO*.SC5` e `TITLE.SC5`, bitmaps SCREEN 5 sem cabeçalho,
  256 × 212, dois pixels por byte, nibble alto primeiro, 27.136 bytes cada.
  Os primeiros 160 pixels verticais são arte; o rodapé é desenhado no runtime.
- **Pacote de execução:** `INTRO.PAK`, 20.546 bytes. São 14 blocos ZX0 v2
  (compatível com o decoder MSXgl), dois por imagem: 16.384 e 4.096 bytes
  descomprimidos. As 52 linhas vazias do rodapé não entram na compressão.
  A ordem é INTRO1 a INTRO6 e TITLE. Tamanhos comprimidos e CRC16/IBM
  (inicial 0xFFFF, polinômio refletido 0xA001) ficam no header gerado e no COM.
  Cada bloco passa por round-trip com DZX0 e comparação exata no build.
  Buffer de leitura máximo atual: 3.402 bytes.
  Não usar `zx0 -c`: o decoder desta versão da MSXgl espera o formato v2,
  não o formato clássico v1.
- **Cache MSX:** 14 segmentos de 16 KiB (224 KiB) no mapper principal, alocados
  pela API DOS2. Página 2 serve de janela temporária; é restaurada antes de
  qualquer chamada ao DOS. Código e dados ficam abaixo de 0x8000, com guarda
  de link no build. O cache já descomprimido evita descompressão e disco nos avanços.
- **Paleta:** 16 entradas RGB de 3 bits por canal, exportadas para o header
  gerado `build/generated/intro_data.h`, junto das legendas ASCII; `INTRO.PAL`
  preserva os 32 bytes para comparação automatizada com o VDP.
- **Prévias:** PNGs individuais e `art/export/storyboard.png`. As prévias usam
  lettering do gerador; o jogo usa a fonte bitmap MSXgl, atribuída em THIRD_PARTY.

O pipeline regenera a arte antes de compilar. Para regenerar ou verificar
reprodutibilidade sem compilar:

```powershell
.\MSXgl\tools\build\Node\node.exe .\assets\art\source\intro.js
.\MSXgl\tools\build\Node\node.exe .\assets\art\source\intro.js --check
```

A opção `--check` compara todas as exportações e o header, sem sobrescrevê-los.
Ela também recomprime e verifica o round-trip. Arquivos temporários desse
processo ficam apenas em `build/generated` e são removidos ao terminar.
O preview não substitui screenshots reais do emulador.

Antes de incorporar um arquivo, registrar autor, origem, licença e ferramenta/formato de exportação. Não usar assets de filmes, séries, quadrinhos ou outros jogos apenas por servirem de inspiração.

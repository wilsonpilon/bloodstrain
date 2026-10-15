# Fontes

- `main.c`: entrada e saída do programa DOS2.
- `ui/title.c`: carregamento de imagens, introdução em seis quadros, legendas,
  título, controles e limpeza do teclado antes do retorno ao DOS.
- `core`: ciclo principal e serviços comuns futuros.
- `world`: áreas, colisão e transições futuras.
- `actors`: protagonista, pet, NPCs e inimigos futuros.
- `systems`: inventário, progressão, diálogos, facções e save futuros.
- `audio/intro_music.c`: partitura original, sequenciador PSG/FM/SCC por H_TIMI,
  detecção das expansões, ajuste 50/60 Hz e encerramento seguro.
- `ui`: apresentação, menus e interface.

As pastas futuras não representam sistemas implementados. Interfaces públicas ficam em `include`. Módulos de projeto devem ter nomes de arquivo-base distintos: o build MSXgl achata os objetos no diretório de saída.

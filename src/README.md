# Fontes

- `main.c`: entrada e saída do programa DOS2.
- `ui/title.c`: abertura mínima.
- `core`: ciclo principal e serviços comuns futuros.
- `world`: áreas, colisão e transições futuras.
- `actors`: protagonista, pet, NPCs e inimigos futuros.
- `systems`: inventário, progressão, diálogos, facções e save futuros.
- `audio`: integração com players e efeitos futuros.
- `ui`: apresentação, menus e interface.

As pastas futuras não representam sistemas implementados. Interfaces públicas ficam em `include`. Módulos de projeto devem ter nomes de arquivo-base distintos: o build MSXgl achata os objetos no diretório de saída.

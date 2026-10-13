# Screenshots

Guardar somente capturas reais da execução, com versão, máquina, emulador e contexto.

## 1.1.4 — captura recomendada

- [Abertura](bloodstrain-1.1.4-title.png).
- [DOS após ESC](bloodstrain-1.1.4-dos.png).

O teste confere as cores diretamente no PNG, além da VRAM, e espera a renderização antes de sair.

## 1.1.3

- [Abertura](bloodstrain-1.1.3-title.png).
- [DOS após ESC](bloodstrain-1.1.3-dos.png), com resposta ao comando `ECHO RETURN_OK`.

O teste aguarda a captura ser renderizada antes de injetar ESC.

## 1.1.2 — reteste

- [Abertura](bloodstrain-1.1.2-title.png).
- [DOS após ESC](bloodstrain-1.1.2-dos.png), com resposta ao comando `ECHO RETURN_OK`.

Captura da abertura refeita sem recompilar durante os testes de temporização.

Capturadas pelo smoke test de Bloodstrain em 2026-10-13, no openMSX 21.0:

- Philips NMS 8255, MSX2, V9938, 128 KiB de VRAM.
- 128 KiB de RAM interna e mapper externo de 512 KiB.
- Cartucho MSX-DOS 2 e mídia de sistema privada; jogo em B:.
- Captura `screenshot -raw` do emulador, sem arte conceitual ou montagem.

Crédito da captura: teste automatizado do projeto com openMSX; conteúdo renderizado pelo jogo, fonte provisória da MSXgl. Capturas e resultados não comprovam funcionamento em hardware físico.

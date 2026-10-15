# Screenshots

Guardar somente capturas reais da execução, com versão, máquina, emulador e contexto.

## 1.1.10 — release consolidado

- [Tela de título em destaque no README](bloodstrain-1.1.10-title.png).
- [Carga e diagnóstico](bloodstrain-1.1.10-loading.png).
- [Cartão da introdução](bloodstrain-1.1.10-card.png).
- [DOS após ESC](bloodstrain-1.1.10-dos.png).

openMSX 21.0, Philips NMS 8255, mapper 512 KiB e DOS2, 2026-10-15.
Capturas do pipeline com PSG; a tela de título aparece no início e no fim
da sequência e permite iniciar/rever a introdução. Ainda não há gameplay.

## 1.1.8 — trilha e diagnóstico

- [Carga e hardware](bloodstrain-1.1.8-loading.png).
- [Título](bloodstrain-1.1.8-title.png).
- [Cartão](bloodstrain-1.1.8-card.png).
- [DOS após ESC](bloodstrain-1.1.8-dos.png).

openMSX 21.0, Philips NMS 8255, mapper 512 KiB e DOS2, 2026-10-15.
A captura de carga do pipeline usa PSG sem expansões de som: só PSG tem tique.
Testes separados com FM-PAC e SCC validam os outros indicadores e a música.

## 1.1.7 — cache e cartões de texto

- [Título](bloodstrain-1.1.7-title.png).
- [Cartão de texto](bloodstrain-1.1.7-card.png).
- [DOS após ESC](bloodstrain-1.1.7-dos.png).

Mesma configuração MSX2/DOS2 da 1.1.5, em 2026-10-15. O teste verifica imagens
ZX0 descomprimidas no mapper, cartões, transições em até 1,5 s de tempo emulado,
ausência de OPEN/READ após a pré-carga e devolução dos 14 segmentos ao sair.
As demais capturas e medições por quadro ficam em `build/smoke`.

## 1.1.5 — abertura narrativa atual

- [Título ilustrado](bloodstrain-1.1.5-title.png).
- [DOS após ESC](bloodstrain-1.1.5-dos.png), com `ECHO RETURN_OK`.

Capturas reais de 2026-10-15, openMSX 21.0, Philips NMS 8255, V9938/128 KiB
de VRAM, DOS2 e mapper externo de 512 KiB. O teste percorreu os seis quadros,
comparou cada ilustração completa na VRAM e os 32 bytes da paleta, testou
SPACE/ENTER, replay, S e ESC. Os seis quadros capturados ficam em `build/smoke`.
O storyboard em `assets/art/export` é uma prévia gerada, não uma captura.

## 1.1.4 — fundação anterior

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

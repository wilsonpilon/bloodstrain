# Dependências, atribuições e licenças

## Trabalho original

As contribuições originais de Bloodstrain são disponibilizadas sob **GNU GPL versão 3, exclusivamente (GPL-3.0-only)**. O texto completo está em [LICENSE](LICENSE).

## MSXgl e fonte provisória

- Projeto: [MSXgl](https://github.com/aoineko-fr/MSXgl).
- Autor principal: **Guillaume “Aoineko” Blanchard**, com colaboradores.
- Licença declarada da biblioteca: **Creative Commons Attribution-ShareAlike 4.0 International**.
- Texto: [licenses/MSXgl-CC-BY-SA-4.0.txt](licenses/MSXgl-CC-BY-SA-4.0.txt), cópia da licença fornecida na dependência.
- Uso: módulos C, startup DOS, headers, ferramentas de build e configuração do template MSX2.
- Fonte provisória: `engine/content/font/font_mgl_sample6.h`, autoria indicada como Guillaume “Aoineko” Blanchard, dados gerados por MSXimg. Seu aviso CC BY-SA é preservado.
- Mudanças: não alteramos os fontes da MSXgl. Bloodstrain substitui a aplicação demonstrativa do template por código próprio e inclui a configuração original com overrides locais para DOS e vídeo.
- Os fontes correspondentes da biblioteca vinculada e da fonte estão incluídos no `SOURCE.zip`; os avisos originais permanecem neles.

**Não se afirma que a MSXgl foi relicenciada.** Seus elementos originais continuam sob CC BY-SA 4.0. A GNU GPLv3 é uma licença de adaptação compatível indicada pela Creative Commons; essa compatibilidade não remove atribuição, avisos ou direitos sobre o material original. Referência: [licenças compatíveis](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses/).

Módulos externos da biblioteca podem ter outras licenças. Ao incorporar novos players, fontes ou recursos, verificar os avisos específicos antes de vinculá-los; não presumir que todos têm a licença geral.

## ZX0

A abertura usa o compressor ZX0 v2.2 no formato v2 e o descompressor
`ZX0_UnpackToRAM` da MSXgl. Formato/algoritmo por Einar Saukas; decoder por
Einar Saukas, Urusergi e colaboradores. O compressor é ferramenta de build,
não integra o COM; seu aviso declara BSD-3. O aviso fornecido permite usar os
descompressores inclusive comercialmente, exigindo crédito ao ZX0, registrado
aqui. Veja [o aviso original](MSXgl/tools/compress/ZX0/license.txt).
Os avisos dos fontes vinculados permanecem no SOURCE.zip.

## SDCC — compilador

[Small Device C Compiler](https://sdcc.sourceforge.net/), equipe SDCC e colaboradores. Compilador identificado localmente como 4.6.0. A distribuição traz `COPYING.txt`, `COPYING3.txt` e avisos de runtime. O compilador não integra o ZIP do jogo. Preservar os avisos da distribuição ao compartilhar a pasta de ferramentas.

## msxDiskUtil

Ferramenta externa usada para criar e verificar o DSK; não vinculada ao COM.

- Arnold Metselaar: versão original dos utilitários.
- Wilson “Barney” Pilon: adaptação e projeto local atual.
- A versão local é uma reescrita em PureBasic, distribuída sob GPLv3, segundo seu README.
- [Fontes e documentação locais](msxDiskUtil/README.md).
- O build extrai apenas `msxdisk.exe` do ZIP local para `tools/local`. O executável não é incluído no pacote do jogo.

## Editor, assistência e emulador

- **Visual Studio Code:** Microsoft e colaboradores.
- **Copilot SDK em VS Code:** assistência na programação e documentação; revisão final humana.
- **openMSX:** equipe openMSX e colaboradores.

São ferramentas de desenvolvimento; não integram o executável nem são redistribuídas no pacote.

## MSX-DOS e ROMs

Não redistribuídos. A mídia de DOS e as ROMs usadas em testes locais são dependências do ambiente do usuário, não assets do jogo.

## Assets próprios e referências culturais

Na versão 1.1.5 foram adicionadas sete ilustrações originais, paleta e lettering
de placas/título, gerados por [intro.js](assets/art/source/intro.js). Produzidos
com assistência do Copilot a partir do roteiro e direção do criador, sob
GPL-3.0-only, sem imagens, fontes ou músicas externas. O texto exibido em runtime
continua usando a fonte da MSXgl, com seus avisos preservados.

Na 1.1.8, a composição "Madrugada de Ferrugem", partitura, arranjos PSG/FM/SCC
e ondas SCC são contribuições originais assistidas pelo Copilot, sob
GPL-3.0-only. Não foram usados músicas, samples ou partituras de terceiros.
Os instrumentos FM de fábrica pertencem ao próprio YM2413; o acesso aos chips
e sua detecção usam os módulos PSG, MSX-Music e SCC da MSXgl.

A referência a loading screens do ZX Spectrum e a filmes B dos anos 1980 é
estilística: retículas, montagem de capa e cores contrastantes, sem reproduzir
composições, personagens ou logotipos de terceiros.

Raccoon City (Resident Evil) e Alexandria (The Walking Dead) são referências editoriais nos nomes de ciclos. Não há afiliação ou endosso, nem uso de arte, música, logotipos ou roteiro dessas franquias.

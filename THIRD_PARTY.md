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

## SDCC

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

Nenhuma arte ou música própria foi adicionada na versão fundadora. Registrar cada contribuição futura com autor, origem, licença e modificações.

Raccoon City (Resident Evil) e Alexandria (The Walking Dead) são referências editoriais nos nomes de ciclos. Não há afiliação ou endosso, nem uso de arte, música, logotipos ou roteiro dessas franquias.

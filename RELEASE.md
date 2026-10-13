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

**Pacote recomendado:** `dist\Bloodstrain-1.1.4.zip`. Executável e DSK também estão em `dist\Bloodstrain-1.1.4`.

Acrescentar próximos patches com versão, data, alterações, artefatos e testes. O pipeline gera números e arquivos, mas cabe à sessão de desenvolvimento registrar aqui o significado de cada patch.

# Bloodstrain — manual do jogo

**1.1.17 — Alexandria — Fundações e abertura**  
Linha 1 — Raccoon City. Manual da abertura e do protótipo de exploração.

## Sobre esta versão

A versão **1.1.17** apresenta uma tela ilustrada de carregamento/título e uma
introdução em seis quadros com legendas, alternados com seis cartões de texto.
Acrescenta cinco áreas conectadas para testar caminhada e colisão.
Ainda não é possível jogar a campanha.
As imagens são arte original em SCREEN 5, 256 × 212, com paleta própria de 16 cores.
O mapa usa tons frios e escuros, sombras e detalhes amarelados, preservando
a aparência de bairro bem cuidado dos anos 1980. A revisão visual não muda
os caminhos, as colisões ou os controles.
Na 1.1.13, a protagonista recebe cabelos castanhos, óculos, jaqueta rocker,
jeans e botas em um sprite de 16 × 24 pixels, com quatro direções e duas
fases de caminhada. Os pés continuam sendo a referência para colisão.
Na 1.1.14, cabeça menor e pernas mais longas refinam as proporções; a
caminhada alterna as duas pernas com passagem pela pose neutra e movimento
dos braços. A personagem deixa de animar quando para ou esbarra.
Na 1.1.15, a nova referência substitui a jaqueta por camiseta preta estampada,
braços à mostra e pulseiras, com jeans cinza e botas. O desenho passa a
16 × 32 pixels para dar espaço ao cabelo e às proporções, sem mudar a
pegada dos pés. Corrida, salto e golpes da referência ainda não são comandos.
Na 1.1.16, avanço e recuo dos braços ficam mais evidentes durante as passadas
nas quatro direções, preservando a aparência, a velocidade e os controles.

## A história

Mooca, São Paulo, numa versão ficcional de 1982–1984. Uma viajante retorna
do Sudeste Asiático com uma infecção desconhecida. Um acidente nas obras de
um hospital leva a contaminação à água do bairro. Sem saber do surto, uma jovem
metaleira se prepara para ir ao mercado antes de passar a madrugada entre
videogames, programação e música.

Nesta demonstração você acompanha o começo dessa história e pode testar uma
quadra separada. A campanha definitiva começará no quarto da protagonista,
não na rua. Objetivos e combate ainda não estão implementados.

## Requisitos

- MSX2 ou compatível.
- MSX-DOS 2 funcionando.
- Unidade de disco ou armazenamento acessível ao DOS.
- Máquina de referência do projeto: 512 KiB de RAM mapper, com pelo menos
  224 KiB livres no mapper principal para as imagens da introdução.
- PSG interno, padrão do MSX. FM (MSX-Music/YM2413) e SCC são opcionais e
  enriquecem a trilha quando detectados; nenhum dos dois é exigido.

## Executar no computador

1. Inicie seu MSX-DOS 2.
2. Copie `BLOODSTR.COM`, `INTRO.PAK` e `WORLD.PAK` para
   a **mesma pasta**. Execute a partir dessa pasta/unidade; não copie só o COM.
3. No prompt, entre nessa pasta/unidade e digite:

```text
BLOODSTR
```

4. Pressione **ESC** para sair e retornar ao DOS.

## Executar o DSK em emulador

O arquivo `Bloodstrain-X.Y.Z.dsk` é um **disco de dados FAT12 de 720 KiB**, não um disco de boot.

1. Configure uma máquina MSX2 com RAM mapper, DOS 2 e ROMs obtidas legitimamente.
2. Inicie MSX-DOS 2 com sua mídia de sistema.
3. Insira o DSK do jogo em outra unidade, por exemplo B:, ou troque a mídia depois do boot conforme seu ambiente.
4. No DOS:

```text
B:
BLOODSTR
```

Não distribuímos `MSXDOS2.SYS`, `COMMAND2.COM` ou ROMs do computador. Não basta inserir o DSK em uma máquina sem DOS 2 e esperar que ele inicie sozinho.

### Disco inicializável para uso local

Para reunir o jogo e os arquivos DOS2 já presentes na sua cópia da MSXgl:

```powershell
.\scripts\local-disk.ps1 -Test
```

O script usa o pacote da versão atual, cria o disco de 720 KiB
`temp\bloodstrain-current.dsk` (pasta ignorada pelo Git) e testa no openMSX.
O nome é fixo: cada execução substitui o disco anterior, sem recompilar nem
aumentar a versão. A substituição ocorre somente após a geração e, com
`-Test`, a validação bem-sucedidas, preservando o disco anterior em caso de falha.
O disco contém `MSXDOS2.SYS`, `COMMAND2.COM`, o COM, `INTRO.PAK`, `WORLD.PAK` e um
`AUTOEXEC.BAT` que inicia o jogo automaticamente. Para selecionar outro pacote,
use `-PackagePath`. Sem `-Test`, apenas cria o disco.

Insira esse DSK na unidade A: e reinicie uma máquina com suporte ao MSX-DOS 2
e RAM mapper. Os arquivos de sistema no disco não substituem a ROM/cartucho
DOS2 exigida pela configuração do emulador. ESC retorna ao prompt A:.
Este disco é privado/local: não entra no ZIP do release nem no controle de
versão; a presença do DOS na MSXgl não estabelece permissão de redistribuição.

## Controles atuais

| Entrada | Ação |
|---|---|
| SPACE ou ENTER | Inicia a introdução e avança uma ilustração ou cartão de texto |
| S | Pula a introdução e mostra o título |
| SPACE ou ENTER no título final | Revê a introdução |
| M no título | Abre o protótipo da quadra |
| Setas no mapa | Caminha em quatro direções |
| ESC no mapa | Retorna ao título e recarrega a abertura |
| ESC na abertura | Retorna ao MSX-DOS, inclusive durante a leitura dos quadros |

As legendas aguardam o jogador: não há avanço automático. Solte a tecla entre
avanços. Durante a leitura de um arquivo, aguarde o carregamento terminar.
Não há campanha, seleção de classe ou suporte a joystick nesta versão.

### Explorar a quadra

Pressione **M** após a carga. Você começa diante do mercadinho na Rua do
Oratório, com a farmácia em frente. Atravesse as portas para entrar e sair;
não é preciso apertar um botão. Caminhe pelas bordas esquerda/direita para
trocar de tela. Mesas, prateleiras, fachadas, postes e outros obstáculos
bloqueiam os pés da personagem.

- **Oeste:** acesso à Rua Criciumal, em direção à casa.
- **Centro:** mercadinho e farmácia, ambos com interior visitável.
- **Leste:** viela com entrada secundária do mercado, acesso ao teatro ao
  norte e indicação da delegacia a leste.
- **Sul:** limite fechado, sem ligação com outra rua.

As continuações para casa, teatro e delegacia ainda não levam a novas áreas:
a interface avisa “CONTINUACAO FORA DESTA DEMO”. A arte e o sprite são
provisórios. Não há itens coletáveis, NPCs, combate ou estados persistentes.
O mapa fica silencioso; a música volta com a abertura ao sair pelo ESC.

## Conteúdo esperado na tela

Uma barra acompanha a carga e descompressão inicial do pacote ZX0 na RAM mapper.
A carga também mostra a geração MSX/MSX2/MSX2+/turbo R, capacidade do mapper
principal e RAM livre no DOS antes de reservar o cache. Um tique verde identifica
PSG, FM e SCC disponíveis; caixa vazia significa expansão não encontrada.
O PSG é parte padrão de qualquer MSX. A identificação é da geração, não do
fabricante/modelo comercial.

O título e a música começam quando todas as imagens estão prontas.
SPACE/ENTER abre a sequência: viagem ao Sudeste
Asiático, mordida, voo de volta, hospital em obras, água contaminada e a jovem
em seu quarto antes de sair ao mercado. Cada ilustração é seguida de um cartão
curto que amplia o contexto. Ao terminar, volta ao título. Transições e replay
não releem o disco; os segmentos reservados são liberados ao sair.

As legendas são um resumo, não a íntegra do roteiro. Usam texto sem acentos por
limitação da fonte atual.

### Música da abertura

**Madrugada de Ferrugem** é uma composição original de heavy metal sombrio,
com atmosfera de terror trash dos anos 1980: 136 BPM, 32 compassos e cerca de
56 segundos em loop. Toca continuamente no título, nas ilustrações e nos cartões.
O avanço manual não reinicia a partitura; ESC silencia todos os chips usados.

- **PSG:** baixo pulsante, melodia e percussão, formando o arranjo completo básico.
- **FM:** guitarras distorcidas em quintas, com timbre original de alto
  feedback e ataque curto, cordas e reforço melódico.
- **SCC:** ondas originais saturadas, riffs graves e voz aguda
  fantasmagórica, mesmo sem FM.

Na 1.1.9, baixo e percussão PSG ganharam mais ataque e bumbo duplo em galope;
FM e SCC usam cortes de volume para dar uma articulação tipo palm mute.

FM aqui é MSX-Music/YM2413 (interno ou FM-PAC); MSX-Audio/Y8950 não é suportado.
A partitura e os timbres ficam no executável, sem carga extra durante a intro.

## Solução de problemas

- **Não dá boot pelo DSK:** comportamento esperado; inicie o DOS 2 separadamente.
- **`BLOODSTR` não encontrado:** confira a unidade atual e a presença de `BLOODSTR.COM`.
- **Sem música:** aguarde o fim da pré-carga e confira volume/saída de áudio.
  Mesmo sem FM/SCC, o PSG deve tocar. Caixa FM vazia é normal sem MSX-Music;
  hardware físico e diferentes expansões ainda precisam de validação.
- **Erro ao carregar imagem:** mantenha `INTRO.PAK` junto do COM da mesma versão.
  O arquivo é verificado por tamanho e CRC16 de cada bloco antes da descompressão.
  A tela identifica arquivo e erro; pressione
  SPACE/ENTER ou ESC para retornar ao DOS. Não há substituição silenciosa da arte.
- **RAM mapper insuficiente:** libere pelo menos 14 segmentos de 16 KiB
  (224 KiB) no mapper principal e use uma configuração DOS2 com 512 KiB.
- **Erro WORLD.PAK:** mantenha o arquivo junto do COM da mesma versão.
  A leitura verifica tamanho e CRC16 antes de descomprimir; ESC retorna ao DOS.
- **Falha ao compilar em outra máquina:** consulte o README; preserve a MSXgl completa e use uma pasta sem espaços no Windows.

## Recursos ainda não disponíveis

Campanha, combate, escolhas, classes, pet, inventário, facções, diálogos,
estados persistentes e salvamento. A exploração disponível é apenas o teste
de cinco áreas; suas regras serão ampliadas quando implementadas.

## Licença e suporte

O software é fornecido sem garantia, sob GPLv3 para as contribuições originais.
Consulte `LICENSE` e `THIRD_PARTY.md`.

# Bloodstrain — conversa de início

**Data:** 2026-10-13  
**Finalidade:** preservar a pergunta do criador e a resposta inicial de viabilidade para continuar o projeto em outro computador ou com outra IA.

Esta conversa é o ponto de partida, **não o status atualizado**. Leia [OUTLINE.md](OUTLINE.md) para saber o que realmente foi implementado, [README.md](README.md) para a visão geral e [RELEASE.md](RELEASE.md) para os releases.

## Pergunta original do criador

Texto preservado, inclusive a redação original:

> Como um programador MSX 2 com um computador com MSX-DOS 2, 512Kb de RAM, SCC e FM e PSG, e usando o SDCC +  MSXgl (que esta baixada em MSXgl/*), vamos criar um jogo do estilo RPG de acao. O problema, eu tenho a ideia, o roteiro, os desdobramentos, classes, ambiente e tudo mais, porem 1) nao sei desenhar bem, principalmente no MSX, e nao sei escrever musicas complexas ou efeitos sonoros legais. Pensando em tudo isso, o qual viavel e a ideia de programarmos juntos este jogo com voce me auxiliando na arte, sprites, sons e musica? alem da programacao geral da MSXgl que conheco pouco? O jogo nao tem muitos inimigos simultaneos na tela, mas tem muitos dialogos e camnhos diferentes que podem ser usados. O jogo tem um personagem principal escolhido dentre 3 classes, e um pet que tambem tem atributos que evoluem, iventario limitado, faccoes inimigas, faccoes amigas, uma pessoa que vai ser uma alidada importante, zumbies de 2 ou 3 tipos e um inimigo como chefao final. Alocalidade e um unico bairro de sao paulo com sete ou oito pontos principais e backtracking. O RPG tem elementos de adenture, na verdade acho mais que ele e um adventure com elementos de RPG do que um RPG em si.

## Resposta inicial

Conteúdo da resposta preservado; links locais foram ajustados para caminhos relativos, para funcionar em outro computador.

**Sim — é viável programarmos esse jogo juntos, inclusive com minha ajuda na arte, nos sprites, nos efeitos sonoros e na música.** E a sua descrição tem uma vantagem importante: ela combina um mundo relativamente pequeno com profundidade narrativa, em vez de depender de dezenas de inimigos ou de um mapa gigantesco.

Eu o trataria como **um adventure de ação com progressão de RPG**. Isso ajuda a priorizar exploração, personagens, escolhas e consequências, sem construir um sistema de RPG enorme que talvez nem seja necessário.

Conferi a biblioteca disponível: a [MSXgl](MSXgl/README.md) suporta executáveis MSX-DOS 2, PSG, SCC, MSX-Music e vários formatos de música e efeitos. Também há um [template para MSX2](MSXgl/projects/template_msx2/) e suporte a [gerenciamento de RAM pelo mapper do DOS](MSXgl/engine/src/dos_mapper.h). Portanto, temos uma base técnica adequada.

### Como posso ajudar com arte e áudio

Não precisamos esperar que você aprenda a desenhar ou compor antes de começar. Podemos desenvolver os recursos junto com o jogo, por iterações.

| Área | O que posso fazer |
|---|---|
| **Cenários** | Definir paleta e linguagem visual; criar conjuntos de peças reutilizáveis para ruas, fachadas, interiores, objetos e obstáculos. |
| **Personagens** | Criar sprites originais, poses e animações curtas, respeitando as limitações do VDP. |
| **Interface** | Desenhar fonte, ícones, inventário, indicadores e caixas de diálogo. |
| **Efeitos sonoros** | Programar sons de ataque, dano, passos, interação, pet, portas e eventos usando tom, ruído e envelopes. |
| **Música** | Compor motivos originais, melodias, baixos e acompanhamentos, preparando dados para o formato de reprodução escolhido. |
| **Programação** | Implementar e explicar o uso da MSXgl: vídeo, entrada, colisão, áudio, arquivos, mapper, diálogos e salvamento. |

**A ressalva é a qualidade artística: ela exige revisão.** Posso criar e ajustar esses recursos, mas não seria honesto prometer uma direção de arte excelente ou músicas complexas e expressivas já na primeira tentativa. Você será fundamental para avaliar se o resultado transmite o clima da história.

Para esse jogo, isso não precisa ser um problema: uma paleta consistente, silhuetas claras e animações econômicas podem funcionar melhor do que desenhos muito detalhados. Na música, temas curtos e memoráveis podem contribuir mais do que complexidade.

### Como eu aproveitaria esse MSX2

#### Gráficos: começar considerando SCREEN 5

Minha primeira candidata seria a **SCREEN 5: 256 × 212, com 16 cores selecionadas de uma paleta de 512**. É uma boa combinação para cenários urbanos, interface e identidade visual.

Usaríamos peças gráficas reutilizáveis para montar os ambientes, mesmo sendo um modo bitmap. Personagem, pet e inimigos poderiam usar sprites de hardware; cenários e interface seriam desenhados com recursos do VDP.

Há uma restrição importante: o MSX2 permite **até oito sprites por linha horizontal**, e um personagem composto por várias camadas pode consumir mais de um desses sprites. Assim, poucos inimigos ajudam, mas ainda precisamos planejar tamanho, composição e posicionamento — especialmente porque o pet acompanha o protagonista.

#### Mundo: pequeno, mas com estados persistentes

Os sete ou oito pontos principais podem se tornar locais memoráveis, ligados por algumas telas de passagem. Não precisamos fazer um bairro inteiro com rolagem contínua.

**Telas fixas ou transições entre pequenas áreas seriam minha recomendação inicial**, por reduzirem o custo técnico e facilitarem a composição artística. Rolagem continua sendo possível, mas precisa justificar sua complexidade.

O backtracking fica interessante quando o bairro muda:

- um caminho antes bloqueado se abre;
- uma facção passa a controlar uma rua;
- um NPC muda de atitude;
- um local revela algo depois de uma descoberta;
- uma habilidade do protagonista ou do pet permite uma nova interação.

Isso rende bastante conteúdo sem exigir um volume gigantesco de gráficos.

#### Memória: 512 KB ajudam, mas não são um espaço linear

O Z80 acessa **64 KB por vez**; a RAM adicional precisa ser acessada por bancos. Parte da memória também estará ocupada pelo sistema.

Eu manteria o núcleo do jogo e o estado essencial acessíveis, carregando os recursos de cada área conforme necessário. A RAM expandida pode servir para bancos de dados e cache, reduzindo acessos ao disco. A **VRAM é separada desses 512 KB** e precisamos confirmar a capacidade da máquina antes de fechar o orçamento gráfico.

Não tentaria carregar tudo simultaneamente apenas porque existe RAM expandida.

#### Som: aproveitar os chips sem complicar o começo

Uma configuração inicial razoável seria:

- **SCC ou MSX-Music para a trilha**;
- **PSG para efeitos sonoros**;
- um único sistema de reprodução musical bem integrado.

A biblioteca oferece diferentes opções, documentadas no [README da MSXgl](MSXgl/README.md). Escolheríamos o formato conforme o fluxo de composição e o custo de reprodução.

Não começaria com SCC, FM e PSG tocando arranjos complexos simultaneamente. É possível explorar combinações depois; primeiro precisamos de música e efeitos que funcionem juntos, sem conflitos e sem prejudicar o jogo.

### O maior desafio não parece ser o hardware

**São as consequências das escolhas.** Três classes, facções, uma aliada importante e vários caminhos podem multiplicar rapidamente a quantidade de diálogos e situações que precisam ser testados.

A solução é representar a história como dados e estados:

- eventos já ocorridos;
- relações com facções;
- condições para cada fala;
- efeitos das escolhas;
- estado dos locais;
- progressão do protagonista e do pet.

Isso evita espalhar a narrativa em centenas de condições pelo código. Também permite testar combinações e preservar tudo no save.

As três classes podem compartilhar boa parte da campanha, mas oferecer **formas diferentes de resolver situações**, sem exigir três jogos separados.

### Como eu começaria

Antes da campanha inteira, faria **uma fatia pequena, mas jogável**, contendo:

- uma rua e um interior;
- protagonista de uma classe e pet;
- um tipo de zumbi;
- uma interação de combate;
- um NPC com diálogo e escolha;
- um item coletável e inventário limitado;
- uma consequência que continue existindo ao sair e voltar;
- salvamento e carregamento;
- um tema musical curto e alguns efeitos.

Essa fatia valida os pontos difíceis: legibilidade da arte, resposta dos controles, sprites, áudio, persistência e ferramentas de produção. Depois, expandimos com muito menos retrabalho.

**Minha avaliação: o conceito cabe bem nesse equipamento, desde que seja projetado para ele desde o início.** Não vejo motivo para eliminar o pet, as três classes ou os caminhos narrativos agora. Eu limitaria primeiro a complexidade gráfica, a quantidade de animações e a ramificação descontrolada da história — não a identidade do jogo.

Você pode ficar principalmente com o roteiro e as decisões criativas, enquanto eu ajudo a transformá-los em sistemas, gráficos e áudio testáveis. O objetivo é construir algo que tenha personalidade, não apenas uma demonstração técnica da MSXgl.

## Pedido de fundação do projeto

Após a conversa acima, o criador pediu:

- Este registro de início e um guia vivo para continuidade entre máquinas e IAs.
- README com visão, roteiro progressivo, créditos e screenshots.
- CHANGELOG para usuários e RELEASE com detalhes e versões X.Y.Z.
- Apelidos de X/Y do universo zumbi, sem nomes de atores ou diretores; patches sem apelido.
- GPL 3.0.
- Organização segmentada de código, arte, áudio e dados.
- Base a partir do template, exibindo Bloodstrain em abertura simples e colorida, sem artes, na versão **1.1.1**.
- Scripts para preparar, compilar, montar, ligar, gerar executável e DSK com msxDiskUtil e empacotar ZIP com documentação.

O roteiro detalhado ainda não foi fornecido. A próxima sessão deve retomar a partir do [guia vivo](OUTLINE.md), não presumir que a fatia jogável já foi feita.

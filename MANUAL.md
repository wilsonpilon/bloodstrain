# Bloodstrain — manual

## Sobre esta versão

A versão atual **1.1.4** contém apenas uma tela de abertura. Ainda não é possível jogar a campanha. Os patches após a fundação 1.1.1 corrigiram a saída ao DOS e reforçaram as ferramentas e testes. Releases seguintes terão as respectivas funções descritas neste manual e no changelog.

## Requisitos

- MSX2 ou compatível.
- MSX-DOS 2 funcionando.
- Unidade de disco ou armazenamento acessível ao DOS.
- Máquina de referência do projeto: 512 KiB de RAM.
- SCC, FM e PSG fazem parte do alvo futuro; a abertura não produz som.

## Executar no computador

1. Inicie seu MSX-DOS 2.
2. Copie `BLOODSTR.COM` para uma pasta ou unidade acessível.
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

## Controles atuais

| Entrada | Ação |
|---|---|
| ESC | Fecha a abertura e retorna ao MSX-DOS |

Não há comando de “iniciar jogo”, seleção de classe ou suporte de gameplay a joystick nesta versão.

## Conteúdo esperado na tela

Faixa vermelha superior, faixa azul inferior, moldura, nome **BLOODSTRAIN**, versão e mensagem de saída. A aparência é provisória, sem desenhos ou sprites próprios.

## Solução de problemas

- **Não dá boot pelo DSK:** comportamento esperado; inicie o DOS 2 separadamente.
- **`BLOODSTR` não encontrado:** confira a unidade atual e a presença de `BLOODSTR.COM`.
- **Sem música:** comportamento esperado nesta versão.
- **Falha ao compilar em outra máquina:** consulte o README; preserve a MSXgl completa e use uma pasta sem espaços no Windows.

## Recursos ainda não disponíveis

Combate, exploração, escolhas, classes, pet, inventário, facções, diálogos e salvamento. As regras e controles serão documentados quando implementados.

## Licença e suporte

O software é fornecido sem garantia, sob GPLv3 para as contribuições originais. Consulte `LICENSE` e `THIRD_PARTY.md`. Ainda não há endereço público de suporte ou repositório remoto definido.

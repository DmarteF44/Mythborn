# Mythborn — Documento de Gameplay

## 1. Visão Geral

Mythborn é um roguelite de sobrevivência em arena, em visão 2D top-down, no ritmo de jogos como Brotato. O jogador controla um macaco aparentemente comum que, ao longo da progressão narrativa, descobre ser Sun Wukong, o Rei Macaco. O universo pode reunir elementos de diferentes mitologias, mas com identidade visual, narrativa e mecânica própria.

Esta etapa cobre a primeira implementação de referência de um personagem completo — **Sun Wukong** — com evolução por nível, uma build livre construída via uma loja de upgrades unificada, e uma moeda temporária de run (Essência). Ainda com placeholders visuais, sem arte definitiva e sem os sistemas narrativos completos.

## 2. Pilares do Gameplay

- **Ação automática, decisão estratégica**: o jogador não mira nem atira manualmente; as decisões relevantes são movimentação/posicionamento e escolha de upgrades.
- **Builds livres por partida**: cada corrida gera uma combinação diferente de armas e melhorias.
- **Progressão em duas camadas**: progressão permanente/narrativa (entre partidas) + build livre (dentro da partida).
- **Simplicidade legível**: sistemas simples, de fácil leitura visual, mesmo com muitos inimigos e efeitos na tela.

## 3. Controles

- Movimento: **WASD**, ou joystick virtual (toque ou mouse) — 8 direções.
- Sem mira manual: ataques são automáticos.
- Navegação em menus (Menu Principal, Level Up, Pause, Configurações, Game Over): mouse ou toque, todos os botões respondem a ambos.

## 4. Movimento

- Personagem controlado via `CharacterBody2D`, com vetor de entrada normalizado permitindo as 8 direções.
- Velocidade base modificável por upgrades permanentes e de partida.
- Colisão com os limites da arena (paredes simples).

## 5. Combate Automático

- O jogador nunca mira: cada arma equipada ataca sozinha, de forma independente, seguindo seu próprio cooldown.
- Regra de alvo: **cada arma procura o inimigo válido mais próximo dela** dentro do seu alcance e o usa como alvo no momento do ataque.
- Se não houver inimigo dentro de alcance, a arma aguarda o próximo ciclo de cooldown sem atacar.

## 6. Seleção do Inimigo Mais Próximo

- Todo inimigo pertence ao grupo `enemies`.
- O sistema de targeting (compartilhado por todas as armas) varre os inimigos vivos e retorna o mais próximo da posição da arma, respeitando o alcance máximo daquela arma.
- Esse sistema é centralizado para que novas armas só precisem informar posição e alcance — sem duplicar lógica de busca de alvo.

## 7. Sistema de Armas

- Cada arma é uma cena independente com um script que estende uma base comum (`Weapon`), responsável por: cooldown, busca de alvo, e delegar o efeito do ataque (melee, projétil, área, etc.) para a implementação específica.
- Dados de cada arma (dano, cooldown, alcance, nome) ficam em um `Resource` (`WeaponData`), permitindo balancear ou criar variações sem alterar código.
- Upgrades permanentes e de partida (dano, velocidade de ataque) afetam todas as armas do jogador via multiplicadores centralizados, não por arma individual.

### Limite de 12 Armas

- O jogador pode carregar **no máximo 12 armas simultâneas**.
- O inventário de armas (`WeaponInventory`) é a fonte única de verdade sobre quais armas estão equipadas, preparado desde já para adicionar, remover e futuramente evoluir armas. Ele também impede duplicar uma arma que o jogador já possui (`has_weapon`), seja comprando na loja ou recebendo de uma evolução de personagem.

### Armas Implementadas

- **Ruyi Jingu Bang** (Bastão de Sun Wukong): corpo a corpo, alcance curto, dano direto, com um arco de golpe visível e flash de impacto no alvo. Arma inicial de Wukong.
- **Clones de Pelo**: poder característico de Wukong, desbloqueado ao evoluir para SUN WUKONG. Atinge até 2 inimigos próximos por ciclo — pequenos "ataques adicionais" simultâneos ao Bastão.
- **Fagulha Divina**: arma de longo alcance à base de projétil, deliberadamente **sem vínculo com nenhuma mitologia específica** — prova de que a build de Wukong não fica presa a poderes chineses (ver seção "Personagem e Build" abaixo). Desbloqueada ao atingir SUN WUKONG DESPERTADO, ou comprável antes disso na loja.

Todas as três podem coexistir no inventário, cada uma com seu próprio cooldown e alcance, todas usando o mesmo sistema de targeting.

## 8. Experiência (XP)

- Inimigos derrotados soltam um item de XP na posição da morte.
- O jogador coleta o XP ao tocar o item (colisão simples via `Area2D`).
- XP acumulado é somado a uma barra de experiência exibida na interface.

## 9. Level-Up

- Ao atingir o XP necessário, o jogador sobe de nível.
- A ação do jogo é pausada temporariamente.
- O jogador ganha Essência (moeda da run) e um "token" de escolha grátis.
- Se o nível atingido corresponde a uma evolução de personagem (ver seção 10), primeiro aparece a **Tela de Evolução**; só depois disso abre a **Loja de Upgrades**.
- Caso contrário, a Loja de Upgrades abre diretamente.
- O requisito de XP para o próximo nível cresce a cada nível.

## 10. Personagem e Evolução — Sun Wukong

O primeiro personagem jogável completo do Mythborn é **Sun Wukong**, com três estágios ao longo da run:

| Estágio | Nível | Nome exibido | Ganhos |
|---|---|---|---|
| Inicial | 1+ | WUKONG | — |
| Evoluído | 15 | SUN WUKONG | +25% vida, +10% velocidade, +15% dano, desbloqueia **Clones de Pelo** |
| Despertado | 30 | SUN WUKONG DESPERTADO | +20% vida, +15% velocidade, +25% dano, +15% velocidade de ataque, desbloqueia **Fagulha Divina** |

Ao atingir um desses níveis, o jogo mostra uma tela de evolução simples (nome antigo → novo nome, ganhos, novo poder) antes de voltar ao fluxo normal. Os bônus de evolução são multiplicadores separados dos bônus de upgrades da loja — os dois se acumulam sem conflitar.

**Importante**: Sun Wukong não fica limitado a poderes chineses. A Fagulha Divina, por exemplo, é deliberadamente uma arma sem mitologia associada — a build da run pode incluir qualquer combinação de armas/poderes, futuramente de qualquer panteão (Zeus, Anúbis, Thor, Hades...), independente da origem do personagem.

## 11. Loja Unificada de Upgrades

Ao subir de nível, a Loja de Upgrades reúne em uma única tela tudo que o jogador pode adquirir para a build da run:

- **Armas** (ex.: Fagulha Divina) — ocupam um slot do inventário (limite de 12).
- **Poderes** (ex.: Clones de Pelo) — tecnicamente também armas, ocupam slot.
- **Passivas** (ex.: +Dano, +Vida) — não ocupam slot, apenas ajustam multiplicadores do jogador.

Cada oferta mostra categoria, nome, descrição e preço em Essência. Um botão **REROLL** gera um novo conjunto de ofertas por um custo crescente. O jogador pode comprar **múltiplas ofertas na mesma visita** (enquanto tiver Essência), e só fecha a loja manualmente pelo botão **CONTINUAR** — o jogo permanece pausado até lá.

A primeira compra de cada visita à loja é sempre gratuita (consome o "token" ganho ao subir de nível), então subir de nível nunca é frustrante mesmo com pouca Essência acumulada.

### Regras de Oferta

- Uma arma que o jogador já possui nunca é oferecida novamente.
- Se o inventário de armas já estiver no limite de 12, a oferta de arma aparece desabilitada com o motivo explicado ("Inventário de armas cheio"), nunca escondida sem explicação.
- Nenhuma oferta repete o mesmo item na mesma tela.

## 12. Essência (Economia da Run)

- Moeda temporária, existe apenas durante a run atual — não é salva entre partidas.
- Ganha derrotando inimigos e ao subir de nível (bônus fixo + o token de compra grátis).
- Gasta na Loja de Upgrades (compras e reroll).
- Não confundir com progressão permanente: isso ainda não existe no Mythborn.

## 13. Passivas e Poderes de Wukong

Passivas disponíveis nesta etapa (todas empilháveis, cada compra soma o efeito de novo):

- **+Dano**, **+Velocidade de Ataque**, **+Velocidade de Movimento**, **+Vida Máxima**, **+XP Ganho**.
- **Nuvem Ventania**: poder característico de Wukong, mecanicamente uma passiva de velocidade de movimento.

Um upgrade novo é apenas uma entrada de dados a mais — nenhuma dessas passivas exigiu tocar na tela de compra.

## 14. Progressão Narrativa

- Fora do escopo desta etapa a implementação completa, mas a arquitetura deve permitir, futuramente:
  - Desbloqueio gradual da identidade de Sun Wukong.
  - Eventos ou marcos narrativos entre partidas.
  - Novas armas/poderes mitológicos associados a essa progressão.

## 15. Progressão Permanente

- Fora do escopo de implementação nesta etapa (sem loja, sem meta-progressão complexa).
- A arquitetura deve deixar espaço para, futuramente, bônus permanentes persistidos entre partidas (ex.: vida base maior, desbloqueio de armas iniciais).

## 16. Estrutura Básica de uma Partida

1. Jogador entra na arena.
2. Inimigos começam a spawnar periodicamente e perseguem o jogador.
3. Armas equipadas atacam automaticamente os inimigos mais próximos.
4. Inimigos derrotados soltam XP.
5. Jogador coleta XP e sobe de nível, escolhendo melhorias.
6. O ciclo se repete, com inimigos surgindo continuamente, até a morte do jogador (fim de partida).

## 17. Tipos Iniciais de Inimigos

Apenas um tipo nesta etapa:

- **Inimigo Básico (Grunt)**: sem ataque à distância, persegue o jogador em linha reta e causa dano por contato. Vida, velocidade, dano de contato e XP concedido são definidos via dado (`EnemyData`), preparando o terreno para novos tipos apenas com novos dados/cenas.

## 18. Escopo do Protótipo

Incluído nesta etapa:

- Movimento do jogador em 8 direções.
- Uma arena simples e fechada.
- Um tipo de inimigo com spawn contínuo.
- Sun Wukong como personagem jogável, com evolução em 3 estágios (WUKONG → SUN WUKONG → SUN WUKONG DESPERTADO).
- Três armas/poderes (Ruyi Jingu Bang, Clones de Pelo, Fagulha Divina) coexistindo no mesmo inventário.
- Sistema de vida e dano (jogador e inimigos).
- Sistema de XP, level-up, evolução de personagem e Loja Unificada de Upgrades (armas, passivas e poderes, com reroll).
- Essência como moeda temporária da run.
- Inventário de armas preparado para até 12 armas, sem duplicar itens já possuídos.
- Interface mínima (vida, XP, nível, timer, Essência, estágio do personagem, armas atuais).
- Estrutura completa de navegação: Menu Principal, Pause (com Configurações e saída confirmada, sem sobreposição de telas), Game Over com resultados da corrida, e reinício limpo da partida.

## 19. Fluxo Global do Jogo

O jogo agora tem uma estrutura de navegação completa, não apenas a arena:

```
MENU PRINCIPAL
   ↓ (JOGAR)
PARTIDA (PLAYING)
   ↓ (sobe de nível)                      ↓ (botão de pause)
nível de evolução? ─sim→ EVOLUÇÃO         PAUSE
   │não                     ↓ (continuar)    ↓ (continuar)
   ↓                     LOJA DE UPGRADES     │
   └──────────────────→ (compra/reroll) ──────┘
                            ↓ (continuar)
PARTIDA (PLAYING)  ←────────┘
   ↓ (morte do jogador)
GAME OVER / RESULTADOS
   ↓                    ↓
JOGAR NOVAMENTE     MENU PRINCIPAL
```

Estados possíveis (`GameManager.State`): `MAIN_MENU`, `PLAYING`, `EVOLUTION`, `UPGRADE_SHOP`, `PAUSED`, `GAME_OVER`. Evolução, Loja de Upgrades e Pause são três pausas conceitualmente diferentes (duas automáticas por progressão, uma manual pedida pelo jogador), mas todas usam o mesmo mecanismo de pausa da engine e o mesmo caminho de retorno (`resume_gameplay()`). Apenas um estado de UI principal fica ativo por vez — nunca duas telas de pausa sobrepostas.

## 20. Menu Principal

Tela inicial do jogo (`MainMenu.tscn`), com:

- Título "MYTHBORN".
- Botão **JOGAR** — inicia uma partida nova e completamente limpa.
- Botão **CONFIGURAÇÕES** — abre o painel de configurações por cima do menu.
- Uma fileira de botões desabilitados ("Coleção", "Progressão", "Conquistas") reservando espaço visual para funcionalidades futuras — não fazem nada nesta etapa.

## 21. Pause

Acessível durante a partida por um botão discreto no canto superior direito do HUD. Ao pausar:

- todo o gameplay congela (inimigos, timer, ataques, movimentação, ganho de XP) — o mesmo mecanismo de pausa usado na Evolução e na Loja de Upgrades;
- é exibido um painel com **CONTINUAR**, **CONFIGURAÇÕES** e **SAIR DA PARTIDA**;
- ao abrir **CONFIGURAÇÕES**, o painel de Pause fica completamente oculto (nunca as duas telas desenhadas ao mesmo tempo); **VOLTAR** retorna ao Pause, nunca direto ao gameplay;
- **SAIR DA PARTIDA** pede confirmação antes de descartar a corrida atual e voltar ao Menu Principal — o jogador nunca sai de uma partida ativa sem confirmar.

## 22. Configurações

Painel reutilizável (mesma cena instanciada no Menu Principal e no Pause), com três opções realmente funcionais:

- **Som**: muta/desmuta o bus de áudio `SFX`.
- **Música**: muta/desmuta o bus de áudio `Music`.
- **Vibração**: liga/desliga o disparo de vibração do aparelho (usado hoje como feedback ao tomar dano).

As preferências são salvas em `user://settings.cfg` e persistem entre sessões.

## 23. Game Over e Resultados

Ao morrer, o jogador vê imediatamente a tela de Game Over com o resultado da corrida:

- tempo sobrevivido;
- nível alcançado;
- inimigos derrotados;
- upgrades escolhidos.

Dali, pode escolher **JOGAR NOVAMENTE** (inicia uma corrida nova e limpa) ou **MENU PRINCIPAL**.

## 24. Estatísticas da Partida

Dados temporários da corrida atual (não persistem entre partidas) ficam centralizados e são reiniciados a cada nova run: tempo sobrevivido, inimigos derrotados, nível alcançado, upgrades escolhidos e armas possuídas.

## 25. Funcionalidades Planejadas para Etapas Futuras

- Novos personagens (Zeus, Hades, Thor, Anúbis...), reutilizando `CharacterData`/`CharacterProgression`.
- Mais armas/poderes de outras mitologias na build de qualquer personagem.
- Evolução de armas individuais (não apenas do personagem).
- Novos tipos de inimigos e chefes.
- Progressão narrativa completa.
- Progressão permanente entre partidas (meta progression) e desbloqueio de personagens.
- Relíquias (categoria já reservada na loja, sem conteúdo ainda).
- Níveis reais de passivas (Power I/II/III) em vez de empilhar o mesmo bônus repetidamente.
- Localidades e modos de jogo (Endless, Challenge, Boss Rush, Chaos).
- Arte definitiva substituindo os placeholders.
- Balanceamento e ajuste fino de dificuldade e economia de Essência.

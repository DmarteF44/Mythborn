# Mythborn — Documento de Gameplay

## 1. Visão Geral

Mythborn é um roguelite de sobrevivência em arena, em visão 2D top-down, no ritmo de jogos como Brotato. O jogador controla um macaco aparentemente comum que, ao longo da progressão narrativa, descobre ser Sun Wukong, o Rei Macaco. O universo pode reunir elementos de diferentes mitologias, mas com identidade visual, narrativa e mecânica própria.

Esta etapa cobre apenas o **protótipo jogável**: validar o núcleo de gameplay com placeholders, sem arte definitiva e sem os sistemas narrativos completos.

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
- O inventário de armas (`WeaponInventory`) é a fonte única de verdade sobre quais armas estão equipadas, preparado desde já para adicionar, remover e futuramente evoluir armas.
- Nesta etapa apenas uma arma (Bastão) é implementada, mas o inventário já respeita o limite de 12 e está pronto para receber novas armas.

## 8. Experiência (XP)

- Inimigos derrotados soltam um item de XP na posição da morte.
- O jogador coleta o XP ao tocar o item (colisão simples via `Area2D`).
- XP acumulado é somado a uma barra de experiência exibida na interface.

## 9. Level-Up

- Ao atingir o XP necessário, o jogador sobe de nível.
- A ação do jogo é pausada temporariamente.
- São exibidas **3 opções de melhoria** sorteadas aleatoriamente (sem repetição entre si na mesma tela).
- O jogador escolhe **1** das 3 opções; o efeito é aplicado imediatamente e o jogo é despausado.
- O requisito de XP para o próximo nível cresce a cada nível.

## 10. Sistema de Melhorias (Upgrades)

Melhorias disponíveis no protótipo (conjunto inicial, deliberadamente simples):

- **+Dano**: aumenta o multiplicador de dano de todas as armas.
- **+Velocidade de Ataque**: reduz o cooldown de todas as armas.
- **+Velocidade de Movimento**: aumenta a velocidade de deslocamento do jogador.

Os upgrades são definidos como dados (`UpgradeData`), não como código específico espalhado pela base — isso permite adicionar novas melhorias apenas descrevendo seus dados e efeito, sem reescrever a tela de level-up.

## 11. Progressão Narrativa

- Fora do escopo desta etapa a implementação completa, mas a arquitetura deve permitir, futuramente:
  - Desbloqueio gradual da identidade de Sun Wukong.
  - Eventos ou marcos narrativos entre partidas.
  - Novas armas/poderes mitológicos associados a essa progressão.

## 12. Progressão Permanente

- Fora do escopo de implementação nesta etapa (sem loja, sem meta-progressão complexa).
- A arquitetura deve deixar espaço para, futuramente, bônus permanentes persistidos entre partidas (ex.: vida base maior, desbloqueio de armas iniciais).

## 13. Estrutura Básica de uma Partida

1. Jogador entra na arena.
2. Inimigos começam a spawnar periodicamente e perseguem o jogador.
3. Armas equipadas atacam automaticamente os inimigos mais próximos.
4. Inimigos derrotados soltam XP.
5. Jogador coleta XP e sobe de nível, escolhendo melhorias.
6. O ciclo se repete, com inimigos surgindo continuamente, até a morte do jogador (fim de partida).

## 14. Tipos Iniciais de Inimigos

Apenas um tipo nesta etapa:

- **Inimigo Básico (Grunt)**: sem ataque à distância, persegue o jogador em linha reta e causa dano por contato. Vida, velocidade, dano de contato e XP concedido são definidos via dado (`EnemyData`), preparando o terreno para novos tipos apenas com novos dados/cenas.

## 15. Escopo do Protótipo

Incluído nesta etapa:

- Movimento do jogador em 8 direções.
- Uma arena simples e fechada.
- Um tipo de inimigo com spawn contínuo.
- Uma arma automática (Bastão) com dano, alcance e cooldown.
- Sistema de vida e dano (jogador e inimigos).
- Sistema de XP e level-up com 3 escolhas de melhoria.
- Inventário de armas preparado para até 12 armas.
- Interface mínima (vida, XP, nível, timer, arma atual, tela de level-up).
- Estrutura completa de navegação: Menu Principal, Pause (com Configurações e saída confirmada), Game Over com resultados da corrida, e reinício limpo da partida.

## 16. Fluxo Global do Jogo

O jogo agora tem uma estrutura de navegação completa, não apenas a arena:

```
MENU PRINCIPAL
   ↓ (JOGAR)
PARTIDA (PLAYING)
   ↓ (subir de nível)          ↓ (botão de pause)
LEVEL UP  ──────────────→  PAUSE
   ↓ (escolher melhoria)       ↓ (continuar)
PARTIDA (PLAYING)  ←───────────┘
   ↓ (morte do jogador)
GAME OVER / RESULTADOS
   ↓                    ↓
JOGAR NOVAMENTE     MENU PRINCIPAL
```

Estados possíveis (`GameManager.State`): `MAIN_MENU`, `PLAYING`, `LEVEL_UP`, `PAUSED`, `GAME_OVER`. Level Up e Pause são duas pausas conceitualmente diferentes (uma automática por progressão, outra manual pedida pelo jogador), mas ambas usam o mesmo mecanismo de pausa da engine e o mesmo caminho de retorno (`resume_gameplay()`).

## 17. Menu Principal

Tela inicial do jogo (`MainMenu.tscn`), com:

- Título "MYTHBORN".
- Botão **JOGAR** — inicia uma partida nova e completamente limpa.
- Botão **CONFIGURAÇÕES** — abre o painel de configurações por cima do menu.
- Uma fileira de botões desabilitados ("Coleção", "Progressão", "Conquistas") reservando espaço visual para funcionalidades futuras — não fazem nada nesta etapa.

## 18. Pause

Acessível durante a partida por um botão discreto no canto superior direito do HUD. Ao pausar:

- todo o gameplay congela (inimigos, timer, ataques, movimentação, ganho de XP) — o mesmo mecanismo de pausa usado no Level Up;
- é exibido um painel com **CONTINUAR**, **CONFIGURAÇÕES** e **SAIR DA PARTIDA**;
- **SAIR DA PARTIDA** pede confirmação antes de descartar a corrida atual e voltar ao Menu Principal — o jogador nunca sai de uma partida ativa sem confirmar.

## 19. Configurações

Painel reutilizável (mesma cena instanciada no Menu Principal e no Pause), com três opções realmente funcionais:

- **Som**: muta/desmuta o bus de áudio `SFX`.
- **Música**: muta/desmuta o bus de áudio `Music`.
- **Vibração**: liga/desliga o disparo de vibração do aparelho (usado hoje como feedback ao tomar dano).

As preferências são salvas em `user://settings.cfg` e persistem entre sessões.

## 20. Game Over e Resultados

Ao morrer, o jogador vê imediatamente a tela de Game Over com o resultado da corrida:

- tempo sobrevivido;
- nível alcançado;
- inimigos derrotados;
- upgrades escolhidos.

Dali, pode escolher **JOGAR NOVAMENTE** (inicia uma corrida nova e limpa) ou **MENU PRINCIPAL**.

## 21. Estatísticas da Partida

Dados temporários da corrida atual (não persistem entre partidas) ficam centralizados e são reiniciados a cada nova run: tempo sobrevivido, inimigos derrotados, nível alcançado, upgrades escolhidos e armas possuídas.

## 22. Funcionalidades Planejadas para Etapas Futuras

- Múltiplas armas simultâneas até o limite de 12.
- Evolução de armas.
- Novos tipos de inimigos e chefes.
- Poderes mitológicos e identidade de Sun Wukong.
- Progressão narrativa completa.
- Progressão permanente entre partidas (meta progression) e loja.
- Arte definitiva substituindo os placeholders.
- Balanceamento e ajuste fino de dificuldade.

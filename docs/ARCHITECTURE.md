# Mythborn — Arquitetura Técnica (Protótipo)

Referência de gameplay: [`docs/GAMEPLAY.md`](GAMEPLAY.md). Engine: **Godot 4.3**.

## 1. Princípios

- Sistemas desacoplados via **grupos** (`enemies`, `player`) e **sinais**, não via referências rígidas entre nós.
- Dados de balanceamento (armas, inimigos, upgrades) em **Resources** (`WeaponData`, `EnemyData`, `UpgradeData`), separados da lógica de comportamento.
- Comportamento específico (como uma arma ataca, como um inimigo se move) fica em scripts que **estendem uma base comum**, permitindo variações futuras sem alterar o núcleo.
- Placeholders visuais (formas coloridas simples) isolados nos nós `Visual` de cada cena, para serem trocados por sprites reais sem tocar em lógica.

## 2. Estrutura de Pastas

```
scenes/
  main/MainMenu.tscn        # Tela inicial
  main/Main.tscn            # Arena + orquestração da partida
  player/Player.tscn
  enemies/Enemy.tscn
  weapons/Staff.tscn
  pickups/XPGem.tscn
  ui/HUD.tscn
  ui/LevelUpScreen.tscn
  ui/PauseMenu.tscn
  ui/SettingsMenu.tscn      # Reutilizada pelo MainMenu e pelo PauseMenu
  ui/GameOverScreen.tscn    # Acumula também o papel de tela de Resultados
  ui/TouchControls.tscn
scripts/
  core/GameManager.gd       # Autoload — estado global e navegação entre cenas
  core/RunStats.gd          # Autoload — estatísticas da corrida atual
  core/Settings.gd          # Autoload — preferências (som/música/vibração), persistidas
  targeting/TargetingUtils.gd
  combat/Health.gd
  player/Player.gd
  player/PlayerStats.gd
  player/PlayerExperience.gd
  weapons/WeaponData.gd
  weapons/Weapon.gd
  weapons/WeaponStaff.gd
  weapons/WeaponInventory.gd
  enemies/EnemyData.gd
  enemies/Enemy.gd
  enemies/EnemySpawner.gd
  xp/XPGem.gd
  upgrades/UpgradeData.gd
  upgrades/UpgradePool.gd   # Autoload — catálogo de upgrades
  ui/HUD.gd
  ui/LevelUpScreen.gd
  ui/MainMenu.gd
  ui/PauseMenu.gd
  ui/SettingsMenu.gd
  ui/GameOverScreen.gd
  ui/VirtualJoystick.gd
  main/Main.gd
resources/
  weapons/staff_data.tres
  enemies/grunt_data.tres
default_bus_layout.tres     # Buses de áudio: Master, Music, SFX
```

## 3. Autoloads (Singletons)

| Nome | Script | Responsabilidade |
|---|---|---|
| `GameManager` | `core/GameManager.gd` | Estado global (`MAIN_MENU`/`PLAYING`/`LEVEL_UP`/`PAUSED`/`GAME_OVER`), troca entre `MainMenu.tscn` e `Main.tscn`, pausar/retomar, sinal `game_over`, constante `MAX_WEAPONS = 12`. Não guarda lógica de UI nem dados da corrida. |
| `RunStats` | `core/RunStats.gd` | Estatísticas temporárias da corrida atual (tempo, inimigos derrotados, nível, upgrades, armas). Zeradas por `GameManager.start_new_run()`. |
| `Settings` | `core/Settings.gd` | Preferências do jogador (som/música/vibração), persistidas em `user://settings.cfg`. |
| `Upgrades` | `upgrades/UpgradePool.gd` | Catálogo de `UpgradeData` disponíveis e sorteio de opções para o level-up. |

## 4. Responsabilidade de Cada Sistema

### MainMenu (`scenes/main/MainMenu.tscn` + `MainMenu.gd`)
Cena raiz do jogo (`run/main_scene`). Contém o título, os botões JOGAR/CONFIGURAÇÕES e uma instância de `SettingsMenu`. O botão JOGAR apenas chama `GameManager.start_new_run()` — toda a lógica de "o que significa começar uma partida" fica no GameManager, não aqui.

### Main / Arena (`scenes/main/Main.tscn` + `Main.gd`)
Orquestra uma partida: instancia o jogador, a arena (paredes simples), o `EnemySpawner`, o `HUD`, a `LevelUpScreen`, o `PauseMenu` e a `GameOverScreen`. Conecta os sinais dessas peças entre si (level up, pause, game over) e atualiza o `RunStats` conforme a partida avança (nível alcançado, upgrades escolhidos, armas possuídas). Como cada nova partida recarrega esta cena inteira do zero via `change_scene_to_file`, **o reset de estado da partida acontece de graça**: não existe código dedicado a "zerar HP/XP/nível/armas/inimigos" — a cena antiga é descartada pela engine e uma instância nova, limpa, ocupa o lugar.

### PauseMenu (`scenes/ui/PauseMenu.tscn` + `PauseMenu.gd`)
`CanvasLayer` com `process_mode = ALWAYS`, instanciado dentro de `Main.tscn`, escondido por padrão. Aberto pelo botão de pause do HUD (via `Main.gd`, que chama `GameManager.open_pause()` e `pause_menu.open()`). Contém o painel principal (Continuar / Configurações / Sair) e um painel de confirmação de saída, alternados por visibilidade — nunca duas instâncias, apenas dois estados visuais do mesmo nó. "Continuar" chama `GameManager.resume_gameplay()`; "Sair" (após confirmar) chama `GameManager.go_to_main_menu()`, que troca de cena e descarta a partida atual.

### SettingsMenu (`scenes/ui/SettingsMenu.tscn` + `SettingsMenu.gd`)
Painel reutilizável (mesma cena instanciada dentro do `MainMenu` e dentro do `PauseMenu`, cada um com sua própria instância). Não conhece quem o abriu: apenas alterna sua própria visibilidade e lê/escreve no autoload `Settings`. `process_mode = ALWAYS` para funcionar mesmo com o jogo pausado.

### GameOverScreen (`scenes/ui/GameOverScreen.tscn` + `GameOverScreen.gd`)
Acumula o papel de tela de Game Over e de Resultados (simplificação deliberada, já prevista no escopo, para não criar uma tela extra sem necessidade). Ao receber o sinal `GameManager.game_over`, `Main.gd` chama `game_over_screen.show_results()`, que lê o snapshot final em `RunStats` (tempo, nível, inimigos, upgrades) e exibe. "Jogar Novamente" chama `GameManager.start_new_run()`; "Menu Principal" chama `GameManager.go_to_main_menu()`.

### Player (`scenes/player/Player.tscn` + `Player.gd`)
`CharacterBody2D` com movimento em 8 direções via `move_left/right/up/down`. Filhos:
- `Health` (componente de vida/dano).
- `PlayerStats` (multiplicadores: velocidade, dano, velocidade de ataque — o que os upgrades alteram).
- `PlayerExperience` (XP, nível, sinal `leveled_up`).
- `WeaponInventory` (armas equipadas).
- `Camera2D` (segue o jogador por ser filho direto).
- `Visual` (placeholder colorido) + `CollisionShape2D`.

### Enemy (`scenes/enemies/Enemy.tscn` + `Enemy.gd`)
`CharacterBody2D` que persegue o nó do grupo `player`. Vida, velocidade, dano de contato e XP concedido vêm de um `EnemyData` (Resource) exportado, permitindo criar novos tipos de inimigo apenas com novos dados/cenas. Contato com o jogador é detectado por uma `Area2D` filha (`ContactArea`) monitorando a camada física do jogador; ao morrer, spawna `XPGem` e se remove do grupo `enemies` automaticamente (comportamento padrão do Godot ao sair da árvore).

### EnemySpawner (`enemies/EnemySpawner.gd`, nó dentro de `Main.tscn`)
`Timer` que instancia inimigos em posições ao redor da arena em intervalos regulares. Recebe a cena do inimigo e o intervalo como parâmetros exportados — novos tipos de inimigo podem ser adicionados trocando/somando cenas aqui, sem alterar o spawner.

### Weapon / WeaponStaff (`scripts/weapons/`)
- `WeaponData` (Resource): dano, cooldown, alcance, nome — dados puros.
- `Weapon` (base, `Node2D`): possui um `Timer` de cooldown; a cada disparo do timer, usa `TargetingUtils` para achar o inimigo mais próximo dentro do alcance e, se houver, chama `_perform_attack(target)` (método virtual). Lê os multiplicadores de `PlayerStats` para calcular dano/cooldown efetivos.
- `WeaponStaff` (estende `Weapon`): implementa `_perform_attack` como um golpe corpo a corpo — aplica dano diretamente no alvo dentro do alcance e dispara um feedback visual simples.

Novas armas = novo script estendendo `Weapon` + novo `WeaponData`. Armas com comportamento diferente (projétil, área, etc.) sobrescrevem apenas `_perform_attack`.

### WeaponInventory (`weapons/WeaponInventory.gd`, filho do Player)
Lista de armas equipadas (máx. `GameManager.MAX_WEAPONS = 12`). Expõe `add_weapon(scene)` que instancia a arma, injeta a referência ao `PlayerStats` do dono e adiciona à lista, respeitando o limite. Fonte única de verdade sobre "quais armas o jogador tem" — a UI e a lógica de evolução futura devem consultar este nó, nunca contar filhos manualmente.

### Sistema de Targeting (`targeting/TargetingUtils.gd`)
Classe utilitária com função estática `get_closest_enemy(from_position, max_range)`, que varre `get_tree().get_nodes_in_group("enemies")` e retorna o mais próximo dentro do alcance (ou `null`). É a única implementação de busca de alvo do jogo; todas as armas (atuais e futuras) a reutilizam — nenhuma arma implementa sua própria busca.

### Damage / Health (`combat/Health.gd`)
Componente reutilizável (`Node`) com `max_health`, `current_health`, sinais `health_changed` e `died`, e método `take_damage(amount)`. Usado tanto pelo jogador quanto pelos inimigos — a lógica de dano nunca é duplicada entre os dois.

### XP (`xp/XPGem.gd`)
`Area2D` simples: ao detectar o corpo do grupo `player`, emite XP para o `PlayerExperience` do jogador e se destrói. Valor do XP vem do inimigo que o gerou (`EnemyData.xp_value`).

### Level-up / Upgrade (`upgrades/`, `ui/LevelUpScreen.gd`)
- `UpgradeData` (Resource): id, título, descrição, tipo (`DAMAGE` / `ATTACK_SPEED` / `MOVE_SPEED`) e valor do efeito.
- `UpgradePool` (autoload): mantém a lista de `UpgradeData` disponíveis e sorteia 3 sem repetição quando o jogador sobe de nível.
- `LevelUpScreen`: `CanvasLayer` com `process_mode = ALWAYS` (continua funcionando com o jogo pausado), recebe as 3 opções sorteadas, exibe um botão por opção e, ao ser clicado, aplica o efeito diretamente no `PlayerStats` do jogador e pede ao `GameManager` para despausar.

Adicionar um upgrade novo = adicionar uma entrada de dados em `UpgradePool`; não requer alterar a tela de level-up nem o fluxo de aplicação, desde que o efeito já exista em `PlayerStats` (ou que se adicione um novo `case` no `match` de aplicação, para efeitos totalmente novos).

### Game State (`core/GameManager.gd`)
Autoload com o estado global do app (`MAIN_MENU`, `PLAYING`, `LEVEL_UP`, `PAUSED`, `GAME_OVER`), responsável por pausar/despausar a árvore (`get_tree().paused`), trocar entre `MainMenu.tscn` e `Main.tscn`, e centralizar a constante `MAX_WEAPONS`. Não guarda lógica de UI (isso fica nos scripts de cada tela) nem dados de estatística (isso fica em `RunStats`) — apenas estado + navegação + pausa. Level Up e Pause são entradas distintas (`open_level_up()` / `open_pause()`), mas saem pelo mesmo caminho (`resume_gameplay()`), evitando duplicar a lógica de "voltar a jogar".

### RunStats (`core/RunStats.gd`)
Autoload com os dados temporários da corrida atual: tempo sobrevivido (incrementado no próprio `_process`, que para automaticamente quando a árvore está pausada — sem lógica extra de pause), inimigos derrotados, nível alcançado, upgrades escolhidos e armas possuídas. `GameManager.start_new_run()` chama `reset()`; `trigger_game_over()` congela `active = false`. `GameOverScreen` lê esses valores diretamente para montar a tela de resultados.

### Settings (`core/Settings.gd`)
Autoload com as preferências do jogador. Som e música mutam de verdade os buses de áudio `SFX` e `Music` (definidos em `default_bus_layout.tres`); vibração aciona `Input.vibrate_handheld()` (hoje usado como feedback ao tomar dano, em `Player.gd`). Persistido em `user://settings.cfg` via `ConfigFile` — não é meta-progressão de gameplay, apenas preferências do app.

## 5. Como o Targeting Funciona (resumo)

1. Todo `Enemy` entra no grupo `enemies` em `_ready()`.
2. Cada `Weapon`, ao disparar seu `Timer` de cooldown, chama `TargetingUtils.get_closest_enemy(global_position, range)`.
3. Se houver um inimigo dentro do alcance, ele é usado como alvo do ataque; caso contrário, a arma aguarda o próximo ciclo.

## 6. Como Armas São Adicionadas

1. Criar um `WeaponData` (`.tres`) com dano/cooldown/alcance/nome.
2. Criar uma cena de arma com um script estendendo `Weapon`, implementando `_perform_attack(target)` conforme o comportamento desejado (melee, projétil, área...).
3. Registrar a cena em `WeaponInventory.add_weapon(scene)` (respeitando o limite de 12).

## 7. Como Inimigos São Adicionados

1. Criar um `EnemyData` (`.tres`) com vida, velocidade, dano de contato e XP.
2. Reutilizar a cena `Enemy.tscn` trocando o `EnemyData` exportado, ou criar uma variante de cena caso o comportamento (não apenas os números) precise mudar.
3. Apontar o `EnemySpawner` para a nova cena.

## 8. Como Upgrades São Adicionados

1. Criar uma entrada `UpgradeData` (id, título, descrição, tipo, valor) em `UpgradePool`.
2. Garantir que `PlayerStats` (ou o ponto de aplicação do upgrade) saiba tratar o tipo — tipos já existentes (`DAMAGE`, `ATTACK_SPEED`, `MOVE_SPEED`) não requerem nenhuma alteração de código.

## 9. Como o Sistema Pode Crescer

- **Evolução de armas**: `WeaponData` pode ganhar um campo `evolution` apontando para outro `WeaponData`/cena; `WeaponInventory` decide quando trocar a instância.
- **Poderes mitológicos**: podem ser modelados como um novo tipo de "arma" (mesma base `Weapon`) ou como um sistema paralelo de habilidades ativadas por narrativa.
- **Chefes**: nova cena estendendo o mesmo padrão de `Enemy` (Health, grupo `enemies`), com script próprio para padrões de ataque — o targeting e o dano já funcionam sem alteração.
- **Progressão permanente**: um autoload adicional (`MetaProgress`) pode persistir dados entre partidas (ex.: salvar em arquivo, no mesmo padrão de `ConfigFile` já usado por `Settings`) e aplicar bônus iniciais ao `PlayerStats` na criação do jogador.
- **Narrativa**: eventos entre partidas podem ser orquestrados fora da arena (menu/hub), sem impacto na arquitetura de combate.
- **Tela de preparação**: pode ser inserida entre o Menu Principal e a partida como um novo estado (`PRE_GAME`) e uma nova cena, sem alterar o resto do fluxo — `MainMenu` chamaria essa cena em vez de `GameManager.start_new_run()` diretamente, e ela decidiria quando de fato iniciar a run.
- **Coleção / Progressão / Conquistas**: os botões desabilitados já reservados no Menu Principal podem virar cenas próprias, seguindo o mesmo padrão de `PauseMenu`/`SettingsMenu` (CanvasLayer independente, sem lógica de UI dentro do GameManager).

## 10. Limitações Conhecidas

- Botão físico "voltar" do Android ainda não é interceptado — hoje isso é papel do `ui_cancel` (Esc), que só está mapeado dentro da partida para abrir o Pause. Tratar o botão de voltar do sistema operacional fica para uma etapa futura de polimento mobile.
- Não há tela de preparação (`PRE_GAME`) entre o Menu e a partida — por decisão de escopo (ver `docs/GAMEPLAY.md`), o botão JOGAR inicia a run diretamente.

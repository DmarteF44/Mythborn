# Mythborn — Arquitetura Técnica (Protótipo)

Referência de gameplay: [`docs/GAMEPLAY.md`](GAMEPLAY.md). Engine: **Godot 4.3**.

## 1. Princípios

- Sistemas desacoplados via **grupos** (`enemies`, `player`) e **sinais**, não via referências rígidas entre nós.
- Dados de balanceamento (armas, inimigos, upgrades, personagens, evoluções) em **Resources** (`WeaponData`, `EnemyData`, `UpgradeData`, `CharacterData`, `CharacterEvolutionData`), separados da lógica de comportamento.
- Comportamento específico (como uma arma ataca, como um inimigo se move, como um personagem evolui) fica em scripts que **estendem uma base comum**, permitindo variações futuras sem alterar o núcleo.
- Placeholders visuais (formas coloridas simples) isolados nos nós `Visual` de cada cena, para serem trocados por sprites reais sem tocar em lógica.
- Nenhum dado de resource referencia de volta a cena que o carrega (evita ciclos de carregamento) — ex.: `WeaponData` não guarda sua própria cena; quem sabe mapear "dado → cena" é `WeaponPool`.

## 2. Estrutura de Pastas

```
scenes/
  main/MainMenu.tscn        # Tela inicial
  main/Main.tscn            # Arena + orquestração da partida
  player/Player.tscn
  enemies/Enemy.tscn
  enemies/Boss.tscn          # Reaproveita Enemy via BossEnemy.gd
  weapons/Staff.tscn         # Ruyi Jingu Bang
  weapons/HairClones.tscn    # Clones de Pelo
  weapons/Spark.tscn         # Fagulha Divina
  weapons/Projectile.tscn    # Projétil genérico (usado pela Fagulha Divina)
  pickups/XPGem.tscn
  ui/HUD.tscn
  ui/UpgradeShop.tscn        # Loja unificada (ofertas + build em 2 colunas + stats)
  ui/EvolutionScreen.tscn
  ui/PauseMenu.tscn
  ui/SettingsMenu.tscn      # Reutilizada pelo MainMenu e pelo PauseMenu
  ui/GameOverScreen.tscn    # Acumula também o papel de tela de Resultados
  ui/MetaUpgradeScreen.tscn # Tela "Progressão" (meta upgrades)
  ui/AchievementsScreen.tscn# Tela "Conquistas" (somente leitura)
  ui/TouchControls.tscn
scripts/
  core/GameManager.gd       # Autoload — estado global e navegação entre cenas
  core/RunStats.gd          # Autoload — estatísticas da corrida atual
  core/Settings.gd          # Autoload — preferências (som/música/vibração), persistidas
  core/Economy.gd           # Autoload — Essência (moeda temporária da run) + inflação de preço
  core/MetaProgress.gd      # Autoload — conta persistente (moeda, unlocks, records, save)
  core/Achievements.gd      # Autoload — catálogo de conquistas + checagem automática
  core/Locations.gd         # Autoload — registro de localidades + qual está ativa
  core/RunConfig.gd         # Autoload — modo + desafio ativos na run
  core/DifficultyDirector.gd# Autoload — escalonamento de dificuldade (inclui rampa do Endless)
  core/MetaUpgrades.gd      # Autoload — catálogo de melhorias permanentes
  core/Skins.gd             # Autoload — catálogo de skins
  content/UnlockCondition.gd
  content/UnlockConditionChecker.gd
  content/RewardData.gd
  content/RewardResolver.gd
  content/DifficultyModifier.gd
  content/WaveData.gd
  content/LocationData.gd
  content/GameModeData.gd
  content/ChallengeData.gd
  content/BossData.gd
  content/AchievementData.gd
  content/CharacterSkinData.gd
  content/MetaUpgradeData.gd
  targeting/TargetingUtils.gd
  combat/Health.gd
  characters/CharacterData.gd
  characters/CharacterEvolutionData.gd
  characters/CharacterProgression.gd
  player/Player.gd
  player/PlayerStats.gd
  player/PlayerExperience.gd
  player/PlayerPassives.gd
  player/PickupMagnet.gd
  weapons/WeaponData.gd
  weapons/Weapon.gd
  weapons/WeaponStaff.gd
  weapons/WeaponHairClones.gd
  weapons/WeaponSpark.gd
  weapons/Projectile.gd
  weapons/WeaponInventory.gd
  weapons/WeaponPool.gd     # Autoload — catálogo de armas/poderes da loja
  enemies/EnemyData.gd
  enemies/Enemy.gd
  enemies/BossEnemy.gd      # extends Enemy — só adiciona metadados de chefe
  enemies/EnemySpawner.gd
  xp/XPGem.gd
  upgrades/ShopCategory.gd       # Enum compartilhado (WEAPON/PASSIVE/POWER)
  upgrades/ShopOffer.gd          # Oferta efêmera pronta para exibição/compra
  upgrades/UpgradeOfferGenerator.gd
  upgrades/UpgradeData.gd
  upgrades/UpgradePool.gd   # Autoload — catálogo de passivas/poderes-passiva
  ui/HUD.gd
  ui/UpgradeShop.gd
  ui/EvolutionScreen.gd
  ui/MainMenu.gd
  ui/PauseMenu.gd
  ui/SettingsMenu.gd
  ui/GameOverScreen.gd
  ui/MetaUpgradeScreen.gd
  ui/AchievementsScreen.gd
  ui/VirtualJoystick.gd
  main/Main.gd
  main/BossDirector.gd
resources/
  weapons/staff_data.tres
  weapons/hair_clones_data.tres
  weapons/spark_data.tres
  enemies/grunt_data.tres
  enemies/bull_demon_king_enemy_data.tres
  characters/wukong_data.tres
  characters/wukong_stage_1_wukong.tres
  characters/wukong_stage_2_sun_wukong.tres
  characters/wukong_stage_3_awakened.tres
  bosses/bull_demon_king_data.tres
  locations/china_domain.tres
default_bus_layout.tres     # Buses de áudio: Master, Music, SFX
assets/
  characters/wukong.png      # Sprites originais, gerados por código (ver seção 12)
  weapons/ruyi_jingu_bang.png
  enemies/grunt.png
  pickups/xp_gem.png
  ui/icon_*.png               # Ícones da loja (arma/passiva/poder/lock)
```

## 3. Autoloads (Singletons)

| Nome | Script | Responsabilidade |
|---|---|---|
| `GameManager` | `core/GameManager.gd` | Estado global (`MAIN_MENU`/`PLAYING`/`EVOLUTION`/`UPGRADE_SHOP`/`PAUSED`/`GAME_OVER`), troca entre `MainMenu.tscn` e `Main.tscn`, pausar/retomar, sinal `game_over`, constante `MAX_WEAPONS = 12`. Não guarda lógica de UI nem dados da corrida. |
| `RunStats` | `core/RunStats.gd` | Estatísticas temporárias da corrida atual (tempo, inimigos/chefes derrotados, nível, estágio de evolução, upgrades, armas). Zeradas por `GameManager.start_new_run()`. |
| `Settings` | `core/Settings.gd` | Preferências do jogador (som/música/vibração), persistidas em `user://settings.cfg`. |
| `Economy` | `core/Economy.gd` | Essência da run atual: ganhar, gastar, custo de reroll, token de primeira-compra-grátis por level-up, inflação de preço por compra (`purchases_made`). Zerada por `GameManager.start_new_run()`. |
| `Upgrades` | `upgrades/UpgradePool.gd` | Catálogo de `UpgradeData` (passivas e poderes-passiva) disponíveis na loja. |
| `Weapons` | `weapons/WeaponPool.gd` | Catálogo de armas/poderes (`WeaponData` + a cena correspondente) disponíveis na loja. |
| `MetaProgress` | `core/MetaProgress.gd` | **A** conta persistente do jogador: Fragmentos Míticos, personagens/skins/conquistas desbloqueados, nível de cada meta upgrade, recordes. Salva em `user://meta_progress.cfg` (`ConfigFile`, com `version` reservado para migração). Nunca se mistura com `RunStats`/`Economy`. |
| `Achievements` | `core/Achievements.gd` | Catálogo de `AchievementData` + checa automaticamente (via `_process`, só enquanto `RunStats.active`) se alguma condição foi satisfeita, aplicando a recompensa e persistindo em `MetaProgress`. |
| `Locations` | `core/Locations.gd` | Registro de `LocationData` + qual está ativa (`current`) — hoje sempre o Domínio Chinês, sem tela de seleção ainda. |
| `RunConfig` | `core/RunConfig.gd` | Modo (`GameModeData`) e desafio (`ChallengeData`, opcional) ativos na run; combina os dois modificadores + o da localidade em um só (`get_combined_modifier()`). |
| `DifficultyDirector` | `core/DifficultyDirector.gd` | Multiplicador de dificuldade efetivo: `RunConfig.get_combined_modifier()` + uma rampa dependente do tempo assim que `RunStats.survival_time` passa de `current_mode.main_cycle_duration` (o Endless). |
| `MetaUpgrades` | `core/MetaUpgrades.gd` | Catálogo de `MetaUpgradeData` (progressão permanente) + `try_purchase()` (gasta `MetaProgress.currency`, sobe o nível salvo). |
| `Skins` | `core/Skins.gd` | Catálogo de `CharacterSkinData` + qual tint aplicar ao personagem atual (a primeira skin desbloqueada para aquele personagem). |

## 4. Responsabilidade de Cada Sistema

### MainMenu (`scenes/main/MainMenu.tscn` + `MainMenu.gd`)
Cena raiz do jogo (`run/main_scene`). Contém o título, os botões JOGAR/CONFIGURAÇÕES e uma instância de `SettingsMenu`. O botão JOGAR apenas chama `GameManager.start_new_run()` — toda a lógica de "o que significa começar uma partida" fica no GameManager, não aqui.

### Main / Arena (`scenes/main/Main.tscn` + `Main.gd`)
Orquestra uma partida: instancia o jogador, a arena (paredes simples), o `EnemySpawner`, o `HUD`, a `EvolutionScreen`, a `UpgradeShop`, o `PauseMenu` e a `GameOverScreen`. Conecta os sinais dessas peças entre si e decide a **sequência** level-up → (evolução, se houver) → loja → volta a jogar (ver seção 5). Atualiza o `RunStats` conforme a partida avança (nível alcançado, upgrades escolhidos, armas possuídas). Como cada nova partida recarrega esta cena inteira do zero via `change_scene_to_file`, **o reset de estado da partida acontece de graça**: não existe código dedicado a "zerar HP/XP/nível/armas/inimigos/evolução" — a cena antiga é descartada pela engine e uma instância nova, limpa, ocupa o lugar. Apenas os autoloads (`RunStats`, `Economy`) precisam de `reset()` explícito, chamado por `GameManager.start_new_run()`.

### PauseMenu (`scenes/ui/PauseMenu.tscn` + `PauseMenu.gd`)
`CanvasLayer` com `process_mode = ALWAYS`, instanciado dentro de `Main.tscn`, escondido por padrão. Aberto pelo botão de pause do HUD (via `Main.gd`, que chama `GameManager.open_pause()` e `pause_menu.open()`). Contém o painel principal (Continuar / Configurações / Sair) e um painel de confirmação de saída, alternados por visibilidade — nunca duas instâncias, apenas dois estados visuais do mesmo nó. "Continuar" chama `GameManager.resume_gameplay()`; "Sair" (após confirmar) chama `GameManager.go_to_main_menu()`, que troca de cena e descarta a partida atual.

**Correção de bug (Etapa 3)**: abrir Configurações a partir do Pause escondia apenas o painel principal do Pause, mas seu fundo escurecido (`Dim`) continuava visível por baixo do fundo escurecido do próprio `SettingsMenu` — as duas telas ficavam sobrepostas incorretamente. Corrigido fazendo `_on_settings_pressed()` esconder **tanto `Dim` quanto `MainPanel`** do Pause (não só o painel), e `SettingsMenu` agora emite um sinal `closed` que o `PauseMenu` escuta para restaurar sua própria visibilidade — nunca as duas telas desenhadas ao mesmo tempo, e "Voltar" sempre retorna ao Pause (nunca direto ao gameplay).

### SettingsMenu (`scenes/ui/SettingsMenu.tscn` + `SettingsMenu.gd`)
Painel reutilizável (mesma cena instanciada dentro do `MainMenu` e dentro do `PauseMenu`, cada um com sua própria instância). Não conhece quem o abriu: apenas alterna sua própria visibilidade e lê/escreve no autoload `Settings`. `process_mode = ALWAYS` para funcionar mesmo com o jogo pausado.

### GameOverScreen (`scenes/ui/GameOverScreen.tscn` + `GameOverScreen.gd`)
Acumula o papel de tela de Game Over e de Resultados (simplificação deliberada, já prevista no escopo, para não criar uma tela extra sem necessidade). Ao receber o sinal `GameManager.game_over`, `Main.gd` chama `game_over_screen.show_results()`, que lê o snapshot final em `RunStats` (tempo, nível, inimigos, upgrades) e exibe. "Jogar Novamente" chama `GameManager.start_new_run()`; "Menu Principal" chama `GameManager.go_to_main_menu()`.

### Player (`scenes/player/Player.tscn` + `Player.gd`)
`CharacterBody2D` com movimento em 8 direções via `move_left/right/up/down`. Filhos:
- `Health` (componente de vida/dano).
- `PlayerStats` (multiplicadores separados por origem: `move_speed_mult`/`damage_mult`/`attack_speed_mult` vindos de upgrades da loja, somam; `character_*_mult` vindos da evolução do personagem, multiplicam. `get_move_speed()`/`get_damage_mult()`/`get_attack_speed_mult()` combinam os dois conjuntos — quem lê nunca precisa saber a origem).
- `PlayerExperience` (XP, nível, `xp_gain_mult`, sinal `leveled_up`).
- `WeaponInventory` (armas equipadas — aceita cópias/níveis duplicados, ver seção dedicada abaixo).
- `PlayerPassives` (nível atual de cada passiva/poder-passivo por id — ver seção dedicada abaixo).
- `CharacterProgression` (qual personagem, estágio de evolução atual — ver seção "Personagem" abaixo).
- `PickupMagnet` (`Area2D`, raio = `PlayerStats.get_pickup_radius()`; ao detectar uma `XPGem` no raio, chama `start_attracting(player)` nela).
- `Camera2D` (segue o jogador por ser filho direto).
- `Visual` (`Sprite2D` com o sprite de Wukong — ver seção "Assets Visuais") + `CollisionShape2D`.

Em `_ready()`, `Player.gd` lê `progression.character_data` para definir vida/velocidade base e conceder a arma inicial — **nenhum dado de personagem fica hard-coded em `Player.gd`**, apenas a leitura genérica de `CharacterData`. Em seguida, `_apply_meta_upgrades()` aplica os bônus permanentes já comprados (`MetaProgress.get_meta_upgrade_level()` de cada entrada em `MetaUpgrades.pool`) e `Skins.get_equipped_tint()` define a cor do `Visual` — ambos leem de autoloads persistentes, nenhum dos dois é recalculado ou duplicado aqui.

### Personagem (`scripts/characters/`)
- `CharacterData` (Resource): quem o jogador é — id, nome, vida/velocidade base, arma inicial, e a lista ordenada de `CharacterEvolutionData`. Um personagem novo (Zeus, Hades...) é só um novo `.tres` desta classe.
- `CharacterEvolutionData` (Resource): um estágio de evolução — nível necessário, nome exibido, multiplicadores de bônus (vida/velocidade/dano/velocidade de ataque) e, opcionalmente, uma arma/poder concedido (`unlocked_power_scene`) com seu rótulo de UI.
- `CharacterProgression` (componente do Player): a única peça que sabe "em que nível o personagem evolui". `check_level(level)` avança `current_stage_index` enquanto o nível atingido for suficiente, aplica os bônus e concede o poder desbloqueado, retornando os dados da evolução (ou `null`, se nenhuma foi atingida agora). **Nenhum outro sistema verifica `if level >= 15`** — tudo passa por aqui, o que permite reaproveitar exatamente o mesmo componente para qualquer personagem futuro.

Sun Wukong (`resources/characters/wukong_data.tres`) tem 3 estágios: WUKONG (nível 1, base) → SUN WUKONG (nível 15, concede Clones de Pelo) → SUN WUKONG DESPERTADO (nível 30, concede Fagulha Divina). Os números de cada estágio ficam nos `.tres`, nunca na tela de evolução ou no HUD.

### Enemy (`scenes/enemies/Enemy.tscn` + `Enemy.gd`)
`CharacterBody2D` que persegue o nó do grupo `player`. Vida, velocidade, dano de contato e XP concedido vêm de um `EnemyData` (Resource) exportado, permitindo criar novos tipos de inimigo apenas com novos dados/cenas. Contato com o jogador é detectado por uma `Area2D` filha (`ContactArea`) monitorando a camada física do jogador; ao morrer, spawna `XPGem` e se remove do grupo `enemies` automaticamente (comportamento padrão do Godot ao sair da árvore).

### EnemySpawner (`enemies/EnemySpawner.gd`, nó dentro de `Main.tscn`)
`Timer` que instancia inimigos em posições ao redor da arena em intervalos regulares. Recebe a cena do inimigo e o intervalo como parâmetros exportados — novos tipos de inimigo podem ser adicionados trocando/somando cenas aqui, sem alterar o spawner.

### Weapon / Armas concretas (`scripts/weapons/`)
- `WeaponData` (Resource): dano/cooldown/alcance de **nível 1** (base), mais taxas de crescimento por nível (`max_level`, `damage_growth_per_level`, `cooldown_reduction_per_level`, `range_growth_per_level`) — `get_damage_for_level(n)`/`get_cooldown_for_level(n)`/`get_range_for_level(n)` derivam o valor real de cada nível a partir daí, então nenhum número de nível fica hard-coded fora do Resource. Também tem `price` e `shop_category` (para a loja) — dados puros. **Não guarda a cena que a representa** (evitaria uma referência circular com a própria cena que a carrega como `weapon_data`); esse mapeamento fica em `WeaponPool`.
- `Weapon` (base, `Node2D`): representa **uma cópia individual** de uma arma, com seu próprio `current_level` (padrão 1) e `Timer` de cooldown independente. A cada disparo do timer, usa `TargetingUtils` para achar o inimigo mais próximo dentro do alcance efetivo do nível atual e, se houver, chama `_perform_attack(target)` (método virtual). `set_level(n)` (usado pela fusão) troca o nível; `_get_effective_damage()`/`_get_effective_cooldown()`/`_get_effective_range()` combinam o nível atual com os multiplicadores de `PlayerStats`. Expõe `_flash_target(target)`, um feedback de acerto reutilizável (flash no `Visual` do alvo) que qualquer arma pode chamar.
- `WeaponStaff` (Ruyi Jingu Bang): golpe corpo a corpo — dano direto no alvo, arco de swing visível (`SwingVisual` gira entre dois ângulos e desaparece) e flash de impacto.
- `WeaponHairClones` (Clones de Pelo): usa `TargetingUtils.get_enemies_in_range(pos, range, 2)` para atingir até 2 alvos por ciclo, cada um com seu próprio flash — prova de arma com efeito em múltiplos alvos sem precisar de uma base nova.
- `WeaponSpark` (Fagulha Divina) + `Projectile`: arma de longo alcance que instancia um `Projectile` (Area2D simples, velocidade fixa em linha reta, dano ao colidir com o grupo `enemies`) mirado na posição do alvo no instante do disparo.

Novas armas = novo script estendendo `Weapon` + novo `WeaponData`. Armas com comportamento diferente (multi-alvo, projétil, área, etc.) sobrescrevem apenas `_perform_attack`.

### WeaponInventory (`weapons/WeaponInventory.gd`, filho do Player) — Duplicatas e Fusão
Lista de **instâncias** de arma equipadas (máx. `GameManager.MAX_WEAPONS = 12` — o limite é de instâncias, não de tipos diferentes). `add_weapon(scene)` **sempre** cria uma cópia nova e independente (nível 1), mesmo que o jogador já tenha aquela arma — duplicatas são o comportamento correto, nunca bloqueadas. `has_weapon(id)` continua existindo, mas só para fins de exibição ("nova cópia" vs "comprar" na loja), nunca para impedir uma aquisição.

`get_grouped_weapons()` agrupa as instâncias por `(id, nível)` — é o que a `UpgradeShop`/HUD usam para mostrar "Ruyi Lv.1 × 5" em vez de 5 cards repetidos.

`fuse(weapon_id, level)` é a **única** forma de uma arma subir de nível: exige 2 cópias daquele id **no mesmo nível**, é sempre uma escolha explícita do jogador (nunca automática ao comprar/receber uma duplicata), não custa Essência, e reaproveita a instância "sobrevivente" (só chama `set_level()` nela) em vez de destruir e recriar — a outra cópia é removida (`erase` + `queue_free`). Falha (retorna `false`) se não houver 2 cópias no nível pedido ou se já estiver no `max_level` daquela arma.

### PlayerPassives (`player/PlayerPassives.gd`, filho do Player) — Passivas com Nível
Diferente de armas: uma passiva **não tem instâncias múltiplas**, apenas um nível (`Dictionary` id → nível atual, limitado por `UpgradeData.max_level`). `apply(upgrade)` incrementa o nível e despacha o efeito pelo tipo: `VITALITY` chama `Health.apply_max_health_multiplier()`, `XP_GAIN` soma em `PlayerExperience.xp_gain_mult`, `PICKUP_RADIUS` soma em `PlayerStats.pickup_radius_bonus` e atualiza o raio real do `PickupMagnet`, e os demais tipos (`DAMAGE`/`ATTACK_SPEED`/`MOVE_SPEED`) continuam indo por `PlayerStats.apply_upgrade()` como antes. Comprar a mesma passiva de novo **melhora o nível existente**, nunca cria uma segunda entrada.

### PickupMagnet + XPGem — Pickup com Ímã
`PickupMagnet` é uma `Area2D` filha do Player cujo raio (`CollisionShape2D`/`CircleShape2D`) é definido por `PlayerStats.get_pickup_radius()`. Ao detectar uma `XPGem` (via `area_entered`, já que XPGem também é `Area2D`), chama `start_attracting(player)` nela. `XPGem` tem um estado (`IDLE` → `ATTRACTING` → `COLLECTED`): parada até ser notificada, depois acelera suavemente (`attract_acceleration` até `attract_speed`) em direção ao alvo a cada `_physics_process`, e é coletada normalmente por `body_entered` quando encosta no jogador — nunca teleporta, nunca dispara XP duas vezes (guarda de estado `COLLECTED`).

### Sistema de Targeting (`targeting/TargetingUtils.gd`)
Classe utilitária com função estática `get_closest_enemy(from_position, max_range)`, que varre `get_tree().get_nodes_in_group("enemies")` e retorna o mais próximo dentro do alcance (ou `null`). É a única implementação de busca de alvo do jogo; todas as armas (atuais e futuras) a reutilizam — nenhuma arma implementa sua própria busca.

### Damage / Health (`combat/Health.gd`)
Componente reutilizável (`Node`) com `max_health`, `current_health`, sinais `health_changed` e `died`, e método `take_damage(amount)`. Usado tanto pelo jogador quanto pelos inimigos — a lógica de dano nunca é duplicada entre os dois.

### XP (`xp/XPGem.gd`)
`Area2D` simples: ao detectar o corpo do grupo `player`, emite XP para o `PlayerExperience` do jogador e se destrói. Valor do XP vem do inimigo que o gerou (`EnemyData.xp_value`).

### Loja Unificada de Upgrades (`upgrades/`, `ui/UpgradeShop.gd`, `ui/EvolutionScreen.gd`)
- `ShopCategory` (classe utilitária): apenas o enum `Type { WEAPON, PASSIVE, POWER }`, compartilhado por `WeaponData` e `UpgradeData` para que a loja trate os dois tipos de dado de forma uniforme.
- `UpgradeData` (Resource): id, título (level-agnostic, ex. "DANO" — nunca "+20% DANO"), descrição, tipo de efeito (`DAMAGE`/`ATTACK_SPEED`/`MOVE_SPEED`/`VITALITY`/`XP_GAIN`/`PICKUP_RADIUS`), `value` (incremento POR NÍVEL), `max_level`, `price` e `shop_category`.
- `UpgradePool` (autoload): catálogo de passivas (e poderes-passiva, como a Nuvem Ventania de Wukong, que é uma passiva de velocidade rotulada como `POWER`).
- `WeaponPool` (autoload): catálogo de `{data: WeaponData, scene: PackedScene}` — armas/poderes que ocupam slot no inventário.
- `ShopOffer` (classe simples, não persistida): uma oferta pronta para exibição/compra — categoria, dados (arma ou upgrade), preço, título, descrição, `action_label` ("COMPRAR"/"NOVA CÓPIA"/"ADQUIRIR"/"MELHORAR") e um `disabled_reason` opcional.
- `UpgradeOfferGenerator` (classe utilitária estática): **o único lugar que decide o que pode ser oferecido**. Armas de `Weapons.pool` são **sempre** candidatas, mesmo já possuídas (duplicatas são o comportamento desejado) — só ganham `disabled_reason` se o inventário estiver cheio. Passivas de `Upgrades.pool` só entram se `player.passives.can_upgrade()` for verdadeiro (não maxadas); a descrição já mostra "Nível N → N+1" com os percentuais calculados via `format_value()`.
- `UpgradeShop` (`CanvasLayer`, `process_mode = ALWAYS`): tela rolável com duas partes. **Sua Build**: `_render_build_summary()` lê `weapon_inventory.get_grouped_weapons()` e `passives.levels` para montar as linhas, com um botão **FUNDIR** por grupo de arma com 2+ cópias (abre um painel de confirmação `FusionConfirm` antes de chamar `weapon_inventory.fuse()`). **Ofertas**: `UpgradeOfferGenerator.generate_offers()` e cartões montados em código (não uma cena por oferta). Compra: se houver "token" grátis (`Economy.has_free_token()`), consome o token; senão, gasta `Economy`. Aplica o efeito (`weapon_inventory.add_weapon()` para armas/poderes, `player.passives.apply()` para passivas — a lógica de "qual campo de `PlayerStats`/`Health`/etc. cada tipo afeta" mora em `PlayerPassives`, não na UI) e remove a oferta da lista, permitindo múltiplas compras na mesma visita sem gerar um novo conjunto a cada compra. **REROLL** gasta `Economy.get_reroll_cost(n)` (cresce a cada uso) e gera um conjunto novo. Fecha só pelo botão CONTINUAR, emitindo `closed`.
- `EvolutionScreen` (`CanvasLayer`, `process_mode = ALWAYS`): mostra nome antigo → novo, bônus formatados a partir dos multiplicadores de `CharacterEvolutionData`, e o poder desbloqueado (se houver). Emite `continued` ao fechar.

Adicionar uma passiva nova = uma entrada em `UpgradePool`. Adicionar uma arma/poder novo = uma entrada em `WeaponPool` (mais o script/cena da própria arma). Nenhum dos dois exige tocar na `UpgradeShop`.

### Economy (`core/Economy.gd`)
Autoload com a Essência (moeda temporária da run): `add`/`spend`/`can_afford`, custo de reroll (`get_reroll_cost`, cresce por uso), e o "token" de primeira-compra-grátis concedido a cada level-up (`grant_level_up_reward`) — garante que subir de nível nunca seja frustrante mesmo com pouca Essência acumulada. Zerada por `GameManager.start_new_run()`.

### Game State (`core/GameManager.gd`)
Autoload com o estado global do app (`MAIN_MENU`, `PLAYING`, `EVOLUTION`, `UPGRADE_SHOP`, `PAUSED`, `GAME_OVER`), responsável por pausar/despausar a árvore (`get_tree().paused`), trocar entre `MainMenu.tscn` e `Main.tscn`, e centralizar a constante `MAX_WEAPONS`. Não guarda lógica de UI (isso fica nos scripts de cada tela) nem dados de estatística/economia (isso fica em `RunStats`/`Economy`) — apenas estado + navegação + pausa. Evolução, Loja e Pause são entradas distintas (`open_evolution()` / `open_upgrade_shop()` / `open_pause()`), mas saem pelo mesmo caminho (`resume_gameplay()`), evitando duplicar a lógica de "voltar a jogar". `Main.gd` é quem decide a **sequência** entre elas (ver seção 5).

### RunStats (`core/RunStats.gd`)
Autoload com os dados temporários da corrida atual: tempo sobrevivido (incrementado no próprio `_process`, que para automaticamente quando a árvore está pausada — sem lógica extra de pause), inimigos derrotados, nível alcançado, upgrades escolhidos e armas possuídas. `GameManager.start_new_run()` chama `reset()`; `trigger_game_over()` congela `active = false`. `GameOverScreen` lê esses valores diretamente para montar a tela de resultados.

### Settings (`core/Settings.gd`)
Autoload com as preferências do jogador. Som e música mutam de verdade os buses de áudio `SFX` e `Music` (definidos em `default_bus_layout.tres`); vibração aciona `Input.vibrate_handheld()` (hoje usado como feedback ao tomar dano, em `Player.gd`). Persistido em `user://settings.cfg` via `ConfigFile` — não é meta-progressão de gameplay, apenas preferências do app.

## 5. Como o Fluxo Level-up → Evolução → Loja Funciona

Um único lugar decide a sequência: `Main._on_player_leveled_up(new_level)`.

1. `PlayerExperience.leveled_up` dispara.
2. `RunStats.level_reached` é atualizado e `Economy.grant_level_up_reward()` concede Essência + 1 token grátis.
3. `player.progression.check_level(new_level)` é chamado. Se retornar uma `CharacterEvolutionData` (o nível cruzou um estágio novo), `Main.gd` chama `GameManager.open_evolution()` e mostra a `EvolutionScreen`.
4. Só quando a `EvolutionScreen` emite `continued` (ou imediatamente, se não houve evolução), `Main.gd` chama `GameManager.open_upgrade_shop()` e abre a `UpgradeShop`.
5. A `UpgradeShop` emite `closed` ao terminar, e `Main.gd` chama `GameManager.resume_gameplay()`.

Isso garante que **nunca duas telas de pausa apareçam ao mesmo tempo**: evolução e loja são sempre sequenciais, nunca simultâneas, mesmo que múltiplos níveis sejam ganhos de uma vez.

## 6. Como o Targeting Funciona (resumo)

1. Todo `Enemy` entra no grupo `enemies` em `_ready()`.
2. Cada `Weapon`, ao disparar seu `Timer` de cooldown, chama `TargetingUtils.get_closest_enemy(global_position, range)`.
3. Se houver um inimigo dentro do alcance, ele é usado como alvo do ataque; caso contrário, a arma aguarda o próximo ciclo.

## 7. Como Armas São Adicionadas

1. Criar um `WeaponData` (`.tres`) com dano/cooldown/alcance de nível 1, taxas de crescimento por nível e `max_level`.
2. Criar uma cena de arma com um script estendendo `Weapon`, implementando `_perform_attack(target)` conforme o comportamento desejado (melee, projétil, área...).
3. Adicionar `{data, scene}` em `WeaponPool.pool` para que apareça na loja. `WeaponInventory.add_weapon(scene)` sempre cria uma cópia nova (respeitando o limite de 12 instâncias) — duplicatas de uma mesma arma nunca precisam de tratamento especial.

## 8. Como Inimigos São Adicionados

1. Criar um `EnemyData` (`.tres`) com vida, velocidade, dano de contato e XP.
2. Reutilizar a cena `Enemy.tscn` trocando o `EnemyData` exportado, ou criar uma variante de cena caso o comportamento (não apenas os números) precise mudar.
3. Apontar o `EnemySpawner` para a nova cena.

## 9. Como Upgrades/Passivas São Adicionados

1. Criar uma entrada `UpgradeData` (id, título level-agnostic, descrição, tipo, `value` por nível, `max_level`) em `UpgradePool`.
2. Garantir que `PlayerPassives.apply()` saiba tratar o tipo — tipos já existentes (`DAMAGE`, `ATTACK_SPEED`, `MOVE_SPEED`, `VITALITY`, `XP_GAIN`, `PICKUP_RADIUS`) não requerem nenhuma alteração de código.

## 10. Como o Sistema Pode Crescer

- **Novos personagens**: um novo `CharacterData` + seus `CharacterEvolutionData` (Zeus, Hades, Thor, Anúbis...). `CharacterProgression` já é genérico — nenhuma alteração de código é necessária, só apontar `Player.tscn`/uma futura tela de seleção para o `.tres` do personagem escolhido.
- **Relíquias**: `ShopCategory.Type` já reserva espaço conceitual; adicionar `RELIC` ao enum e um `RelicData`/`RelicPool` segue o mesmo padrão de `WeaponPool`/`UpgradePool`.
- **Evolução de arma além do nível máximo** (ex.: Ruyi Jingu Bang Lv.5 + condição → "Ascended"): `WeaponData` ganharia um campo `evolution_scene`/`evolution_condition`; `WeaponInventory.fuse()` já centraliza "o que acontece ao juntar 2 cópias", então essa evolução seria só mais um caso ali quando `level == max_level`.
- **Melhorar arma existente via compra direta** (sem precisar de uma segunda cópia): hoje a única forma de subir o nível de uma arma é a fusão voluntária de 2 cópias iguais; um "upgrade direto" pago em Essência seria um método adicional em `WeaponInventory`, opcional e sem afetar a fusão.
- **Poderes mitológicos de outros panteões**: novas entradas em `WeaponPool`/`UpgradePool`, exatamente como Clones de Pelo e Fagulha Divina foram adicionados — nenhuma delas exigiu tocar na `UpgradeShop`.
- **Chefes**: novo `.tres` de `EnemyData` (stats) + `BossData` (metadados/recompensa) + adicionar em `LocationData.boss_pool` — `Boss.tscn`/`BossEnemy.gd` já são genéricos, nenhuma cena nova é necessária a menos que o comportamento (não só os números) precise mudar.
- **Novas localidades**: um novo `LocationData.tres` com seu `enemy_pool`/`boss_pool`/`wave_profile` próprios; trocar `Locations.current` (via `set_current(id)`) é só o que falta para uma tela de seleção usá-lo.
- **Novos modos/desafios**: uma nova entrada em `RunConfig.game_modes`/`challenges` — cada um é só uma composição de `DifficultyModifier`, nunca código específico.
- **Narrativa**: eventos entre partidas podem ser orquestrados fora da arena (menu/hub), sem impacto na arquitetura de combate.
- **Tela de preparação**: pode ser inserida entre o Menu Principal e a partida como um novo estado (`PRE_GAME`) e uma nova cena, sem alterar o resto do fluxo — `MainMenu` chamaria essa cena em vez de `GameManager.start_new_run()` diretamente, e ela decidiria quando de fato iniciar a run.
- **Coleção**: o botão já reservado no Menu Principal pode virar uma tela própria (personagens/skins/armas/poderes/bosses/inimigos/localidades/conquistas), seguindo o mesmo padrão de `MetaUpgradeScreen`/`AchievementsScreen` (CanvasLayer independente, sem lógica de UI dentro do GameManager).
- **Tela de seleção de Localidade/Modo/Desafio**: toda a lógica (`Locations`, `RunConfig`) já existe e é testável por código; falta só a UI que chama `set_current`/`set_mode`/`set_challenge` antes de `GameManager.start_new_run()`.

## 11. Arquitetura de Conteúdo (Etapa 6)

Consolidação da fundação para conteúdo em escala: localidades, modos, desafios, chefes, conquistas, recompensas, desbloqueios, skins e meta-progressão. Segue o mesmo princípio já usado por armas/passivas: **dados em Resources, catálogos em autoloads pequenos e focados, nenhum `if` específico por item**.

### Blocos de dados reutilizáveis (`scripts/content/`)
- `UnlockCondition` (Resource): condição genérica — `KILLS`/`SURVIVAL_TIME`/`LEVEL_REACHED`/`BOSS_DEFEATED`/`CHARACTER_EVOLUTION`/`ACHIEVEMENT`/`CURRENCY`/`COMBINATION` (AND de sub-condições, cada uma podendo comparar "no mínimo" ou "no máximo"). Avaliada por `UnlockConditionChecker.is_met()`, que só lê fontes já centralizadas (`RunStats`, `Economy`, `MetaProgress`, `Achievements`) — nenhum sistema mantém seu próprio contador duplicado.
- `RewardData` (Resource): pode conter Fragmentos Míticos, Essência, desbloqueio de personagem/skin/conquista ao mesmo tempo. Aplicada de forma centralizada por `RewardResolver.apply()` — nenhum sistema credita moeda ou desbloqueia conteúdo "na mão".
- `DifficultyModifier` (Resource): bloco de multiplicadores (vida/dano/velocidade/spawn/XP/recompensa) reutilizado por `GameModeData`, `ChallengeData` e `LocationData`. `DifficultyModifier.combine()` compõe vários em um só — um desafio é literalmente só isso, nunca lógica própria.

### Localidade, Ondas e Dificuldade
- `LocationData` (Resource): onde a run acontece — `enemy_pool`/`elite_pool` (dados, não cenas — `EnemySpawner` instancia sempre a mesma `Enemy.tscn` genérica e só troca o `enemy_data`), `boss_pool`, `wave_profile` (lista de `WaveData`), `difficulty_modifier`, `initial_duration`, `unlock_condition`.
- `WaveData` (Resource): uma janela de tempo (`start_time`/`end_time`) com seu próprio `spawn_interval` (e opcionalmente um `enemy_pool_override`). `EnemySpawner._current_wave()` só pergunta "qual onda está ativa agora?" — os números ficam inteiramente no `.tres` da localidade.
- `Locations` (autoload): registro de `LocationData` + `current`. Nesta etapa só existe o Domínio Chinês (`china_domain.tres`).
- `RunConfig` (autoload): `current_mode`/`current_challenge` da run + `get_combined_modifier()` (soma o modificador do modo, do desafio e da localidade atual).
- `DifficultyDirector` (autoload): `get_modifier()` pega o combinado de `RunConfig` e, se `RunStats.survival_time` já passou de `current_mode.main_cycle_duration`, aplica uma rampa adicional (+12%/minuto de vida/dano/spawn) — é assim que o Survival "vira" Endless sozinho, sem nenhuma checagem espalhada pelo `Main.gd`. `Enemy._ready()` lê esse modificador uma vez ao spawnar (vida/dano/velocidade/XP/recompensa do inimigo); `EnemySpawner` usa `get_spawn_interval_mult()` a cada disparo.

### Boss
- `BossData` (Resource): metadados do chefe (nome/origem/descrição/`spawn_time`/`reward`/`secret`) + uma referência a um `EnemyData` normal para vida/velocidade/dano de contato — **o combate em si não é reimplementado**.
- `BossEnemy` (`extends Enemy`): só sobrescreve `_ready()` (usa `boss_data.enemy_data` e repassa `health_changed` como `boss_health_changed`, para a UI) e `_on_died()` (chama `super._on_died()` — mantendo XP/Essência/kill count normais — e adiciona `RunStats.bosses_defeated += 1` + `RewardResolver.apply(boss_data.reward)`).
- `BossDirector` (nó em `Main.tscn`): a cada frame (checagem O(nº de chefes da localidade), trivial), compara `RunStats.survival_time` com `boss_data.spawn_time` de cada chefe do `Locations.current.boss_pool` ainda não spawnado. `Main.gd` só escuta os sinais `boss_spawned`/`boss_defeated` para mostrar/esconder a barra de vida do chefe no HUD.

### Conquistas e Recompensas
- `AchievementData` (Resource): id, nome, descrição, `secret`, `condition` (`UnlockCondition`), `reward` (`RewardData`).
- `Achievements` (autoload): monta o catálogo (6 entradas, uma secreta) e, em `_process()` — só enquanto `RunStats.active` —, checa se alguma condição ainda não desbloqueada foi satisfeita; se sim, aplica a recompensa e persiste via `MetaProgress.unlock_achievement()`. `force_unlock(id)` existe para recompensas que apontam direto para uma conquista (`RewardData.unlock_achievement_id`).
- A tela **Conquistas** (`AchievementsScreen`, aberta pelo Menu Principal) é só leitura: lista `Achievements.pool`, mostrando "???" para as secretas ainda não desbloqueadas.

### Meta-Progressão (conta persistente)
- `MetaProgress` (autoload): a única fonte de verdade do que sobrevive entre partidas — Fragmentos Míticos, personagens/skins/conquistas desbloqueados, nível de cada meta upgrade, recordes (`update_record`, guarda o melhor valor). Salva em `user://meta_progress.cfg` via `ConfigFile`, com um campo `version` já reservado para migração futura. **Nunca se mistura com `RunStats`/`Economy`** (que são temporários).
- `MetaUpgradeData` + `MetaUpgrades` (autoload): 2 melhorias funcionais (`meta_damage`, `meta_max_hp`), cada nível custando mais que o anterior (`get_cost_for_next_level`). `Player._apply_meta_upgrades()` lê o nível salvo de cada uma e aplica o bônus uma vez, no início da run — mesmo `match` de tipos que `PlayerPassives` usa, sem duplicar a lógica de "o que cada tipo de bônus faz".
- `CharacterSkinData` + `Skins` (autoload): uma skin só muda aparência (`tint` sobre o `Visual`). Sem tela de seleção ainda — `Skins.get_equipped_tint(character_id)` retorna a primeira skin desbloqueada para aquele personagem, aplicada automaticamente em `Player._ready()`.
- A tela **Progressão** (`MetaUpgradeScreen`, aberta pelo Menu Principal) mostra os 2 meta upgrades com nível atual/próximo/custo e compra na hora (`MetaUpgrades.try_purchase()`).

### Fim de Run → Recompensa (sem duplicar)
`Main.gd` está conectado a `GameManager.game_over`, que **só dispara uma vez por run** (o próprio `GameManager.trigger_game_over()` já tem a guarda `if state == GAME_OVER: return`) — não há necessidade de uma guarda adicional nesse ponto. `GameOverScreen.show_results()` credita uma recompensa simples de fim-de-run (proporcional a tempo + nível) com sua própria guarda local (`_reward_applied`) como segunda camada de segurança contra clique duplo no botão. Recompensas de chefe/conquista já foram creditadas no instante em que aconteceram, via `RewardResolver` — o fim de run não as re-aplica.

## 12. Assets Visuais (Etapa 5)

Os placeholders geométricos (`Polygon2D`) do jogador, do bastão, do inimigo e da gema de XP foram substituídos por sprites (`Sprite2D`) simples e originais, em `assets/`. Eles foram **gerados por código** (script Python com Pillow, formas básicas desenhadas programaticamente — círculos, elipses, polígonos), não copiados de nenhum jogo ou banco de assets, evitando qualquer questão de licenciamento.

Cada substituição manteve o nome do nó `Visual` e o tipo `CanvasItem` (`Polygon2D` → `Sprite2D`, ambos têm `.modulate`), então **nenhum script precisou mudar** — `Weapon._flash_target()`, `Player.gd` e `Enemy.gd` continuam funcionando exatamente como antes, só o que é desenhado mudou. `texture_filter = NEAREST` é usado em cada `Sprite2D` para manter a estética de pixel art nítida mesmo com o `stretch/mode = canvas_items` do projeto.

O bastão (`SwingVisual` em `Staff.tscn`) trocou dois `Polygon2D` (cabo + ponta) por um único `Sprite2D` do ícone `ruyi_jingu_bang.png`, mantendo a mesma animação de arco de swing controlada por `WeaponStaff.gd` (rotação do nó pai, não da sprite em si).

## 13. Limitações Conhecidas

- Botão físico "voltar" do Android ainda não é interceptado — hoje isso é papel do `ui_cancel` (Esc), que só está mapeado dentro da partida para abrir o Pause. Tratar o botão de voltar do sistema operacional fica para uma etapa futura de polimento mobile.
- Não há tela de preparação (`PRE_GAME`) entre o Menu e a partida — por decisão de escopo (ver `docs/GAMEPLAY.md`), o botão JOGAR inicia a run diretamente.
- A loja não oferece "melhorar uma arma já equipada" além da fusão voluntária de 2 cópias iguais (ver seção 10) — não existe upgrade direto pago em Essência.
- Categoria `RELIC` mencionada no desenho geral do sistema de ofertas ainda não existe no `ShopCategory.Type` nem tem conteúdo — fica reservada para uma etapa futura.
- Evolução de arma além do `max_level` (ex.: "Ascended") ainda não existe — a arquitetura permite (ver seção 10), mas não foi implementada nesta etapa.
- Se dois estágios de evolução de personagem forem cruzados numa única chamada de `add_xp()` (XP muito acima do necessário de uma vez, o que não acontece em jogo normal, só forçando via debug), apenas a última evolução atingida é mostrada na `EvolutionScreen`, embora os bônus de todas sejam aplicados corretamente.
- Os sprites são deliberadamente simples (poucas cores, sem animação) — servem para dar identidade visual básica, não são arte final.
- Não há tela de seleção de Localidade/Modo/Desafio — `Locations.current`, `RunConfig.current_mode` e `RunConfig.current_challenge` têm defaults sensatos (Domínio Chinês, Survival, nenhum desafio) e toda a troca é testável por código (`set_current`/`set_mode`/`set_challenge`), mas nenhuma UI ainda chama isso.
- Só existem 1 localidade, 1 chefe, 1 desafio e 6 conquistas — a arquitetura suporta múltiplos de cada, só o conteúdo em si ainda não foi produzido em escala (fora do escopo desta etapa, por decisão explícita).
- Sem tela de seleção de skin — a primeira desbloqueada para o personagem é equipada automaticamente; múltiplas skins do mesmo personagem ainda não têm como o jogador escolher entre elas.
- Categoria `RELIC`, bosses secretos com conteúdo real e a cadeia "Quatro Cavaleiros" mencionados como exemplos futuros no pedido original ainda não têm nenhuma entrada — só os campos (`secret`, `unlock_condition`) já existem em `BossData`/`AchievementData` para quando isso for produzido.
- Bestiário e tela de Coleção ainda não existem — `RunStats`/`MetaProgress` já guardam dados suficientes (kills, bosses derrotados, conquistas) para alimentá-los quando forem construídos.

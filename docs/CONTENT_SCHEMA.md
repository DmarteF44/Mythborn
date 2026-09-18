# Mythborn — Schema dos Resources de Conteúdo

Referência de campos de cada `Resource` de conteúdo do jogo. Para "como eu crio um X novo", ver [`docs/CONTENT_PIPELINE.md`](CONTENT_PIPELINE.md). Para o *porquê* arquitetural, ver [`docs/ARCHITECTURE.md`](ARCHITECTURE.md).

## CharacterData
**Propósito**: quem o jogador é.
**Local**: `scripts/characters/CharacterData.gd`
**Campos**: `id`, `character_name`, `display_name`, `origin`, `description`, `base_health`, `base_move_speed`, `starting_weapon` (`PackedScene`), `evolutions` (`Array[CharacterEvolutionData]`), `unlock_condition`.
**Relacionamentos**: registrado em `Characters.pool`. `evolutions[0]` é sempre o estágio inicial (`level_required = 1`).
**Exemplo mínimo**: `resources/characters/wukong_data.tres` — `id="wukong"`, `base_health=30`, `starting_weapon=Staff.tscn`, 3 evoluções.

## CharacterEvolutionData
**Propósito**: um estágio de evolução do personagem (Wukong → Sun Wukong → Despertado).
**Local**: `scripts/characters/CharacterEvolutionData.gd`
**Campos**: `stage` (enum `INITIAL`/`EVOLVED`/`AWAKENED`), `level_required`, `display_name`, `health_bonus_mult`, `move_speed_bonus_mult`, `damage_bonus_mult`, `attack_speed_bonus_mult`, `unlocked_power_scene` (opcional), `unlocked_power_label`.
**Relacionamentos**: lista ordenada dentro de `CharacterData.evolutions`. Avaliado por `CharacterProgression.check_level()`.
**Exemplo mínimo**: `wukong_stage_2_sun_wukong.tres` — nível 15, `display_name="SUN WUKONG"`, concede `HairClones.tscn`.

## CharacterSkinData
**Propósito**: aparência alternativa de um personagem (nunca altera atributos).
**Local**: `scripts/content/CharacterSkinData.gd`
**Campos**: `id`, `character_id`, `display_name`, `tint` (`Color`), `unlock_condition`, `reward`.
**Relacionamentos**: registrado em `Skins.pool`; "default" é sintética (não fica em `pool`, ver `Skins.get_default_skin()`). Equipada via `MetaProgress.equipped_skins[character_id]`.
**Exemplo mínimo**: `wukong_golden` — `character_id="wukong"`, `tint=Color(1.7, 1.35, 0.4, 1)`.

## WeaponData
**Propósito**: dados de balanceamento de uma arma/poder (nível 1 + taxas de crescimento).
**Local**: `scripts/weapons/WeaponData.gd`
**Campos**: `id`, `display_name`, `damage`, `cooldown`, `range` (todos nível 1), `max_level`, `damage_growth_per_level`, `cooldown_reduction_per_level`, `range_growth_per_level`, `price`, `shop_category` (`WEAPON`/`PASSIVE`/`POWER`).
**Relacionamentos**: `{data, scene}` registrado em `WeaponPool.pool`. Uma cópia em jogo é uma instância de `Weapon` (a cena), nunca o `WeaponData` diretamente — várias cópias/níveis coexistem (`WeaponInventory`).
**Exemplo mínimo**: `staff_data.tres` — `id="staff"`, `damage=5`, `max_level=5`.

## UpgradeData
**Propósito**: uma passiva ou poder-passivo (dano, vida, velocidade, magnetismo, Nuvem Ventania...).
**Local**: `scripts/upgrades/UpgradeData.gd`
**Campos**: `id`, `title` (level-agnostic), `description`, `type` (enum: `DAMAGE`/`ATTACK_SPEED`/`MOVE_SPEED`/`VITALITY`/`XP_GAIN`/`PICKUP_RADIUS`), `value` (incremento por nível), `max_level`, `price`, `shop_category`.
**Relacionamentos**: registrado em `UpgradePool.pool`. Nível atual por jogador fica em `PlayerPassives.levels[id]`, nunca no próprio Resource (compartilhado).
**Exemplo mínimo**: `damage` — `type=DAMAGE`, `value=0.2`, `max_level=3`.

## EnemyData
**Propósito**: dados de um tipo de inimigo comum (ou a base de um chefe, via `BossData.enemy_data`).
**Local**: `scripts/enemies/EnemyData.gd`
**Campos**: `display_name`, `max_health`, `move_speed`, `contact_damage`, `xp_value`, `essence_value`.
**Relacionamentos**: registrado em `LocationData.enemy_pool`/`elite_pool` ou referenciado por `BossData.enemy_data`. `EnemySpawner` sempre instancia a mesma `Enemy.tscn` e só troca este campo.
**Exemplo mínimo**: `grunt_data.tres` — `max_health=10`, `essence_value=3`.

## LocationData
**Propósito**: onde a run acontece.
**Local**: `scripts/content/LocationData.gd`
**Campos**: `id`, `display_name`, `description`, `origin`, `enemy_pool` (`Array[EnemyData]`), `elite_pool` (reservado), `boss_pool` (`Array[BossData]`), `wave_profile` (`Array[WaveData]`), `difficulty_modifier`, `initial_duration`, `endless_enabled`, `reward` (reservado), `unlock_condition`.
**Relacionamentos**: registrado em `Locations.pool`; `Locations.current` é a ativa na run. Lida por `EnemySpawner`/`BossDirector`/`RunConfig.get_combined_modifier()`.
**Exemplo mínimo**: `china_domain.tres` — Grunt no `enemy_pool`, Rei Touro Demônio no `boss_pool`, 3 `WaveData`.

## WaveData
**Propósito**: uma janela de tempo com suas próprias regras de spawn.
**Local**: `scripts/content/WaveData.gd`
**Campos**: `start_time`, `end_time`, `spawn_interval`, `elite_chance` (reservado), `enemy_pool_override` (opcional).
**Relacionamentos**: lista ordenada dentro de `LocationData.wave_profile`. `EnemySpawner._current_wave()` escolhe qual está ativa.
**Exemplo mínimo**: `0s–60s`, `spawn_interval=1.8`.

## GameModeData
**Propósito**: regras gerais da partida (Survival, Endless...).
**Local**: `scripts/content/GameModeData.gd`
**Campos**: `id`, `display_name`, `description`, `endless_enabled`, `main_cycle_duration` (segundos até a rampa do Endless começar; 0 = já começa no Endless), `difficulty_modifier`, `reward_multiplier`, `unlock_condition`.
**Relacionamentos**: registrado em `RunConfig.game_modes`; `RunConfig.current_mode` é o ativo. Lido por `DifficultyDirector`.
**Exemplo mínimo**: `survival` — `main_cycle_duration=900`; `endless` — `main_cycle_duration=0`.

## ChallengeData
**Propósito**: um modificador opcional de regras (Inferno...).
**Local**: `scripts/content/ChallengeData.gd`
**Campos**: `id`, `display_name`, `description`, `modifier` (`DifficultyModifier`), `reward_multiplier`, `unlock_condition`.
**Relacionamentos**: registrado em `RunConfig.challenges`; `RunConfig.current_challenge` (`null` = Normal) é o ativo.
**Exemplo mínimo**: `inferno` — `health_multiplier=1.5`, `xp_multiplier=0.8`, `reward_multiplier=1.5`.

## DifficultyModifier
**Propósito**: bloco de multiplicadores reutilizado por `GameModeData`/`ChallengeData`/`LocationData`.
**Local**: `scripts/content/DifficultyModifier.gd`
**Campos**: `health_multiplier`, `damage_multiplier`, `speed_multiplier`, `spawn_multiplier`, `xp_multiplier`, `reward_multiplier` (todos `1.0` = neutro).
**Relacionamentos**: `DifficultyModifier.combine(a, b)` compõe vários; `RunConfig.get_combined_modifier()` soma modo + desafio + localidade; `DifficultyDirector` acrescenta a rampa de tempo do Endless por cima.

## BossData
**Propósito**: metadados de um chefe (o combate vem de `enemy_data`).
**Local**: `scripts/content/BossData.gd`
**Campos**: `id`, `display_name`, `origin`, `description`, `enemy_data` (`EnemyData`), `spawn_time`, `reward`, `secret`, `unlock_condition`, `phases` (`Array[BossPhaseData]`, opcional).
**Relacionamentos**: registrado em `LocationData.boss_pool`. `BossDirector` decide quando spawnar; `BossEnemy` (extends `Enemy`) decide o comportamento.
**Exemplo mínimo**: `bull_demon_king_data.tres` — `spawn_time=300`, `reward` dá Essência + Fragmentos + desbloqueia a skin dourada.

## BossPhaseData
**Propósito**: ponto de extensão para chefes com múltiplas fases (dash, projéteis, invocação — ainda não implementados, só a detecção de fase).
**Local**: `scripts/content/BossPhaseData.gd`
**Campos**: `display_name`, `health_threshold` (fração de vida em que a fase começa), `damage_multiplier`, `speed_multiplier`, `enrage`, `telegraph_duration` (reservado).
**Relacionamentos**: lista opcional em `BossData.phases`; vazio = comportamento atual (fase única). `BossEnemy._check_phase()`/`_on_phase_changed()` aplicam automaticamente os multiplicadores; uma subclasse futura pode sobrescrever `_on_phase_changed()` para comportamentos especiais.

## AchievementData
**Propósito**: uma conquista.
**Local**: `scripts/content/AchievementData.gd`
**Campos**: `id`, `display_name`, `description`, `secret`, `condition` (`UnlockCondition`), `reward` (`RewardData`).
**Relacionamentos**: registrado em `Achievements.pool`. `Achievements._process()` checa `condition` automaticamente; desbloqueio persiste em `MetaProgress.unlocked_achievements`.
**Exemplo mínimo**: `first_kill` — `condition = KILLS >= 1`, `reward = +10 Essência`.

## RewardData
**Propósito**: o que uma ação concede — pode combinar vários itens ao mesmo tempo.
**Local**: `scripts/content/RewardData.gd`
**Campos**: `currency_amount` (Fragmentos Míticos), `essence_amount`, `unlock_character_id`, `unlock_skin_id`, `unlock_achievement_id`.
**Relacionamentos**: aplicada por `RewardResolver.apply()` — nunca "na mão". Usada por `AchievementData.reward`, `BossData.reward`.

## UnlockCondition
**Propósito**: condição reutilizável de desbloqueio.
**Local**: `scripts/content/UnlockCondition.gd`
**Campos**: `type` (enum: `KILLS`/`SURVIVAL_TIME`/`LEVEL_REACHED`/`BOSS_DEFEATED`/`CHARACTER_EVOLUTION`/`ACHIEVEMENT`/`CURRENCY`/`COMBINATION`/`ALWAYS_MET`), `comparison` (`AT_LEAST`/`AT_MOST`), `amount`, `target_id`, `sub_conditions` (`Array[UnlockCondition]`, só para `COMBINATION`).
**Relacionamentos**: avaliada por `UnlockConditionChecker.is_met()`. Usada por `CharacterData`, `CharacterSkinData`, `LocationData`, `GameModeData`, `ChallengeData`, `BossData`, `AchievementData`.
**Exemplo mínimo (secreto)**: `awakened_rush` — `COMBINATION` de `CHARACTER_EVOLUTION >= 2` e `SURVIVAL_TIME <= 300` (AT_MOST).

## MetaUpgradeData
**Propósito**: uma melhoria permanente (paga em Fragmentos Míticos).
**Local**: `scripts/content/MetaUpgradeData.gd`
**Campos**: `id`, `display_name`, `description`, `type` (reaproveita `UpgradeData.Type`), `value_per_level`, `max_level`, `cost_per_level`.
**Relacionamentos**: registrado em `MetaUpgrades.pool`. Nível salvo em `MetaProgress.meta_upgrade_levels[id]`. Aplicada uma vez por `Player._apply_meta_upgrades()` no início de cada run.
**Exemplo mínimo**: `meta_damage` — `type=DAMAGE`, `value_per_level=0.02`, `max_level=5`.

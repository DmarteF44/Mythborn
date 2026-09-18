# Mythborn — Guia de Criação de Conteúdo

Referência rápida: "quero adicionar X, quais arquivos eu toco?" Para o *porquê* de cada sistema existir assim, ver [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) (seção 11 principalmente). Nenhum item abaixo deveria exigir alterar `GameManager.gd`, `Main.gd` ou a `UpgradeShop` inteira — se parecer que exige, provavelmente existe um jeito mais data-driven.

## Fluxos resumidos

```
NOVO PERSONAGEM
CharacterData → evolutions (CharacterEvolutionData) → starting_weapon → skins (CharacterSkinData) → unlock_condition

NOVO BOSS
BossData → enemy_data (stats) → phases (BossPhaseData, opcional) → location (boss_pool) → reward → achievement (opcional)

NOVA LOCALIDADE
LocationData → wave_profile (WaveData) → enemy_pool → boss_pool → difficulty_modifier

NOVO CHALLENGE
ChallengeData → modifier (DifficultyModifier) → reward_multiplier

NOVO SEGREDO
UnlockCondition → conteúdo (AchievementData/BossData/CharacterSkinData com secret=true) → RewardData
```

## Personagem novo

1. Criar `CharacterData` (`.tres`) com vida/velocidade base, arma inicial e `unlock_condition` (ou deixar vazio = disponível desde o início).
2. Criar 1+ `CharacterEvolutionData` (`.tres`) — pelo menos o estágio inicial (`level_required = 1`).
3. Adicionar em `Characters.pool` — a partir daí ele já aparece na tela de seleção de Personagem (`RunSetupFlow`/`SelectionScreen`) e `Player.gd` resolve `RunConfig.selected_character_id` automaticamente, sem precisar tocar em `Player.gd`/`GameManager`/`Main`.
4. **Limitação atual**: `Player.tscn` só tem um `Visual` (o sprite de Wukong). Um segundo personagem com aparência própria hoje precisaria de uma segunda cena de jogador (ou de trocar a textura do `Visual` dinamicamente a partir de `CharacterData` — ainda não implementado, ver `docs/ARCHITECTURE.md`).
5. Registrar em `MetaProgress.unlocked_characters` (via `unlock_character_id` de alguma `RewardData`) se não for desbloqueado por padrão.

**Nunca precisa**: tocar em `CharacterProgression.gd` (já é genérico), nem em `RunSetupFlow.gd`/`SelectionScreen.gd` (iteram `Characters.pool` automaticamente).

## Skin nova

1. Criar `CharacterSkinData` (`.tres` ou entrada em `Skins.gd`) com `character_id`, `tint` (ou trocar por uma textura própria no futuro) e `unlock_condition`.
2. Adicionar ao `Skins.pool` — aparece automaticamente na tela de Skin (`RunSetupFlow`) e na aba Skins da Coleção.
3. Equipar é `Skins.equip(character_id, skin_id)` (grava em `MetaProgress.equipped_skins`); aplicar o visual é `Skins.get_equipped_tint(character_id)`, já chamado por `Player.gd`.

**Nunca precisa**: tocar em `Player.gd` (`Skins.get_equipped_tint()` já é genérico) nem criar uma segunda forma de "skin equipada" — `MetaProgress` é a única fonte de verdade.

## Arma ou poder novo

1. Criar `WeaponData` (`.tres`) — dano/cooldown/alcance de nível 1, taxas de crescimento por nível, `max_level`, `price`, `shop_category` (`WEAPON` ou `POWER`).
2. Criar a cena (`Node2D` + `CooldownTimer`) com um script estendendo `Weapon`, implementando `_perform_attack(target)`.
3. Adicionar `{"data": ..., "scene": ...}` em `WeaponPool.pool`.

**Nunca precisa**: tocar em `WeaponInventory.gd`, `UpgradeShop.gd` ou `UpgradeOfferGenerator.gd` (duplicatas, fusão e ofertas já são genéricos).

## Passiva ou poder-passivo novo

1. Adicionar uma entrada em `UpgradePool._ready()` — id, título (level-agnostic, ex. "DANO"), descrição, `type` (usar um tipo já existente — `DAMAGE`/`ATTACK_SPEED`/`MOVE_SPEED`/`VITALITY`/`XP_GAIN`/`PICKUP_RADIUS` — sempre que possível), `value` (incremento por nível), `max_level`, `price`, `shop_category` (`PASSIVE` ou `POWER`).
2. Só se o efeito for um tipo **novo** (nenhum dos já existentes serve): adicionar o valor no enum `UpgradeData.Type` e o `case` correspondente em `PlayerPassives.apply()`.

**Nunca precisa**: tocar em `UpgradeShop.gd` (a menos que o tipo seja realmente novo).

## Inimigo comum novo

1. Criar `EnemyData` (`.tres`) — vida, velocidade, dano de contato, XP, Essência.
2. Adicionar em `LocationData.enemy_pool` (ou no `enemy_pool_override` de uma `WaveData` específica, se só deve aparecer numa janela de tempo).

**Nunca precisa**: nova cena — `EnemySpawner` sempre instancia a mesma `Enemy.tscn` e só troca o `enemy_data`, a menos que o *comportamento* (não só os números) precise mudar.

## Chefe novo

1. Criar `EnemyData` (`.tres`) com os stats do chefe (geralmente muito maiores que um inimigo comum).
2. Criar `BossData` (`.tres`) apontando para esse `EnemyData`, com `display_name`, `spawn_time`, `reward` (`RewardData`) e, se secreto, `secret = true` + `unlock_condition`.
3. (Opcional) Criar `BossPhaseData` para cada fase (limiar de vida + multiplicadores de dano/velocidade) e adicionar em `BossData.phases` — a detecção de transição de fase já é automática (`BossEnemy._check_phase()`); para um comportamento especial numa fase (dash, projéteis, invocação), criar uma cena/script estendendo `BossEnemy` e sobrescrever `_on_phase_changed()`.
4. Adicionar em `LocationData.boss_pool`.

**Nunca precisa**: nova cena base (`Boss.tscn`/`BossEnemy.gd` já são genéricos, incluindo fases simples) nem tocar em `BossDirector.gd`/`Main.gd`. Só crie uma subclasse de `BossEnemy` se o chefe precisar de um comportamento realmente especial além de escalar dano/velocidade por fase.

## Localidade nova

1. Criar `LocationData` (`.tres`): `enemy_pool`, `elite_pool` (reservado, sem uso ainda), `boss_pool`, `wave_profile` (lista de `WaveData`), `difficulty_modifier`, `initial_duration`, `unlock_condition`.
2. Adicionar em `Locations.pool` — aparece automaticamente na tela de seleção de Localidade e na aba Localidades da Coleção.
3. Para testar diretamente por código: `Locations.set_current(id)` antes de `GameManager.start_new_run()` (é exatamente o que a tela de seleção faz).

## Modo novo

1. Adicionar uma entrada em `RunConfig.game_modes` — `endless_enabled`, `main_cycle_duration`, `difficulty_modifier`, `reward_multiplier`, `unlock_condition`.
2. Já aparece automaticamente na tela de seleção de Modo (`RunSetupFlow._open_mode()` itera `RunConfig.game_modes`, sem filtro).

## Desafio novo

1. Adicionar uma entrada em `RunConfig.challenges` — um `DifficultyModifier` + `reward_multiplier` + `unlock_condition`. **Nunca** escrever lógica específica do desafio; se o efeito não cabe em `DifficultyModifier`, é sinal de que o campo deveria ser adicionado lá (reutilizável por qualquer desafio futuro), não direto no desafio.
2. Já aparece automaticamente na tela de seleção de Desafio, ao lado de "Normal" (`current_challenge = null`).

## Conquista nova

1. Adicionar uma entrada em `Achievements._ready()` — id, nome, descrição, `secret`, `condition` (`UnlockCondition` — reaproveitar um tipo existente sempre que possível; `COMBINATION` permite compor várias), `reward` (`RewardData`).

**Nunca precisa**: eventos/sinais novos — `Achievements._process()` já verifica todas as condições pendentes automaticamente lendo `RunStats`/`Economy`/`MetaProgress`.

## Melhoria permanente (meta upgrade) nova

1. Adicionar uma entrada em `MetaUpgrades._ready()` — `type` (reaproveitar um tipo de `UpgradeData.Type`), `value_per_level`, `max_level`, `cost_per_level`.
2. Se o `type` for realmente novo, adicionar o `case` em `Player._apply_meta_upgrades()`.

## Recompensa

Sempre um `RewardData` — nunca aplicar moeda/desbloqueio "na mão". Um `RewardData` pode combinar `currency_amount` + `essence_amount` + `unlock_character_id` + `unlock_skin_id` + `unlock_achievement_id` ao mesmo tempo. Para aplicar: `RewardResolver.apply(reward)`.

## Condição de desbloqueio

Sempre um `UnlockCondition` — nunca `if` específico. Reaproveitar um `type` existente; usar `COMBINATION` para compor várias (ex.: "nível X E tempo de sobrevivência ≤ Y", como o segredo "Despertar Precoce"). Avaliar com `UnlockConditionChecker.is_met(condition)`.

## Relíquia (categoria reservada, sem conteúdo ainda)

Ainda não implementado. Para adicionar: incluir `RELIC` em `ShopCategory.Type`, criar `RelicData` (Resource) e um `RelicPool` (autoload), seguindo exatamente o padrão de `WeaponPool`/`UpgradePool`.

## Conteúdo secreto (exemplo: "Quatro Cavaleiros")

Nenhum conteúdo real dos Quatro Cavaleiros existe ainda — isto é só um exemplo de como uma futura cadeia de conteúdo secreto usaria o que já existe, sem precisar de sistema novo:

1. Cada Cavaleiro seria um `BossData` com `secret = true` e um `unlock_condition` próprio (ex.: derrotar os outros três primeiro — expressável hoje via `UnlockCondition.Type.COMBINATION` de vários `BOSS_DEFEATED`/`ACHIEVEMENT`).
2. Opcionalmente, uma `AchievementData` secreta "encontrou um Cavaleiro" com `reward.unlock_achievement_id` apontando para a conquista "final" depois dos quatro.
3. Opcionalmente, um `CharacterSkinData` ou até um `CharacterData` secreto desbloqueado pela mesma cadeia.

A `CollectionScreen` já sabe mostrar "???" para bosses/skins/personagens secretos não descobertos (ver `_render_bosses()`) — nenhuma UI nova seria necessária.

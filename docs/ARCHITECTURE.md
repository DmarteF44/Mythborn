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
  main/Main.tscn            # Arena + orquestração da partida
  player/Player.tscn
  enemies/Enemy.tscn
  weapons/Staff.tscn
  pickups/XPGem.tscn
  ui/HUD.tscn
  ui/LevelUpScreen.tscn
scripts/
  core/GameManager.gd       # Autoload — estado global da partida
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
  main/Main.gd
resources/
  weapons/staff_data.tres
  enemies/grunt_data.tres
```

## 3. Autoloads (Singletons)

| Nome | Script | Responsabilidade |
|---|---|---|
| `GameManager` | `core/GameManager.gd` | Estado da partida (`playing`/`leveling_up`/`game_over`), pausar/retomar, sinal `game_over`, constante `MAX_WEAPONS = 12`. |
| `Upgrades` | `upgrades/UpgradePool.gd` | Catálogo de `UpgradeData` disponíveis e sorteio de opções para o level-up. |

## 4. Responsabilidade de Cada Sistema

### Main / Arena (`scenes/main/Main.tscn` + `Main.gd`)
Orquestra a partida: instancia o jogador, a arena (paredes simples), o `EnemySpawner`, o `HUD` e a `LevelUpScreen`. Conecta o sinal `leveled_up` do jogador à exibição da tela de upgrade, e o sinal de morte do jogador ao fim de partida.

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
Autoload com o estado atual da partida (`playing`, `leveling_up`, `game_over`), responsável por pausar/despausar a árvore (`get_tree().paused`) e centralizar a constante `MAX_WEAPONS`. Outros sistemas leem o estado ou reagem ao sinal `game_over` em vez de decidir sozinhos quando pausar o jogo.

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
- **Progressão permanente**: um autoload adicional (`MetaProgress`) pode persistir dados entre partidas (ex.: salvar em arquivo) e aplicar bônus iniciais ao `PlayerStats` na criação do jogador.
- **Narrativa**: eventos entre partidas podem ser orquestrados fora da arena (menu/hub), sem impacto na arquitetura de combate.

class_name BossPhaseData
extends Resource

## Ponto de extensão para chefes com múltiplas fases. `BossData.phases`
## vazio = comportamento atual (fase única). Preenchido, `BossEnemy`
## aplica automaticamente os multiplicadores da fase ao cruzar o limiar de
## vida; comportamentos especiais (dash, projéteis, invocação, telegraph
## visual) ficam para uma subclasse futura sobrescrever `_on_phase_changed()`.

@export var display_name: String = ""
@export var health_threshold: float = 1.0 ## fração da vida máxima em que a fase começa (1.0 = desde o início)
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var enrage: bool = false

## Reservado para o futuro: duração do aviso visual antes de um ataque
## especial ("vou atacar esta área") — não implementado ainda.
@export var telegraph_duration: float = 0.0

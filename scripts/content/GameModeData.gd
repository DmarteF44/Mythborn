class_name GameModeData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

@export var endless_enabled: bool = true
## Segundos até a rampa de dificuldade do Endless começar. 0 = já começa
## em modo Endless desde o início (usado pelo próprio modo ENDLESS).
@export var main_cycle_duration: float = 900.0

@export var difficulty_modifier: DifficultyModifier
@export var reward_multiplier: float = 1.0
@export var unlock_condition: UnlockCondition

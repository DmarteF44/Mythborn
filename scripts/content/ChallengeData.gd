class_name ChallengeData
extends Resource

## Um desafio é APENAS uma composição de modificadores — nunca código
## específico por desafio (ver DifficultyModifier).

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

@export var modifier: DifficultyModifier
@export var reward_multiplier: float = 1.0
@export var unlock_condition: UnlockCondition

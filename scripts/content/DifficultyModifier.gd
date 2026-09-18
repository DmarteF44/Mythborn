class_name DifficultyModifier
extends Resource

## Bloco de multiplicadores reutilizado por GameModeData e ChallengeData —
## um Challenge é "apenas" uma composição destes valores, nunca código
## específico por desafio.

@export var health_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var spawn_multiplier: float = 1.0
@export var xp_multiplier: float = 1.0
@export var reward_multiplier: float = 1.0


static func combine(a: DifficultyModifier, b: DifficultyModifier) -> DifficultyModifier:
	var result := DifficultyModifier.new()
	if a == null and b == null:
		return result
	if a == null:
		return b
	if b == null:
		return a
	result.health_multiplier = a.health_multiplier * b.health_multiplier
	result.damage_multiplier = a.damage_multiplier * b.damage_multiplier
	result.speed_multiplier = a.speed_multiplier * b.speed_multiplier
	result.spawn_multiplier = a.spawn_multiplier * b.spawn_multiplier
	result.xp_multiplier = a.xp_multiplier * b.xp_multiplier
	result.reward_multiplier = a.reward_multiplier * b.reward_multiplier
	return result

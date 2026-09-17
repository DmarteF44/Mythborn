class_name CharacterProgression
extends Node

## Centraliza a evolução do personagem por nível. Nenhum outro sistema deve
## checar "if level >= 15" — tudo passa por check_level().

signal evolved(evolution: CharacterEvolutionData)

@export var character_data: CharacterData

var current_stage_index: int = 0

@onready var _stats: PlayerStats = get_parent().get_node("PlayerStats")
@onready var _health: Health = get_parent().get_node("Health")
@onready var _weapon_inventory: WeaponInventory = get_parent().get_node("WeaponInventory")


## Chamar sempre que o jogador subir de nível. Retorna os dados da evolução
## se uma nova foi atingida agora, ou null caso contrário.
func check_level(level: int) -> CharacterEvolutionData:
	var reached: CharacterEvolutionData = null
	while current_stage_index + 1 < character_data.evolutions.size() \
			and level >= character_data.evolutions[current_stage_index + 1].level_required:
		current_stage_index += 1
		reached = character_data.evolutions[current_stage_index]
		_apply_evolution(reached)
	if reached != null:
		evolved.emit(reached)
	return reached


func get_display_name() -> String:
	return character_data.evolutions[current_stage_index].display_name


func get_previous_display_name() -> String:
	var index: int = maxi(current_stage_index - 1, 0)
	return character_data.evolutions[index].display_name


func _apply_evolution(evo: CharacterEvolutionData) -> void:
	_health.apply_max_health_multiplier(evo.health_bonus_mult)
	_stats.character_move_mult *= evo.move_speed_bonus_mult
	_stats.character_damage_mult *= evo.damage_bonus_mult
	_stats.character_attack_speed_mult *= evo.attack_speed_bonus_mult
	if evo.unlocked_power_scene != null:
		_weapon_inventory.add_weapon(evo.unlocked_power_scene)

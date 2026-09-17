class_name PlayerStats
extends Node

## Multiplicadores/stats do jogador. Upgrades escrevem aqui; armas leem daqui.

@export var base_move_speed: float = 220.0

var move_speed_mult: float = 1.0
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0


func get_move_speed() -> float:
	return base_move_speed * move_speed_mult


func apply_upgrade(upgrade: UpgradeData) -> void:
	match upgrade.type:
		UpgradeData.Type.DAMAGE:
			damage_mult += upgrade.value
		UpgradeData.Type.ATTACK_SPEED:
			attack_speed_mult += upgrade.value
		UpgradeData.Type.MOVE_SPEED:
			move_speed_mult += upgrade.value

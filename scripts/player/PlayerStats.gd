class_name PlayerStats
extends Node

## Multiplicadores/stats do jogador. Upgrades da run e evolução do
## personagem escrevem aqui, em conjuntos de campos separados; armas leem
## os valores efetivos via get_move_speed()/get_damage_mult()/get_attack_speed_mult().

@export var base_move_speed: float = 220.0
@export var base_pickup_radius: float = 80.0

## Vindos de upgrades escolhidos na run (empilham somando).
var move_speed_mult: float = 1.0
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0
var pickup_radius_bonus: float = 0.0

## Vindos da evolução do personagem (empilham multiplicando).
var character_move_mult: float = 1.0
var character_damage_mult: float = 1.0
var character_attack_speed_mult: float = 1.0


func get_move_speed() -> float:
	return base_move_speed * move_speed_mult * character_move_mult


func get_damage_mult() -> float:
	return damage_mult * character_damage_mult


func get_attack_speed_mult() -> float:
	return attack_speed_mult * character_attack_speed_mult


func get_pickup_radius() -> float:
	return base_pickup_radius + pickup_radius_bonus


func apply_upgrade(upgrade: UpgradeData) -> void:
	match upgrade.type:
		UpgradeData.Type.DAMAGE:
			damage_mult += upgrade.value
		UpgradeData.Type.ATTACK_SPEED:
			attack_speed_mult += upgrade.value
		UpgradeData.Type.MOVE_SPEED:
			move_speed_mult += upgrade.value

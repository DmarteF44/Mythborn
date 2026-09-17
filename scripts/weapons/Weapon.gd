class_name Weapon
extends Node2D

## Base de todas as armas: cooldown + busca de alvo. Comportamento do ataque
## em si é responsabilidade de cada subclasse via _perform_attack().

@export var weapon_data: WeaponData

var stats: PlayerStats = null

@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	_start_cooldown()


func _get_effective_damage() -> float:
	var mult := stats.damage_mult if stats else 1.0
	return weapon_data.damage * mult


func _get_effective_cooldown() -> float:
	var mult := stats.attack_speed_mult if stats else 1.0
	return weapon_data.cooldown / max(0.01, mult)


func _start_cooldown() -> void:
	cooldown_timer.wait_time = max(0.05, _get_effective_cooldown())
	cooldown_timer.start()


func _on_cooldown_timeout() -> void:
	var target := TargetingUtils.get_closest_enemy(global_position, weapon_data.range)
	if target != null:
		_perform_attack(target)
	_start_cooldown()


## Sobrescrever nas subclasses para implementar o efeito do ataque (melee, projétil, área...).
func _perform_attack(_target: Node2D) -> void:
	pass

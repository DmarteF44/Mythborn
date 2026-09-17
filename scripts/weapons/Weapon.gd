class_name Weapon
extends Node2D

## Base de todas as armas: cooldown + busca de alvo. Comportamento do ataque
## em si é responsabilidade de cada subclasse via _perform_attack().
##
## Esta instância representa UMA cópia da arma — o jogador pode ter várias
## cópias independentes da mesma WeaponData (ver WeaponInventory), cada uma
## com seu próprio current_level, cooldown e alvo.

@export var weapon_data: WeaponData

var stats: PlayerStats = null
var current_level: int = 1

@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	_start_cooldown()


## Usado pela fusão (WeaponInventory.fuse) para elevar o nível desta cópia.
func set_level(level: int) -> void:
	current_level = clampi(level, 1, weapon_data.max_level)


func _get_effective_damage() -> float:
	var mult := stats.get_damage_mult() if stats else 1.0
	return weapon_data.get_damage_for_level(current_level) * mult


func _get_effective_cooldown() -> float:
	var mult := stats.get_attack_speed_mult() if stats else 1.0
	return weapon_data.get_cooldown_for_level(current_level) / max(0.01, mult)


func _get_effective_range() -> float:
	return weapon_data.get_range_for_level(current_level)


func _start_cooldown() -> void:
	cooldown_timer.wait_time = max(0.05, _get_effective_cooldown())
	cooldown_timer.start()


func _on_cooldown_timeout() -> void:
	var target := TargetingUtils.get_closest_enemy(global_position, _get_effective_range())
	if target != null:
		_perform_attack(target)
	_start_cooldown()


## Sobrescrever nas subclasses para implementar o efeito do ataque (melee, projétil, área...).
func _perform_attack(_target: Node2D) -> void:
	pass


## Feedback de acerto reutilizável por qualquer arma: um flash rápido no
## placeholder visual do alvo atingido.
func _flash_target(target: Node2D) -> void:
	if not is_instance_valid(target):
		return
	var visual := target.get_node_or_null("Visual") as CanvasItem
	if visual == null:
		return
	visual.modulate = Color(1.8, 1.8, 1.8, 1.0)
	var tween := target.create_tween()
	tween.tween_property(visual, "modulate", Color(1, 1, 1, 1), 0.15)

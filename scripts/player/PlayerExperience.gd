class_name PlayerExperience
extends Node

## XP e nível do jogador.

signal xp_changed(current: float, to_next: float)
signal leveled_up(new_level: int)

@export var base_xp_to_next: float = 10.0
@export var xp_growth_per_level: float = 5.0

var level: int = 1
var current_xp: float = 0.0
var xp_to_next: float = 0.0


func _ready() -> void:
	xp_to_next = base_xp_to_next
	xp_changed.emit(current_xp, xp_to_next)


func add_xp(amount: float) -> void:
	current_xp += amount
	while current_xp >= xp_to_next:
		current_xp -= xp_to_next
		level += 1
		xp_to_next += xp_growth_per_level
		leveled_up.emit(level)
	xp_changed.emit(current_xp, xp_to_next)

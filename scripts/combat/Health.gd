class_name Health
extends Node

## Componente de vida reutilizável por jogador e inimigos.

signal health_changed(current: float, max_value: float)
signal died

@export var max_health: float = 10.0

var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if current_health <= 0.0 or amount <= 0.0:
		return
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if current_health <= 0.0:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0.0


## Usado por evolução de personagem e pela passiva de Vitalidade — aumenta a
## vida máxima e cura a diferença como um pequeno bônus imediato.
func apply_max_health_multiplier(mult: float) -> void:
	var bonus := max_health * (mult - 1.0)
	if bonus <= 0.0:
		return
	max_health += bonus
	current_health += bonus
	health_changed.emit(current_health, max_health)

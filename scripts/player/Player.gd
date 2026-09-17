class_name Player
extends CharacterBody2D

@onready var stats: PlayerStats = $PlayerStats
@onready var health: Health = $Health
@onready var experience: PlayerExperience = $PlayerExperience
@onready var weapon_inventory: WeaponInventory = $WeaponInventory
@onready var progression: CharacterProgression = $CharacterProgression


var _last_health: float = -1.0


func _ready() -> void:
	add_to_group("player")

	var character_data := progression.character_data
	health.max_health = character_data.base_health
	health.current_health = character_data.base_health
	stats.base_move_speed = character_data.base_move_speed

	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

	weapon_inventory.add_weapon(character_data.starting_weapon)


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * stats.get_move_speed()
	move_and_slide()


func _on_health_changed(current: float, _max_value: float) -> void:
	if _last_health >= 0.0 and current < _last_health:
		Settings.trigger_haptic()
	_last_health = current


func _on_died() -> void:
	GameManager.trigger_game_over()

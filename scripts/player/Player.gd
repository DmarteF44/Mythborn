class_name Player
extends CharacterBody2D

@export var starting_weapons: Array[PackedScene] = []

@onready var stats: PlayerStats = $PlayerStats
@onready var health: Health = $Health
@onready var experience: PlayerExperience = $PlayerExperience
@onready var weapon_inventory: WeaponInventory = $WeaponInventory


func _ready() -> void:
	add_to_group("player")
	health.died.connect(_on_died)
	for weapon_scene in starting_weapons:
		weapon_inventory.add_weapon(weapon_scene)


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * stats.get_move_speed()
	move_and_slide()


func _on_died() -> void:
	GameManager.trigger_game_over()

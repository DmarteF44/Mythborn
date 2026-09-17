class_name EnemySpawner
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var spawn_radius: float = 500.0

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_timer_timeout)
	_timer.start()


func _on_timer_timeout() -> void:
	if enemy_scene == null:
		return

	var player := TargetingUtils.get_player()
	var center := player.global_position if player != null else global_position

	var angle := randf() * TAU
	var spawn_position := center + Vector2.RIGHT.rotated(angle) * spawn_radius

	var enemy := enemy_scene.instantiate()
	enemy.global_position = spawn_position
	get_tree().current_scene.add_child(enemy)

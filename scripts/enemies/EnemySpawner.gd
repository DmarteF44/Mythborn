class_name EnemySpawner
extends Node2D

## `enemy_scene` é a cena genérica (Enemy.tscn) instanciada para todo
## inimigo comum; qual EnemyData ela recebe vem de Locations.current (ou do
## fallback exportado, se nenhuma localidade estiver definida). O intervalo
## de spawn segue a onda ativa (Locations.current.wave_profile) e o
## escalonamento de DifficultyDirector — nada disso fica fixo aqui.

@export var enemy_scene: PackedScene
@export var fallback_enemy_data: EnemyData
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
	enemy.enemy_data = _pick_enemy_data()
	enemy.global_position = spawn_position
	get_tree().current_scene.add_child(enemy)

	_timer.wait_time = max(0.15, _current_spawn_interval() * DifficultyDirector.get_spawn_interval_mult())


func _current_wave() -> WaveData:
	var location := Locations.current
	if location == null or location.wave_profile.is_empty():
		return null
	for wave in location.wave_profile:
		if RunStats.survival_time >= wave.start_time and RunStats.survival_time < wave.end_time:
			return wave
	return location.wave_profile[-1]


func _current_spawn_interval() -> float:
	var wave := _current_wave()
	return wave.spawn_interval if wave != null else spawn_interval


func _pick_enemy_data() -> EnemyData:
	var wave := _current_wave()
	if wave != null and not wave.enemy_pool_override.is_empty():
		return wave.enemy_pool_override[randi() % wave.enemy_pool_override.size()]

	var location := Locations.current
	if location != null and not location.enemy_pool.is_empty():
		return location.enemy_pool[randi() % location.enemy_pool.size()]

	return fallback_enemy_data

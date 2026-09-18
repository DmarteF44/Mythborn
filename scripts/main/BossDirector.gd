class_name BossDirector
extends Node

## Lê a localidade ativa e decide quando cada chefe do boss_pool aparece
## (por tempo de sobrevivência). Nenhum horário fica hard-coded em Main.gd.

signal boss_spawned(boss: BossEnemy, boss_data: BossData)
signal boss_defeated(boss_data: BossData)

@export var boss_scene: PackedScene

var _spawned_ids: Array[String] = []


func _process(_delta: float) -> void:
	if not RunStats.active:
		return
	var location := Locations.current
	if location == null:
		return
	for boss_data in location.boss_pool:
		if _spawned_ids.has(boss_data.id):
			continue
		if RunStats.survival_time >= boss_data.spawn_time:
			_spawn_boss(boss_data)


func _spawn_boss(boss_data: BossData) -> void:
	_spawned_ids.append(boss_data.id)

	var player := TargetingUtils.get_player()
	var spawn_position := (player.global_position + Vector2(0, -420)) if player != null else Vector2.ZERO

	var boss := boss_scene.instantiate() as BossEnemy
	boss.global_position = spawn_position
	get_tree().current_scene.add_child(boss)
	boss.boss_defeated.connect(_on_boss_defeated)

	boss_spawned.emit(boss, boss_data)


func _on_boss_defeated(boss_data: BossData) -> void:
	boss_defeated.emit(boss_data)

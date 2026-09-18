extends Node

## Autoload — registro de localidades + qual está ativa na run atual.
## EnemySpawner/BossDirector só perguntam a este autoload; nada de
## localidade fica hard-coded neles.

var pool: Array[LocationData] = []
var current: LocationData


func _ready() -> void:
	pool = [
		preload("res://resources/locations/china_domain.tres"),
		preload("res://resources/locations/greek_domain.tres"),
	]
	current = pool[0]


func get_by_id(id: String) -> LocationData:
	for location in pool:
		if location.id == id:
			return location
	return null


func set_current(id: String) -> bool:
	var location := get_by_id(id)
	if location == null:
		return false
	current = location
	return true

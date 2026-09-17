extends Node

## Autoload — catálogo de upgrades disponíveis para o level-up.
## Adicionar um novo upgrade = adicionar uma entrada aqui.

var pool: Array[UpgradeData] = []


func _ready() -> void:
	pool = [
		_make("damage", "+20% DANO", "Aumenta o dano de todas as armas em 20%.", UpgradeData.Type.DAMAGE, 0.2),
		_make("attack_speed", "+15% VELOCIDADE DE ATAQUE", "Reduz o intervalo entre ataques em 15%.", UpgradeData.Type.ATTACK_SPEED, 0.15),
		_make("move_speed", "+10% VELOCIDADE", "Aumenta a velocidade de movimento em 10%.", UpgradeData.Type.MOVE_SPEED, 0.1),
	]


func _make(id: String, title: String, description: String, type: UpgradeData.Type, value: float) -> UpgradeData:
	var data := UpgradeData.new()
	data.id = id
	data.title = title
	data.description = description
	data.type = type
	data.value = value
	return data


func get_random_upgrades(count: int = 3) -> Array[UpgradeData]:
	var shuffled := pool.duplicate()
	shuffled.shuffle()
	var result: Array[UpgradeData] = []
	for i in range(min(count, shuffled.size())):
		result.append(shuffled[i])
	return result

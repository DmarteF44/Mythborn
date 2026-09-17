extends Node

## Autoload — catálogo de passivas (e poderes-passiva) disponíveis na loja.
## Adicionar uma nova = adicionar uma entrada aqui.
##
## `title` é level-agnostic (ex.: "DANO", não "+20% DANO") — o nível atual e
## o valor percentual são calculados e exibidos pela UpgradeShop a partir de
## PlayerPassives + `value`, nunca hard-coded no texto.

var pool: Array[UpgradeData] = []


func _ready() -> void:
	pool = [
		_make("damage", "DANO", "Aumenta o dano de todas as armas.", UpgradeData.Type.DAMAGE, 0.2, 3, 15, ShopCategory.Type.PASSIVE),
		_make("attack_speed", "VELOCIDADE DE ATAQUE", "Reduz o intervalo entre ataques.", UpgradeData.Type.ATTACK_SPEED, 0.15, 3, 15, ShopCategory.Type.PASSIVE),
		_make("move_speed", "VELOCIDADE", "Aumenta a velocidade de movimento.", UpgradeData.Type.MOVE_SPEED, 0.1, 3, 15, ShopCategory.Type.PASSIVE),
		_make("vitality", "VIDA MÁXIMA", "Aumenta a vida máxima e cura a diferença.", UpgradeData.Type.VITALITY, 0.15, 3, 15, ShopCategory.Type.PASSIVE),
		_make("xp_mastery", "XP GANHO", "Aumenta o XP ganho de inimigos.", UpgradeData.Type.XP_GAIN, 0.1, 3, 15, ShopCategory.Type.PASSIVE),
		_make("magnetism", "MAGNETISMO", "Aumenta o raio de coleta de itens.", UpgradeData.Type.PICKUP_RADIUS, 25.0, 3, 15, ShopCategory.Type.PASSIVE),
		_make("cloud_somersault", "NUVEM VENTANIA", "Poder de Wukong: aumenta a velocidade de movimento.", UpgradeData.Type.MOVE_SPEED, 0.12, 3, 20, ShopCategory.Type.POWER),
	]


func _make(id: String, title: String, description: String, type: UpgradeData.Type, value: float, max_level: int, price: int, shop_category: ShopCategory.Type) -> UpgradeData:
	var data := UpgradeData.new()
	data.id = id
	data.title = title
	data.description = description
	data.type = type
	data.value = value
	data.max_level = max_level
	data.price = price
	data.shop_category = shop_category
	return data

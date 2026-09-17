extends Node

## Autoload — catálogo de passivas (e poderes-passiva) disponíveis na loja.
## Adicionar uma nova = adicionar uma entrada aqui.

var pool: Array[UpgradeData] = []


func _ready() -> void:
	pool = [
		_make("damage", "+20% DANO", "Aumenta o dano de todas as armas em 20%.", UpgradeData.Type.DAMAGE, 0.2, 15, ShopCategory.Type.PASSIVE),
		_make("attack_speed", "+15% VELOCIDADE DE ATAQUE", "Reduz o intervalo entre ataques em 15%.", UpgradeData.Type.ATTACK_SPEED, 0.15, 15, ShopCategory.Type.PASSIVE),
		_make("move_speed", "+10% VELOCIDADE", "Aumenta a velocidade de movimento em 10%.", UpgradeData.Type.MOVE_SPEED, 0.1, 15, ShopCategory.Type.PASSIVE),
		_make("vitality", "+15% VIDA MÁXIMA", "Aumenta a vida máxima em 15% e cura a diferença.", UpgradeData.Type.VITALITY, 0.15, 15, ShopCategory.Type.PASSIVE),
		_make("xp_mastery", "+10% XP GANHO", "Aumenta o XP ganho de inimigos em 10%.", UpgradeData.Type.XP_GAIN, 0.1, 15, ShopCategory.Type.PASSIVE),
		_make("cloud_somersault", "NUVEM VENTANIA", "Poder de Wukong: +12% de velocidade de movimento.", UpgradeData.Type.MOVE_SPEED, 0.12, 20, ShopCategory.Type.POWER),
	]


func _make(id: String, title: String, description: String, type: UpgradeData.Type, value: float, price: int, shop_category: ShopCategory.Type) -> UpgradeData:
	var data := UpgradeData.new()
	data.id = id
	data.title = title
	data.description = description
	data.type = type
	data.value = value
	data.price = price
	data.shop_category = shop_category
	return data

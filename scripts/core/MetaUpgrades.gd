extends Node

## Autoload — catálogo de melhorias permanentes (pagas em Fragmentos
## Míticos, nunca resetam com a run). Aplicadas em Player._ready() e
## exibidas/compradas pela tela de Progressão.

var pool: Array[MetaUpgradeData] = []


func _ready() -> void:
	pool = [
		_make("meta_damage", "Poder Ancestral", "Aumenta o dano base em todas as runs.", UpgradeData.Type.DAMAGE, 0.02, 5, 50),
		_make("meta_max_hp", "Vitalidade Ancestral", "Aumenta a vida máxima base em todas as runs.", UpgradeData.Type.VITALITY, 0.02, 5, 50),
	]


func get_by_id(id: String) -> MetaUpgradeData:
	for meta in pool:
		if meta.id == id:
			return meta
	return null


## Custo cresce a cada nível já comprado (nível 0 -> 1 custa a base; nível
## 4 -> 5 custa 5x a base), simples e centralizado em um único lugar.
func get_cost_for_next_level(meta: MetaUpgradeData, current_level: int) -> int:
	return meta.cost_per_level * (current_level + 1)


func try_purchase(id: String) -> bool:
	var meta := get_by_id(id)
	if meta == null:
		return false
	var current_level := MetaProgress.get_meta_upgrade_level(id)
	if current_level >= meta.max_level:
		return false
	var cost := get_cost_for_next_level(meta, current_level)
	if not MetaProgress.spend_currency(cost):
		return false
	MetaProgress.set_meta_upgrade_level(id, current_level + 1)
	return true


func _make(id: String, title: String, description: String, type: UpgradeData.Type, value_per_level: float, max_level: int, cost_per_level: int) -> MetaUpgradeData:
	var data := MetaUpgradeData.new()
	data.id = id
	data.display_name = title
	data.description = description
	data.type = type
	data.value_per_level = value_per_level
	data.max_level = max_level
	data.cost_per_level = cost_per_level
	return data

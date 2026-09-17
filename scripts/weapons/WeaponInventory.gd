class_name WeaponInventory
extends Node2D

## Fonte única de verdade sobre as armas equipadas pelo jogador.
##
## REGRA OFICIAL: uma mesma arma pode existir em várias cópias e níveis
## independentes. Cada cópia ocupa 1 dos 12 slots. Fundir 2 cópias iguais do
## mesmo nível (mesmo id) é uma ação OPCIONAL do jogador (ver fuse()) — nunca
## automática ao comprar/receber uma duplicata.

signal weapon_added(weapon: Weapon)
signal weapon_fused(weapon: Weapon)

var weapons: Array[Weapon] = []

@onready var _owner_stats: PlayerStats = get_parent().get_node("PlayerStats")


func add_weapon(weapon_scene: PackedScene) -> Weapon:
	if weapons.size() >= GameManager.MAX_WEAPONS:
		return null

	var weapon := weapon_scene.instantiate() as Weapon
	weapon.stats = _owner_stats
	add_child(weapon)
	weapons.append(weapon)
	weapon_added.emit(weapon)
	return weapon


## Apenas para exibição na loja ("nova cópia" vs "comprar") — nunca bloqueia
## uma aquisição.
func has_weapon(weapon_id: String) -> bool:
	for weapon in weapons:
		if weapon.weapon_data.id == weapon_id:
			return true
	return false


func is_full() -> bool:
	return weapons.size() >= GameManager.MAX_WEAPONS


## Agrupa as cópias por (id, nível) para a UI ("Ruyi Lv.1 × 5"), já
## ordenado por arma e depois por nível.
func get_grouped_weapons() -> Array[Dictionary]:
	var groups: Dictionary = {}
	for weapon in weapons:
		var key := "%s:%d" % [weapon.weapon_data.id, weapon.current_level]
		if not groups.has(key):
			groups[key] = {"weapon_data": weapon.weapon_data, "level": weapon.current_level, "count": 0}
		groups[key]["count"] += 1

	var result: Array[Dictionary] = []
	for key in groups:
		result.append(groups[key])
	result.sort_custom(func(a, b):
		if a["weapon_data"].id == b["weapon_data"].id:
			return a["level"] < b["level"]
		return a["weapon_data"].id < b["weapon_data"].id
	)
	return result


## Fusão voluntária: consome 2 cópias de weapon_id no nível `level` e produz
## 1 cópia no nível seguinte (reaproveitando a instância "sobrevivente" em
## vez de destruir e recriar). Retorna false se não houver 2 cópias, ou se
## já estiver no nível máximo daquela arma.
func fuse(weapon_id: String, level: int) -> bool:
	var matches: Array[Weapon] = []
	for weapon in weapons:
		if weapon.weapon_data.id == weapon_id and weapon.current_level == level:
			matches.append(weapon)
			if matches.size() == 2:
				break

	if matches.size() < 2:
		return false
	if level >= matches[0].weapon_data.max_level:
		return false

	var survivor := matches[0]
	var consumed := matches[1]
	survivor.set_level(level + 1)
	weapons.erase(consumed)
	consumed.queue_free()
	weapon_fused.emit(survivor)
	return true

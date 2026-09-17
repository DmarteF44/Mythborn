class_name WeaponInventory
extends Node2D

## Fonte única de verdade sobre as armas equipadas pelo jogador.

signal weapon_added(weapon: Weapon)

var weapons: Array[Weapon] = []

@onready var _owner_stats: PlayerStats = get_parent().get_node("PlayerStats")


func add_weapon(weapon_scene: PackedScene) -> Weapon:
	if weapons.size() >= GameManager.MAX_WEAPONS:
		return null

	var weapon := weapon_scene.instantiate() as Weapon

	# Evita duplicar uma arma que o jogador já tenha (ex.: evolução de
	# personagem concedendo um poder que já foi comprado na loja antes).
	if has_weapon(weapon.weapon_data.id):
		weapon.queue_free()
		return null

	weapon.stats = _owner_stats
	add_child(weapon)
	weapons.append(weapon)
	weapon_added.emit(weapon)
	return weapon


func has_weapon(weapon_id: String) -> bool:
	for weapon in weapons:
		if weapon.weapon_data.id == weapon_id:
			return true
	return false


func is_full() -> bool:
	return weapons.size() >= GameManager.MAX_WEAPONS

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
	weapon.stats = _owner_stats
	add_child(weapon)
	weapons.append(weapon)
	weapon_added.emit(weapon)
	return weapon


func is_full() -> bool:
	return weapons.size() >= GameManager.MAX_WEAPONS

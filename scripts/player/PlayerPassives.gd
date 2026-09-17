class_name PlayerPassives
extends Node

## Nível atual de cada passiva/poder-passivo do jogador (por id). Diferente
## de armas: uma passiva NÃO tem múltiplas instâncias, apenas 1 nível que
## sobe a cada compra — comprar a mesma passiva de novo melhora o nível
## existente, nunca cria uma segunda "cópia".

signal passive_changed(id: String, level: int)

var levels: Dictionary = {}

@onready var _stats: PlayerStats = get_parent().get_node("PlayerStats")
@onready var _health: Health = get_parent().get_node("Health")
@onready var _experience: PlayerExperience = get_parent().get_node("PlayerExperience")
@onready var _pickup_magnet: PickupMagnet = get_parent().get_node("PickupMagnet")


func get_level(upgrade_id: String) -> int:
	return levels.get(upgrade_id, 0)


func can_upgrade(upgrade: UpgradeData) -> bool:
	return get_level(upgrade.id) < upgrade.max_level


func apply(upgrade: UpgradeData) -> void:
	var new_level: int = get_level(upgrade.id) + 1
	levels[upgrade.id] = new_level

	match upgrade.type:
		UpgradeData.Type.VITALITY:
			_health.apply_max_health_multiplier(1.0 + upgrade.value)
		UpgradeData.Type.XP_GAIN:
			_experience.xp_gain_mult += upgrade.value
		UpgradeData.Type.PICKUP_RADIUS:
			_stats.pickup_radius_bonus += upgrade.value
			_pickup_magnet.set_radius(_stats.get_pickup_radius())
		_:
			_stats.apply_upgrade(upgrade)

	passive_changed.emit(upgrade.id, new_level)

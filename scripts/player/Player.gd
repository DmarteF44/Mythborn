class_name Player
extends CharacterBody2D

@onready var stats: PlayerStats = $PlayerStats
@onready var health: Health = $Health
@onready var experience: PlayerExperience = $PlayerExperience
@onready var weapon_inventory: WeaponInventory = $WeaponInventory
@onready var progression: CharacterProgression = $CharacterProgression
@onready var passives: PlayerPassives = $PlayerPassives
@onready var pickup_magnet: PickupMagnet = $PickupMagnet
@onready var visual: CanvasItem = $Visual


var _last_health: float = -1.0


func _ready() -> void:
	add_to_group("player")

	var character_data := progression.character_data
	health.max_health = character_data.base_health
	health.current_health = character_data.base_health
	stats.base_move_speed = character_data.base_move_speed

	_apply_meta_upgrades()
	visual.modulate = Skins.get_equipped_tint(character_data.id)

	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

	weapon_inventory.add_weapon(character_data.starting_weapon)
	pickup_magnet.set_radius(stats.get_pickup_radius())


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * stats.get_move_speed()
	move_and_slide()


## Progressão permanente (entre partidas) — cada nível comprado em
## MetaUpgrades.pool aplica seu bônus aqui, uma vez, no início da run.
func _apply_meta_upgrades() -> void:
	for meta in MetaUpgrades.pool:
		var level := MetaProgress.get_meta_upgrade_level(meta.id)
		if level <= 0:
			continue
		var total_value := meta.value_per_level * level
		match meta.type:
			UpgradeData.Type.VITALITY:
				health.apply_max_health_multiplier(1.0 + total_value)
			UpgradeData.Type.DAMAGE:
				stats.damage_mult += total_value
			UpgradeData.Type.ATTACK_SPEED:
				stats.attack_speed_mult += total_value
			UpgradeData.Type.MOVE_SPEED:
				stats.move_speed_mult += total_value


func _on_health_changed(current: float, _max_value: float) -> void:
	if _last_health >= 0.0 and current < _last_health:
		Settings.trigger_haptic()
	_last_health = current


func _on_died() -> void:
	GameManager.trigger_game_over()

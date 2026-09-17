class_name HUD
extends CanvasLayer

signal pause_requested

@onready var health_bar: ProgressBar = $TopBar/HBox/StatsVBox/HealthBar
@onready var xp_bar: ProgressBar = $TopBar/HBox/StatsVBox/XPBar
@onready var level_label: Label = $TopBar/HBox/StatsVBox/InfoRow/LevelLabel
@onready var timer_label: Label = $TopBar/HBox/StatsVBox/InfoRow/TimerLabel
@onready var weapon_label: Label = $TopBar/HBox/StatsVBox/WeaponLabel
@onready var pause_button: Button = $TopBar/HBox/PauseButton


func _ready() -> void:
	pause_button.pressed.connect(func() -> void: pause_requested.emit())


func _process(_delta: float) -> void:
	timer_label.text = RunStats.format_time(RunStats.survival_time)


func bind_to_player(player: Player) -> void:
	player.health.health_changed.connect(_on_health_changed)
	health_bar.max_value = player.health.max_health
	health_bar.value = player.health.current_health

	player.experience.xp_changed.connect(_on_xp_changed)
	player.experience.leveled_up.connect(_on_leveled_up)
	_on_xp_changed(player.experience.current_xp, player.experience.xp_to_next)
	_on_leveled_up(player.experience.level)

	player.weapon_inventory.weapon_added.connect(_on_weapon_added)
	_update_weapon_label(player.weapon_inventory.weapons)


func _on_health_changed(current: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = current


func _on_xp_changed(current: float, to_next: float) -> void:
	xp_bar.max_value = to_next
	xp_bar.value = current


func _on_leveled_up(new_level: int) -> void:
	level_label.text = "Nível %d" % new_level


func _on_weapon_added(_weapon: Weapon) -> void:
	var player := TargetingUtils.get_player() as Player
	if player != null:
		_update_weapon_label(player.weapon_inventory.weapons)


func _update_weapon_label(weapons: Array[Weapon]) -> void:
	var names: Array[String] = []
	for weapon in weapons:
		names.append(weapon.weapon_data.display_name)
	weapon_label.text = "Armas (%d/%d): %s" % [weapons.size(), GameManager.MAX_WEAPONS, ", ".join(names)]

class_name HUD
extends CanvasLayer

signal pause_requested

@onready var health_bar: ProgressBar = $TopBar/HBox/StatsVBox/HealthBar
@onready var xp_bar: ProgressBar = $TopBar/HBox/StatsVBox/XPBar
@onready var level_label: Label = $TopBar/HBox/StatsVBox/InfoRow/LevelLabel
@onready var stage_label: Label = $TopBar/HBox/StatsVBox/InfoRow/StageLabel
@onready var timer_label: Label = $TopBar/HBox/StatsVBox/ResourceRow/TimerLabel
@onready var essence_label: Label = $TopBar/HBox/StatsVBox/ResourceRow/EssenceLabel
@onready var weapon_label: Label = $TopBar/HBox/StatsVBox/WeaponLabel
@onready var pause_button: Button = $TopBar/HBox/PauseButton

@onready var boss_bar_layer: Control = $BossBar
@onready var boss_name_label: Label = $BossBar/VBox/BossNameLabel
@onready var boss_health_bar: ProgressBar = $BossBar/VBox/BossHealthBar

var _player: Player = null
var _boss: BossEnemy = null


func _ready() -> void:
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	Economy.essence_changed.connect(_on_essence_changed)
	_on_essence_changed(Economy.essence)
	boss_bar_layer.visible = false


func _process(_delta: float) -> void:
	timer_label.text = RunStats.format_time(RunStats.survival_time)


func bind_to_player(player: Player) -> void:
	_player = player

	player.health.health_changed.connect(_on_health_changed)
	health_bar.max_value = player.health.max_health
	health_bar.value = player.health.current_health

	player.experience.xp_changed.connect(_on_xp_changed)
	player.experience.leveled_up.connect(_on_leveled_up)
	_on_xp_changed(player.experience.current_xp, player.experience.xp_to_next)
	_on_leveled_up(player.experience.level)

	player.progression.evolved.connect(func(_evo: CharacterEvolutionData) -> void: _update_stage_label())
	_update_stage_label()

	player.weapon_inventory.weapon_added.connect(_on_weapon_inventory_changed)
	player.weapon_inventory.weapon_fused.connect(func(_w: Weapon) -> void: _update_weapon_label())
	_update_weapon_label()


func _on_health_changed(current: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = current


func _on_xp_changed(current: float, to_next: float) -> void:
	xp_bar.max_value = to_next
	xp_bar.value = current


func _on_leveled_up(new_level: int) -> void:
	level_label.text = "LV %d" % new_level


func _on_essence_changed(current: int) -> void:
	essence_label.text = "Essência %d" % current


func _update_stage_label() -> void:
	stage_label.text = _player.progression.get_display_name()


func _on_weapon_inventory_changed(_weapon: Weapon) -> void:
	_update_weapon_label()


func _update_weapon_label() -> void:
	if _player == null:
		return
	var parts: Array[String] = []
	for group in _player.weapon_inventory.get_grouped_weapons():
		var weapon_data: WeaponData = group["weapon_data"]
		parts.append("%s Lv.%d×%d" % [weapon_data.display_name, group["level"], group["count"]])
	weapon_label.text = "Armas %d/%d: %s" % [_player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS, ", ".join(parts)]


func show_boss_bar(boss: BossEnemy, display_name: String) -> void:
	_boss = boss
	boss_name_label.text = display_name.to_upper()
	boss_health_bar.max_value = boss.health.max_health
	boss_health_bar.value = boss.health.current_health
	boss.boss_health_changed.connect(_on_boss_health_changed)
	boss_bar_layer.visible = true


func hide_boss_bar() -> void:
	_boss = null
	boss_bar_layer.visible = false


func _on_boss_health_changed(current: float, max_value: float) -> void:
	boss_health_bar.max_value = max_value
	boss_health_bar.value = current

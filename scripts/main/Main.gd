extends Node2D

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var level_up_screen: LevelUpScreen = $LevelUpScreen
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_screen: GameOverScreen = $GameOverScreen


func _ready() -> void:
	hud.bind_to_player(player)
	hud.pause_requested.connect(_on_pause_requested)

	player.experience.leveled_up.connect(_on_player_leveled_up)
	level_up_screen.upgrade_chosen.connect(_on_upgrade_chosen)

	player.weapon_inventory.weapon_added.connect(_on_weapon_added)
	RunStats.set_weapons_owned(player.weapon_inventory.weapons.size())

	GameManager.game_over.connect(_on_game_over)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GameManager.state == GameManager.State.PLAYING:
		_on_pause_requested()


func _on_pause_requested() -> void:
	GameManager.open_pause()
	pause_menu.open()


func _on_player_leveled_up(new_level: int) -> void:
	RunStats.level_reached = new_level
	GameManager.open_level_up()
	level_up_screen.show_options(Upgrades.get_random_upgrades(3))


func _on_upgrade_chosen(upgrade: UpgradeData) -> void:
	player.stats.apply_upgrade(upgrade)
	RunStats.register_upgrade()
	GameManager.resume_gameplay()


func _on_weapon_added(_weapon: Weapon) -> void:
	RunStats.set_weapons_owned(player.weapon_inventory.weapons.size())


func _on_game_over() -> void:
	game_over_screen.show_results()

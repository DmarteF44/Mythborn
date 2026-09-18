extends Node2D

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var evolution_screen: EvolutionScreen = $EvolutionScreen
@onready var upgrade_shop: UpgradeShop = $UpgradeShop
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var boss_director: BossDirector = $BossDirector


func _ready() -> void:
	MetaProgress.discover_location(Locations.current.id)

	hud.bind_to_player(player)
	hud.pause_requested.connect(_on_pause_requested)

	player.experience.leveled_up.connect(_on_player_leveled_up)
	evolution_screen.continued.connect(_open_upgrade_shop)
	upgrade_shop.closed.connect(_on_upgrade_shop_closed)

	player.weapon_inventory.weapon_added.connect(_on_weapon_added)
	RunStats.set_weapons_owned(player.weapon_inventory.weapons.size())

	boss_director.boss_spawned.connect(_on_boss_spawned)
	boss_director.boss_defeated.connect(_on_boss_defeated)

	GameManager.game_over.connect(_on_game_over)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GameManager.state == GameManager.State.PLAYING:
		_on_pause_requested()


func _on_pause_requested() -> void:
	GameManager.open_pause()
	pause_menu.open()


func _on_player_leveled_up(new_level: int) -> void:
	RunStats.level_reached = new_level
	Economy.grant_level_up_reward()

	var evolution := player.progression.check_level(new_level)
	if evolution != null:
		RunStats.evolution_stage_reached = player.progression.current_stage_index
		GameManager.open_evolution()
		evolution_screen.show_evolution(player.progression.get_previous_display_name(), evolution)
	else:
		_open_upgrade_shop()


func _open_upgrade_shop() -> void:
	GameManager.open_upgrade_shop()
	upgrade_shop.open(player)


func _on_upgrade_shop_closed() -> void:
	GameManager.resume_gameplay()


func _on_weapon_added(_weapon: Weapon) -> void:
	RunStats.set_weapons_owned(player.weapon_inventory.weapons.size())


func _on_boss_spawned(boss: BossEnemy, boss_data: BossData) -> void:
	hud.show_boss_bar(boss, boss_data.display_name)


func _on_boss_defeated(_boss_data: BossData) -> void:
	hud.hide_boss_bar()


func _on_game_over() -> void:
	MetaProgress.update_record("best_survival_time", RunStats.survival_time)
	MetaProgress.update_record("best_level", RunStats.level_reached)
	game_over_screen.show_results(player)

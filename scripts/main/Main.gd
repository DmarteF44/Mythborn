extends Node2D

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var level_up_screen: LevelUpScreen = $LevelUpScreen
@onready var game_over_label: Label = $GameOverLayer/GameOverLabel


func _ready() -> void:
	hud.bind_to_player(player)
	player.experience.leveled_up.connect(_on_player_leveled_up)
	level_up_screen.upgrade_chosen.connect(_on_upgrade_chosen)
	GameManager.game_over.connect(_on_game_over)
	game_over_label.visible = false


func _on_player_leveled_up(_new_level: int) -> void:
	GameManager.pause_for_level_up()
	level_up_screen.show_options(Upgrades.get_random_upgrades(3))


func _on_upgrade_chosen(upgrade: UpgradeData) -> void:
	player.stats.apply_upgrade(upgrade)
	GameManager.resume()


func _on_game_over() -> void:
	game_over_label.visible = true

extends Control

@onready var play_button: Button = $CenterContainer/VBox/PlayButton
@onready var settings_button: Button = $CenterContainer/VBox/SettingsButton
@onready var settings_menu: SettingsMenu = $SettingsMenu

@onready var progression_button: Button = $CenterContainer/VBox/FutureRow/Progression
@onready var achievements_button: Button = $CenterContainer/VBox/FutureRow/Achievements
@onready var meta_upgrade_screen: MetaUpgradeScreen = $MetaUpgradeScreen
@onready var achievements_screen: AchievementsScreen = $AchievementsScreen


func _ready() -> void:
	GameManager.state = GameManager.State.MAIN_MENU
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(settings_menu.open)
	progression_button.pressed.connect(meta_upgrade_screen.open)
	achievements_button.pressed.connect(achievements_screen.open)


func _on_play_pressed() -> void:
	GameManager.start_new_run()

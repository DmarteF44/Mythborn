extends Control

@onready var play_button: Button = $CenterContainer/VBox/PlayButton
@onready var settings_button: Button = $CenterContainer/VBox/SettingsButton
@onready var settings_menu: SettingsMenu = $SettingsMenu


func _ready() -> void:
	GameManager.state = GameManager.State.MAIN_MENU
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(settings_menu.open)


func _on_play_pressed() -> void:
	GameManager.start_new_run()

class_name GameOverScreen
extends CanvasLayer

@onready var time_label: Label = $CenterContainer/Panel/VBox/Stats/TimeValue
@onready var level_label: Label = $CenterContainer/Panel/VBox/Stats/LevelValue
@onready var enemies_label: Label = $CenterContainer/Panel/VBox/Stats/EnemiesValue
@onready var upgrades_label: Label = $CenterContainer/Panel/VBox/Stats/UpgradesValue
@onready var retry_button: Button = $CenterContainer/Panel/VBox/RetryButton
@onready var menu_button: Button = $CenterContainer/Panel/VBox/MenuButton


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func show_results() -> void:
	time_label.text = RunStats.format_time(RunStats.survival_time)
	level_label.text = str(RunStats.level_reached)
	enemies_label.text = str(RunStats.enemies_defeated)
	upgrades_label.text = str(RunStats.upgrades_taken)
	visible = true


func _on_retry_pressed() -> void:
	GameManager.start_new_run()


func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()

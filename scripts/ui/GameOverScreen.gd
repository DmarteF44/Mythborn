class_name GameOverScreen
extends CanvasLayer

@onready var time_label: Label = $CenterContainer/Panel/VBox/Stats/TimeValue
@onready var level_label: Label = $CenterContainer/Panel/VBox/Stats/LevelValue
@onready var enemies_label: Label = $CenterContainer/Panel/VBox/Stats/EnemiesValue
@onready var upgrades_label: Label = $CenterContainer/Panel/VBox/Stats/UpgradesValue
@onready var bosses_label: Label = $CenterContainer/Panel/VBox/Stats/BossesValue
@onready var reward_label: Label = $CenterContainer/Panel/VBox/RewardLabel
@onready var retry_button: Button = $CenterContainer/Panel/VBox/RetryButton
@onready var menu_button: Button = $CenterContainer/Panel/VBox/MenuButton

var _reward_applied: bool = false


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func show_results() -> void:
	time_label.text = RunStats.format_time(RunStats.survival_time)
	level_label.text = str(RunStats.level_reached)
	enemies_label.text = str(RunStats.enemies_defeated)
	upgrades_label.text = str(RunStats.upgrades_taken)
	bosses_label.text = str(RunStats.bosses_defeated)
	reward_label.text = "+%d Fragmentos Míticos" % _grant_end_of_run_reward()
	visible = true


## Recompensa simples por ter jogado a run (separada da recompensa de boss/
## conquista, que já é creditada por RewardResolver assim que acontece).
## Guardado por `_reward_applied` para nunca ser aplicada duas vezes.
func _grant_end_of_run_reward() -> int:
	if _reward_applied:
		return int(RunStats.survival_time / 10.0) + RunStats.level_reached * 2
	_reward_applied = true
	var amount := int(RunStats.survival_time / 10.0) + RunStats.level_reached * 2
	MetaProgress.add_currency(amount)
	return amount


func _on_retry_pressed() -> void:
	GameManager.start_new_run()


func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()

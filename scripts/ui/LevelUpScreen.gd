class_name LevelUpScreen
extends CanvasLayer

signal upgrade_chosen(upgrade: UpgradeData)

@onready var panel: Control = $Panel
@onready var buttons: Array[Button] = [
	$Panel/VBox/OptionButton1,
	$Panel/VBox/OptionButton2,
	$Panel/VBox/OptionButton3,
]

var _current_options: Array[UpgradeData] = []


func _ready() -> void:
	visible = false
	for i in buttons.size():
		buttons[i].pressed.connect(_on_button_pressed.bind(i))


func show_options(options: Array[UpgradeData]) -> void:
	_current_options = options
	for i in buttons.size():
		if i < options.size():
			var upgrade := options[i]
			buttons[i].text = "%s\n%s" % [upgrade.title, upgrade.description]
			buttons[i].visible = true
		else:
			buttons[i].visible = false
	visible = true


func _on_button_pressed(index: int) -> void:
	if index >= _current_options.size():
		return
	visible = false
	upgrade_chosen.emit(_current_options[index])

class_name LevelUpScreen
extends CanvasLayer

signal upgrade_chosen(upgrade: UpgradeData)

@onready var option_cards: Array[Button] = [
	$Panel/Background/VBox/Option1,
	$Panel/Background/VBox/Option2,
	$Panel/Background/VBox/Option3,
]

var _current_options: Array[UpgradeData] = []


func _ready() -> void:
	visible = false
	for i in option_cards.size():
		option_cards[i].pressed.connect(_on_option_pressed.bind(i))


func show_options(options: Array[UpgradeData]) -> void:
	_current_options = options
	for i in option_cards.size():
		var card := option_cards[i]
		if i < options.size():
			var upgrade := options[i]
			card.get_node("VBox/TitleLabel").text = upgrade.title
			card.get_node("VBox/DescriptionLabel").text = upgrade.description
			card.visible = true
		else:
			card.visible = false
	visible = true


func _on_option_pressed(index: int) -> void:
	if index >= _current_options.size():
		return
	visible = false
	upgrade_chosen.emit(_current_options[index])

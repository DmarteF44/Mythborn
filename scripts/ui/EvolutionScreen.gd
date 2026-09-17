class_name EvolutionScreen
extends CanvasLayer

signal continued

@onready var from_label: Label = $CenterContainer/Panel/VBox/FromLabel
@onready var to_label: Label = $CenterContainer/Panel/VBox/ToLabel
@onready var bonus_label: Label = $CenterContainer/Panel/VBox/BonusLabel
@onready var power_label: Label = $CenterContainer/Panel/VBox/PowerLabel
@onready var continue_button: Button = $CenterContainer/Panel/VBox/ContinueButton


func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)


func show_evolution(previous_name: String, evo: CharacterEvolutionData) -> void:
	from_label.text = previous_name
	to_label.text = evo.display_name
	bonus_label.text = _format_bonuses(evo)

	if evo.unlocked_power_label != "":
		power_label.text = "NOVO PODER: %s" % evo.unlocked_power_label
		power_label.visible = true
	else:
		power_label.visible = false

	visible = true


func _format_bonuses(evo: CharacterEvolutionData) -> String:
	var parts: Array[String] = []
	if evo.health_bonus_mult > 1.0:
		parts.append("+%d%% Vida" % round((evo.health_bonus_mult - 1.0) * 100))
	if evo.move_speed_bonus_mult > 1.0:
		parts.append("+%d%% Velocidade" % round((evo.move_speed_bonus_mult - 1.0) * 100))
	if evo.damage_bonus_mult > 1.0:
		parts.append("+%d%% Dano" % round((evo.damage_bonus_mult - 1.0) * 100))
	if evo.attack_speed_bonus_mult > 1.0:
		parts.append("+%d%% Vel. de Ataque" % round((evo.attack_speed_bonus_mult - 1.0) * 100))
	return " · ".join(parts)


func _on_continue_pressed() -> void:
	visible = false
	continued.emit()

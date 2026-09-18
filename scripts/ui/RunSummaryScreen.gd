class_name RunSummaryScreen
extends CanvasLayer

## Última etapa antes de `GameManager.start_new_run()` — só lê o que já foi
## escolhido em RunConfig/Locations (fonte única de verdade), nunca guarda
## seu próprio estado de seleção.

signal start_pressed
signal back_pressed

@onready var content_container: VBoxContainer = $CenterContainer/Panel/VBox/ContentContainer
@onready var start_button: Button = $CenterContainer/Panel/VBox/StartButton
@onready var back_button: Button = $CenterContainer/Panel/VBox/BackButton


func _ready() -> void:
	visible = false
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	back_button.pressed.connect(func() -> void: back_pressed.emit())


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		back_pressed.emit()


func open() -> void:
	_render()
	visible = true


func close() -> void:
	visible = false


func _render() -> void:
	for child in content_container.get_children():
		child.queue_free()

	var character := Characters.get_by_id(RunConfig.selected_character_id)
	var character_name := character.display_name if character != null else "?"

	var skin_name := "Padrão"
	for skin in Skins.get_options_for_character(RunConfig.selected_character_id):
		if skin.id == RunConfig.selected_skin_id:
			skin_name = skin.display_name

	var challenge_name := RunConfig.current_challenge.display_name if RunConfig.current_challenge != null else "Normal"

	content_container.add_child(_row("PERSONAGEM", character_name))
	content_container.add_child(_row("SKIN", skin_name))
	content_container.add_child(_row("LOCALIDADE", Locations.current.display_name))
	content_container.add_child(_row("MODO", RunConfig.current_mode.display_name))
	content_container.add_child(_row("DESAFIO", challenge_name))


func _row(label_text: String, value_text: String) -> Control:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 16)
	label.modulate = Color(1, 1, 1, 0.6)
	hbox.add_child(label)
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_size_override("font_size", 18)
	hbox.add_child(value)
	return hbox

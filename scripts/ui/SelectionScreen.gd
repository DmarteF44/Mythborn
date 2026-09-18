class_name SelectionScreen
extends CanvasLayer

## Tela de seleção genérica e reutilizável — usada por RunSetupFlow para
## Personagem, Skin, Localidade, Modo e Desafio. Não sabe nada sobre o que
## está selecionando: só recebe uma lista de opções (Dictionary) e emite
## qual foi escolhida. Isso evita 5 telas quase idênticas duplicando layout
## e lógica de "cartão bloqueado/desbloqueado".

signal option_selected(id: String)
signal back_pressed

@onready var title_label: Label = $CenterContainer/Panel/VBox/Title
@onready var list_container: VBoxContainer = $CenterContainer/Panel/VBox/Scroll/ListContainer
@onready var back_button: Button = $CenterContainer/Panel/VBox/BackButton


func _ready() -> void:
	visible = false
	back_button.pressed.connect(func() -> void: back_pressed.emit())


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		back_pressed.emit()


## `options`: Array[Dictionary] com chaves:
##   id (String), title (String), subtitle (String, opcional),
##   description (String, opcional), locked (bool), locked_reason (String),
##   selected (bool, destaca a opção atual), action_label (String, default "SELECIONAR").
func open(title: String, options: Array) -> void:
	title_label.text = title
	for child in list_container.get_children():
		child.queue_free()
	for option in options:
		list_container.add_child(_build_row(option))
	visible = true


func close() -> void:
	visible = false


func _build_row(option: Dictionary) -> Control:
	var locked: bool = option.get("locked", false)
	var selected: bool = option.get("selected", false)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.22, 0.18, 1) if selected else Color(0.16, 0.17, 0.22, 1)
	if locked:
		style.bg_color = Color(0.12, 0.12, 0.14, 1)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12
	if selected:
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.5, 1, 0.6, 1)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var title := Label.new()
	title.text = ("%s ✓" % option["title"]) if selected else ("%s 🔒" % option["title"] if locked else String(option["title"]))
	title.add_theme_font_size_override("font_size", 20)
	title.modulate = Color(1, 1, 1, 0.5) if locked else Color(1, 1, 1, 1)
	text_vbox.add_child(title)

	if option.get("subtitle", "") != "":
		var subtitle := Label.new()
		subtitle.text = option["subtitle"]
		subtitle.add_theme_font_size_override("font_size", 13)
		subtitle.modulate = Color(1, 1, 1, 0.55)
		text_vbox.add_child(subtitle)

	if option.get("description", "") != "":
		var desc := Label.new()
		desc.text = option["description"] if not locked else option.get("locked_reason", "Bloqueado.")
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc.add_theme_font_size_override("font_size", 13)
		desc.modulate = Color(1, 1, 1, 0.7)
		text_vbox.add_child(desc)

	var action_button := Button.new()
	action_button.custom_minimum_size = Vector2(130, 56)
	if locked:
		action_button.text = "???"
		action_button.disabled = true
	else:
		action_button.text = option.get("action_label", "SELECIONAR")
		action_button.pressed.connect(func() -> void: option_selected.emit(option["id"]))
	hbox.add_child(action_button)

	return panel

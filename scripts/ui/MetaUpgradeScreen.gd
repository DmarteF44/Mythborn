class_name MetaUpgradeScreen
extends CanvasLayer

## Tela mínima de progressão permanente: 2 melhorias funcionais (ver
## MetaUpgrades.pool), pagas em Fragmentos Míticos, nunca resetam com a run.

@onready var currency_label: Label = $CenterContainer/Panel/VBox/CurrencyLabel
@onready var list_container: VBoxContainer = $CenterContainer/Panel/VBox/ListContainer
@onready var back_button: Button = $CenterContainer/Panel/VBox/BackButton


func _ready() -> void:
	visible = false
	back_button.pressed.connect(close)
	MetaProgress.currency_changed.connect(func(_v: int) -> void: _render())


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func open() -> void:
	_render()
	visible = true


func close() -> void:
	visible = false


func _render() -> void:
	currency_label.text = "Fragmentos Míticos: %d" % MetaProgress.currency

	for child in list_container.get_children():
		child.queue_free()

	for meta in MetaUpgrades.pool:
		list_container.add_child(_build_row(meta))


func _build_row(meta: MetaUpgradeData) -> Control:
	var level := MetaProgress.get_meta_upgrade_level(meta.id)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.17, 0.22, 1)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 16
	style.content_margin_top = 10
	style.content_margin_right = 16
	style.content_margin_bottom = 10

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var title := Label.new()
	title.text = "%s — Nível %d/%d" % [meta.display_name, level, meta.max_level]
	title.add_theme_font_size_override("font_size", 18)
	text_vbox.add_child(title)

	var desc := Label.new()
	desc.text = meta.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 13)
	desc.modulate = Color(1, 1, 1, 0.7)
	text_vbox.add_child(desc)

	var effect := Label.new()
	var current_pct := int(round(meta.value_per_level * level * 100))
	var next_pct := int(round(meta.value_per_level * (level + 1) * 100))
	effect.text = "Atual: +%d%%  →  Próximo: +%d%%" % [current_pct, next_pct] if level < meta.max_level else "Atual: +%d%% (MAX)" % current_pct
	effect.add_theme_font_size_override("font_size", 13)
	effect.modulate = Color(0.7, 0.95, 1, 1)
	text_vbox.add_child(effect)

	var buy_button := Button.new()
	buy_button.custom_minimum_size = Vector2(120, 64)
	if level >= meta.max_level:
		buy_button.text = "MAX"
		buy_button.disabled = true
	else:
		var cost := MetaUpgrades.get_cost_for_next_level(meta, level)
		buy_button.text = str(cost)
		buy_button.disabled = MetaProgress.currency < cost
		buy_button.pressed.connect(_on_buy_pressed.bind(meta.id))
	hbox.add_child(buy_button)

	return panel


func _on_buy_pressed(id: String) -> void:
	MetaUpgrades.try_purchase(id)
	_render()

class_name AchievementsScreen
extends CanvasLayer

## Lista somente-leitura das conquistas (Achievements.pool). Conquistas
## secretas mostram "???" até serem desbloqueadas.

@onready var list_container: VBoxContainer = $CenterContainer/Panel/VBox/Scroll/ListContainer
@onready var back_button: Button = $CenterContainer/Panel/VBox/BackButton


func _ready() -> void:
	visible = false
	back_button.pressed.connect(close)


func open() -> void:
	_render()
	visible = true


func close() -> void:
	visible = false


func _render() -> void:
	for child in list_container.get_children():
		child.queue_free()

	for achievement in Achievements.pool:
		list_container.add_child(_build_row(achievement))


func _build_row(achievement: AchievementData) -> Control:
	var unlocked := Achievements.is_unlocked(achievement.id)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.17, 0.22, 1) if unlocked else Color(0.12, 0.12, 0.14, 1)
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

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var title := Label.new()
	var desc := Label.new()

	if unlocked:
		title.text = achievement.display_name
		desc.text = achievement.description
	elif achievement.secret:
		title.text = "???"
		desc.text = "Conquista secreta."
	else:
		title.text = "%s 🔒" % achievement.display_name
		desc.text = achievement.description

	title.add_theme_font_size_override("font_size", 18)
	title.modulate = Color(1, 0.85, 0.3, 1) if unlocked else Color(1, 1, 1, 0.6)
	vbox.add_child(title)

	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 13)
	desc.modulate = Color(1, 1, 1, 0.6)
	vbox.add_child(desc)

	return panel

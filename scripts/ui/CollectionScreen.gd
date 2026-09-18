class_name CollectionScreen
extends CanvasLayer

## Hub somente-leitura: Personagens / Skins / Localidades / Bosses /
## Conquistas. Cada aba só lê dados já existentes (Characters/Skins/
## Locations/MetaProgress/Achievements) — nenhum estado próprio de coleção.

enum Tab { CHARACTERS, SKINS, LOCATIONS, BOSSES, ACHIEVEMENTS }

@onready var characters_tab: Button = $CenterContainer/Panel/VBox/Tabs/CharactersTab
@onready var skins_tab: Button = $CenterContainer/Panel/VBox/Tabs/SkinsTab
@onready var locations_tab: Button = $CenterContainer/Panel/VBox/Tabs/LocationsTab
@onready var bosses_tab: Button = $CenterContainer/Panel/VBox/Tabs/BossesTab
@onready var achievements_tab: Button = $CenterContainer/Panel/VBox/Tabs/AchievementsTab
@onready var content_container: VBoxContainer = $CenterContainer/Panel/VBox/Scroll/ContentContainer
@onready var back_button: Button = $CenterContainer/Panel/VBox/BackButton


func _ready() -> void:
	visible = false
	back_button.pressed.connect(close)
	characters_tab.pressed.connect(func() -> void: _show_tab(Tab.CHARACTERS))
	skins_tab.pressed.connect(func() -> void: _show_tab(Tab.SKINS))
	locations_tab.pressed.connect(func() -> void: _show_tab(Tab.LOCATIONS))
	bosses_tab.pressed.connect(func() -> void: _show_tab(Tab.BOSSES))
	achievements_tab.pressed.connect(func() -> void: _show_tab(Tab.ACHIEVEMENTS))


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func open() -> void:
	_show_tab(Tab.CHARACTERS)
	visible = true


func close() -> void:
	visible = false


func _show_tab(tab: Tab) -> void:
	for child in content_container.get_children():
		child.queue_free()
	match tab:
		Tab.CHARACTERS:
			_render_characters()
		Tab.SKINS:
			_render_skins()
		Tab.LOCATIONS:
			_render_locations()
		Tab.BOSSES:
			_render_bosses()
		Tab.ACHIEVEMENTS:
			_render_achievements()


func _render_characters() -> void:
	for character in Characters.pool:
		var unlocked := Characters.is_unlocked(character)
		var subtitle := character.description if unlocked else "Bloqueado."
		content_container.add_child(_row(character.display_name, character.origin if unlocked else "???", subtitle, unlocked))
	for i in 2:
		content_container.add_child(_row("???", "", "Personagem futuro.", false))


func _render_skins() -> void:
	for character in Characters.pool:
		for skin in Skins.pool:
			if skin.character_id != character.id:
				continue
			var unlocked := Skins.is_unlocked(skin)
			content_container.add_child(_row(skin.display_name, character.display_name, "Desbloqueada." if unlocked else "Bloqueada.", unlocked))


func _render_locations() -> void:
	for location in Locations.pool:
		var discovered := MetaProgress.is_location_discovered(location.id)
		var title := location.display_name if discovered else "???"
		var subtitle := location.origin if discovered else ""
		var desc := location.description if discovered else "Ainda não visitada."
		content_container.add_child(_row(title, subtitle, desc, discovered))


func _render_bosses() -> void:
	var any_boss := false
	for location in Locations.pool:
		for boss_data in location.boss_pool:
			any_boss = true
			var encounter := MetaProgress.get_boss_encounter(boss_data.id)
			var fought: int = encounter.get("times_fought", 0)
			var defeated: int = encounter.get("times_defeated", 0)
			var discovered := fought > 0 or defeated > 0
			if boss_data.secret and not discovered:
				content_container.add_child(_row("???", "", "Chefe secreto.", false))
				continue
			var title := boss_data.display_name if discovered else "???"
			var desc := "Enfrentado %d vez(es) · Derrotado %d vez(es)" % [fought, defeated] if discovered else "Ainda não encontrado."
			content_container.add_child(_row(title, boss_data.origin if discovered else "", desc, discovered))
	if not any_boss:
		content_container.add_child(_row("Nenhum chefe nesta localidade", "", "", false))


func _render_achievements() -> void:
	var unlocked_count := 0
	for achievement in Achievements.pool:
		if Achievements.is_unlocked(achievement.id):
			unlocked_count += 1

	var header := Label.new()
	header.text = "%d / %d desbloqueadas" % [unlocked_count, Achievements.pool.size()]
	header.add_theme_font_size_override("font_size", 16)
	header.modulate = Color(0.7, 0.95, 1, 1)
	content_container.add_child(header)

	for achievement in Achievements.pool:
		var unlocked := Achievements.is_unlocked(achievement.id)
		var title := achievement.display_name if (unlocked or not achievement.secret) else "???"
		content_container.add_child(_row(title, "", achievement.description if unlocked else "", unlocked))


func _row(title_text: String, subtitle_text: String, description_text: String, unlocked: bool) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.17, 0.22, 1) if unlocked else Color(0.12, 0.12, 0.14, 1)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 14
	style.content_margin_top = 8
	style.content_margin_right = 14
	style.content_margin_bottom = 8

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 17)
	title.modulate = Color(1, 1, 1, 1) if unlocked else Color(1, 1, 1, 0.5)
	vbox.add_child(title)

	if subtitle_text != "":
		var subtitle := Label.new()
		subtitle.text = subtitle_text
		subtitle.add_theme_font_size_override("font_size", 12)
		subtitle.modulate = Color(1, 1, 1, 0.5)
		vbox.add_child(subtitle)

	if description_text != "":
		var desc := Label.new()
		desc.text = description_text
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc.add_theme_font_size_override("font_size", 12)
		desc.modulate = Color(1, 1, 1, 0.65)
		vbox.add_child(desc)

	return panel

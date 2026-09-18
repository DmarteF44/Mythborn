class_name GameOverScreen
extends CanvasLayer

## Separa claramente RESULTADO DA RUN (o que aconteceu) de RECOMPENSA
## PERMANENTE (o que ficou de verdade na conta) e NOVOS DESBLOQUEIOS —
## lidos de RunStats/MetaProgress, nunca recalculados aqui.

@onready var content_container: VBoxContainer = $CenterContainer/Panel/VBox/Scroll/ContentContainer
@onready var retry_button: Button = $CenterContainer/Panel/VBox/RetryButton
@onready var menu_button: Button = $CenterContainer/Panel/VBox/MenuButton

var _reward_applied: bool = false


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func show_results(player: Player) -> void:
	var end_of_run_reward := _grant_end_of_run_reward()

	for child in content_container.get_children():
		child.queue_free()

	content_container.add_child(_section_header("RESULTADO DA RUN"))
	content_container.add_child(_row("Personagem", "%s (%s)" % [player.progression.character_data.display_name, player.progression.get_display_name()]))
	content_container.add_child(_row("Localidade", Locations.current.display_name))
	content_container.add_child(_row("Modo", RunConfig.current_mode.display_name))
	content_container.add_child(_row("Desafio", RunConfig.current_challenge.display_name if RunConfig.current_challenge != null else "Normal"))
	content_container.add_child(_row("Tempo sobrevivido", RunStats.format_time(RunStats.survival_time)))
	content_container.add_child(_row("Nível alcançado", str(RunStats.level_reached)))
	content_container.add_child(_row("Inimigos derrotados", str(RunStats.enemies_defeated)))
	content_container.add_child(_row("Chefes derrotados", str(RunStats.bosses_defeated)))
	content_container.add_child(_row("Essência total ganha", str(RunStats.total_essence_earned)))

	var weapon_summary: Array[String] = []
	for group in player.weapon_inventory.get_grouped_weapons():
		var weapon_data: WeaponData = group["weapon_data"]
		weapon_summary.append("%s Lv.%d×%d" % [weapon_data.display_name, group["level"], group["count"]])
	content_container.add_child(_row("Armas", ", ".join(weapon_summary) if not weapon_summary.is_empty() else "—"))

	var passive_count := 0
	for upgrade_data in Upgrades.pool:
		if player.passives.get_level(upgrade_data.id) > 0:
			passive_count += 1
	content_container.add_child(_row("Passivas/Poderes", str(passive_count)))

	content_container.add_child(_section_header("RECOMPENSA PERMANENTE"))
	content_container.add_child(_row("Fragmentos Míticos", "+%d" % end_of_run_reward))

	if not RunStats.achievements_unlocked_this_run.is_empty() or not RunStats.skins_unlocked_this_run.is_empty():
		content_container.add_child(_section_header("NOVOS DESBLOQUEIOS"))
		for id in RunStats.achievements_unlocked_this_run:
			var achievement := Achievements.get_by_id(id)
			content_container.add_child(_row("Conquista", achievement.display_name if achievement != null else id))
		for id in RunStats.skins_unlocked_this_run:
			var skin_name := id
			for skin in Skins.pool:
				if skin.id == id:
					skin_name = skin.display_name
			content_container.add_child(_row("Skin", skin_name))

	visible = true


## Recompensa simples por ter jogado a run (separada da recompensa de boss/
## conquista, que já é creditada por RewardResolver assim que acontece).
## Guardado por `_reward_applied` para nunca ser aplicada duas vezes.
func _grant_end_of_run_reward() -> int:
	var amount := int(RunStats.survival_time / 10.0) + RunStats.level_reached * 2
	if _reward_applied:
		return MetaProgress.currency - RunStats.currency_at_run_start
	_reward_applied = true
	MetaProgress.add_currency(amount)
	return MetaProgress.currency - RunStats.currency_at_run_start


func _section_header(text: String) -> Control:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.modulate = Color(1, 0.85, 0.5, 1)
	return label


func _row(label_text: String, value_text: String) -> Control:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color(1, 1, 1, 0.7)
	hbox.add_child(label)
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.autowrap_mode = TextServer.AUTOWRAP_WORD
	value.custom_minimum_size = Vector2(260, 0)
	value.add_theme_font_size_override("font_size", 14)
	hbox.add_child(value)
	return hbox


func _on_retry_pressed() -> void:
	GameManager.start_new_run()


func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()

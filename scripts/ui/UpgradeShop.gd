class_name UpgradeShop
extends CanvasLayer

## Tela unificada de upgrades: cabeçalho (nível/essência/estágio), faixa de
## ofertas (em grade, com ícone e lock), build atual em duas colunas
## (passivas/poderes à esquerda, armas à direita, com fusão) e um resumo de
## atributos. A UI só exibe o que UpgradeOfferGenerator/WeaponInventory/
## PlayerStats calculam — nenhuma regra de elegibilidade ou número de stat
## mora aqui.

signal closed

const OFFER_COUNT := 4

const ICON_WEAPON := preload("res://assets/ui/icon_weapon.png")
const ICON_PASSIVE := preload("res://assets/ui/icon_passive.png")
const ICON_POWER := preload("res://assets/ui/icon_power.png")
const ICON_LOCK := preload("res://assets/ui/icon_lock.png")
const ICON_UNLOCK := preload("res://assets/ui/icon_unlock.png")

@onready var level_label: Label = $CenterContainer/Panel/VBox/HeaderRow/LevelLabel
@onready var essence_label: Label = $CenterContainer/Panel/VBox/HeaderRow/EssenceLabel
@onready var context_label: Label = $CenterContainer/Panel/VBox/ContextLabel
@onready var free_hint_label: Label = $CenterContainer/Panel/VBox/FreeHintLabel

@onready var offers_grid: GridContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/OffersGrid
@onready var passives_column: VBoxContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/BuildColumns/PassivesColumn
@onready var weapons_column: VBoxContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/BuildColumns/WeaponsColumn
@onready var stats_container: VBoxContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/StatsContainer

@onready var reroll_button: Button = $CenterContainer/Panel/VBox/ButtonsRow/RerollButton
@onready var continue_button: Button = $CenterContainer/Panel/VBox/ButtonsRow/ContinueButton

@onready var fusion_confirm: Control = $FusionConfirm
@onready var fusion_message: Label = $FusionConfirm/Panel/VBox/Label
@onready var fusion_cancel_button: Button = $FusionConfirm/Panel/VBox/HBox/CancelButton
@onready var fusion_confirm_button: Button = $FusionConfirm/Panel/VBox/HBox/ConfirmButton

var _current_offers: Array[ShopOffer] = []
var _reroll_count: int = 0
var _player: Player = null
var _pending_fusion_weapon_id: String = ""
var _pending_fusion_level: int = 0


func _ready() -> void:
	visible = false
	fusion_confirm.visible = false
	reroll_button.pressed.connect(_on_reroll_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	fusion_cancel_button.pressed.connect(_on_fusion_cancel_pressed)
	fusion_confirm_button.pressed.connect(_on_fusion_confirm_pressed)
	Economy.essence_changed.connect(func(_v: int) -> void: _refresh_header())


func open(player: Player) -> void:
	_player = player
	_reroll_count = 0
	_current_offers = UpgradeOfferGenerator.generate_offers(OFFER_COUNT, _player)
	_render_offers()
	_render_build_summary()
	_render_stats()
	_refresh_header()
	visible = true


func _refresh_header() -> void:
	if _player == null:
		return
	level_label.text = "NÍVEL %d" % _player.experience.level
	essence_label.text = "Essência: %d" % Economy.essence
	context_label.text = "%s · %s" % [_player.progression.get_display_name(), RunStats.format_time(RunStats.survival_time)]
	free_hint_label.visible = Economy.has_free_token()
	var cost := Economy.get_reroll_cost(_reroll_count)
	reroll_button.text = "REROLL (%d)" % cost
	reroll_button.disabled = not Economy.can_afford(cost)


func _render_stats() -> void:
	for child in stats_container.get_children():
		child.queue_free()

	var stats := _player.stats
	var rows := [
		["Vida Máxima", "%d" % _player.health.max_health],
		["Velocidade", "%d%%" % int(round(stats.get_move_speed() / stats.base_move_speed * 100))],
		["Dano", "%d%%" % int(round(stats.get_damage_mult() * 100))],
		["Vel. de Ataque", "%d%%" % int(round(stats.get_attack_speed_mult() * 100))],
		["Raio de Coleta", "%dpx" % int(round(stats.get_pickup_radius()))],
		["XP Ganho", "%d%%" % int(round(_player.experience.xp_gain_mult * 100))],
	]
	for row in rows:
		stats_container.add_child(_build_stat_row(row[0], row[1]))


func _build_stat_row(label_text: String, value_text: String) -> Control:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(label)
	var value := Label.new()
	value.text = value_text
	value.add_theme_font_size_override("font_size", 14)
	value.modulate = Color(0.7, 0.95, 1, 1)
	hbox.add_child(value)
	return hbox


func _render_build_summary() -> void:
	for child in weapons_column.get_children():
		child.queue_free()
	var weapons_header := Label.new()
	weapons_header.text = "ARMAS %d/%d" % [_player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS]
	weapons_header.add_theme_font_size_override("font_size", 16)
	weapons_column.add_child(weapons_header)
	for group in _player.weapon_inventory.get_grouped_weapons():
		weapons_column.add_child(_build_weapon_row(group))

	for child in passives_column.get_children():
		child.queue_free()
	var passive_count := 0
	var power_count := 0
	var passive_rows: Array[Control] = []
	var power_rows: Array[Control] = []
	for upgrade_data in Upgrades.pool:
		var level: int = _player.passives.get_level(upgrade_data.id)
		if level <= 0:
			continue
		if upgrade_data.shop_category == ShopCategory.Type.POWER:
			power_count += 1
			power_rows.append(_build_passive_row(upgrade_data, level))
		else:
			passive_count += 1
			passive_rows.append(_build_passive_row(upgrade_data, level))

	var passives_header := Label.new()
	passives_header.text = "PASSIVAS %d" % passive_count
	passives_header.add_theme_font_size_override("font_size", 16)
	passives_column.add_child(passives_header)
	for row in passive_rows:
		passives_column.add_child(row)

	var powers_header := Label.new()
	powers_header.text = "PODERES %d" % power_count
	powers_header.add_theme_font_size_override("font_size", 16)
	passives_column.add_child(powers_header)
	for row in power_rows:
		passives_column.add_child(row)


func _build_weapon_row(group: Dictionary) -> Control:
	var weapon_data: WeaponData = group["weapon_data"]
	var level: int = group["level"]
	var count: int = group["count"]

	var vbox := VBoxContainer.new()
	var label := Label.new()
	label.text = "%s Lv.%d × %d" % [weapon_data.display_name, level, count]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(label)

	if level >= weapon_data.max_level:
		var max_label := Label.new()
		max_label.text = "MAX"
		max_label.modulate = Color(1, 0.85, 0.3, 1)
		max_label.add_theme_font_size_override("font_size", 13)
		vbox.add_child(max_label)
	elif count >= 2:
		var fuse_button := Button.new()
		fuse_button.text = "FUNDIR 2 → Lv.%d" % (level + 1)
		fuse_button.custom_minimum_size = Vector2(0, 48)
		fuse_button.pressed.connect(_on_fuse_requested.bind(weapon_data.id, level, weapon_data.display_name))
		vbox.add_child(fuse_button)

	return vbox


func _build_passive_row(upgrade_data: UpgradeData, level: int) -> Control:
	var label := Label.new()
	var value_text := UpgradeOfferGenerator.format_value(upgrade_data, level)
	var max_tag := "  (MAX)" if level >= upgrade_data.max_level else ""
	label.text = "%s Lv.%d (%s)%s" % [upgrade_data.title, level, value_text, max_tag]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", 14)
	return label


func _render_offers() -> void:
	for child in offers_grid.get_children():
		child.queue_free()

	if _current_offers.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Sem mais ofertas nesta rodada. Use REROLL ou CONTINUAR."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		offers_grid.add_child(empty_label)
		return

	for offer in _current_offers:
		offers_grid.add_child(_build_offer_card(offer))


func _build_offer_card(offer: ShopOffer) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.17, 0.22, 1)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 0)
	panel.add_theme_stylebox_override("panel", style)

	var outer_vbox := VBoxContainer.new()
	panel.add_child(outer_vbox)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	outer_vbox.add_child(top_row)

	var icon := TextureRect.new()
	icon.texture = _category_icon(offer.category)
	icon.custom_minimum_size = Vector2(28, 28)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top_row.add_child(icon)

	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(text_vbox)

	var category_label := Label.new()
	category_label.text = "%s · %s" % [_category_name(offer.category), offer.action_label]
	category_label.add_theme_font_size_override("font_size", 12)
	category_label.modulate = Color(1, 1, 1, 0.55)
	text_vbox.add_child(category_label)

	var title_label := Label.new()
	title_label.text = offer.title
	title_label.add_theme_font_size_override("font_size", 19)
	text_vbox.add_child(title_label)

	var lock_button := TextureButton.new()
	lock_button.texture_normal = ICON_LOCK if offer.locked else ICON_UNLOCK
	lock_button.custom_minimum_size = Vector2(28, 28)
	lock_button.pressed.connect(_on_lock_toggled.bind(offer))
	top_row.add_child(lock_button)

	var desc_label := Label.new()
	desc_label.text = offer.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.modulate = Color(1, 1, 1, 0.7)
	outer_vbox.add_child(desc_label)

	if offer.disabled_reason != "":
		var reason_label := Label.new()
		reason_label.text = offer.disabled_reason
		reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		reason_label.add_theme_font_size_override("font_size", 12)
		reason_label.modulate = Color(1, 0.5, 0.5, 1)
		outer_vbox.add_child(reason_label)

	var buy_button := Button.new()
	buy_button.custom_minimum_size = Vector2(0, 56)
	buy_button.disabled = offer.disabled_reason != ""
	if offer.disabled_reason != "":
		buy_button.text = "—"
	elif Economy.has_free_token():
		buy_button.text = "GRÁTIS"
	else:
		buy_button.text = str(offer.get_price())
	buy_button.pressed.connect(_on_buy_pressed.bind(offer))
	outer_vbox.add_child(buy_button)

	return panel


func _category_name(category: ShopCategory.Type) -> String:
	match category:
		ShopCategory.Type.WEAPON:
			return "ARMA"
		ShopCategory.Type.PASSIVE:
			return "PASSIVA"
		ShopCategory.Type.POWER:
			return "PODER"
	return ""


func _category_icon(category: ShopCategory.Type) -> Texture2D:
	match category:
		ShopCategory.Type.WEAPON:
			return ICON_WEAPON
		ShopCategory.Type.POWER:
			return ICON_POWER
	return ICON_PASSIVE


func _on_lock_toggled(offer: ShopOffer) -> void:
	offer.locked = not offer.locked
	_render_offers()


func _on_buy_pressed(offer: ShopOffer) -> void:
	if offer.disabled_reason != "":
		return

	if Economy.has_free_token():
		Economy.use_free_token()
	else:
		var price := offer.get_price()
		if not Economy.spend(price):
			return
		Economy.register_purchase()

	_apply_offer(offer)
	RunStats.register_upgrade()
	_current_offers.erase(offer)
	_render_offers()
	_render_build_summary()
	_render_stats()
	_refresh_header()


func _apply_offer(offer: ShopOffer) -> void:
	if offer.weapon_scene != null:
		_player.weapon_inventory.add_weapon(offer.weapon_scene)
	elif offer.upgrade_data != null:
		_player.passives.apply(offer.upgrade_data)


func _on_reroll_pressed() -> void:
	var cost := Economy.get_reroll_cost(_reroll_count)
	if not Economy.spend(cost):
		return
	_reroll_count += 1

	var locked_offers: Array[ShopOffer] = []
	var locked_ids: Array[String] = []
	for offer in _current_offers:
		if offer.locked:
			locked_offers.append(offer)
			locked_ids.append(offer.id)

	var fresh := UpgradeOfferGenerator.generate_offers(OFFER_COUNT - locked_offers.size(), _player, locked_ids)
	_current_offers = locked_offers + fresh
	_render_offers()
	_refresh_header()


func _on_continue_pressed() -> void:
	visible = false
	closed.emit()


func _on_fuse_requested(weapon_id: String, level: int, display_name: String) -> void:
	_pending_fusion_weapon_id = weapon_id
	_pending_fusion_level = level
	fusion_message.text = "Fundir 2x %s Lv.%d em 1x Lv.%d?" % [display_name, level, level + 1]
	fusion_confirm.visible = true


func _on_fusion_cancel_pressed() -> void:
	fusion_confirm.visible = false


func _on_fusion_confirm_pressed() -> void:
	fusion_confirm.visible = false
	_player.weapon_inventory.fuse(_pending_fusion_weapon_id, _pending_fusion_level)
	_render_build_summary()
	_refresh_offer_disabled_states()


func _refresh_offer_disabled_states() -> void:
	for offer in _current_offers:
		if offer.weapon_data == null:
			continue
		if _player.weapon_inventory.is_full():
			offer.disabled_reason = "Inventário de armas cheio (%d/%d)" % [_player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS]
		else:
			offer.disabled_reason = ""
	_render_offers()

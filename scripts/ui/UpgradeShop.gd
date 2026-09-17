class_name UpgradeShop
extends CanvasLayer

## Tela unificada de upgrades: mostra a build atual (armas agrupadas por
## nível, com fusão opcional) e as ofertas (armas, passivas, poderes) numa
## única experiência rolável. A UI apenas exibe o que
## UpgradeOfferGenerator/WeaponInventory calculam — nenhuma regra de
## elegibilidade mora aqui.

signal closed

const OFFER_COUNT := 4

@onready var level_label: Label = $CenterContainer/Panel/VBox/HeaderRow/LevelLabel
@onready var essence_label: Label = $CenterContainer/Panel/VBox/HeaderRow/EssenceLabel
@onready var free_hint_label: Label = $CenterContainer/Panel/VBox/FreeHintLabel
@onready var weapons_build_container: VBoxContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/WeaponsBuildContainer
@onready var passives_build_container: VBoxContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/PassivesBuildContainer
@onready var offers_container: VBoxContainer = $CenterContainer/Panel/VBox/MainScroll/ContentVBox/OffersContainer
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
	_refresh_header()
	visible = true


func _refresh_header() -> void:
	level_label.text = "NÍVEL %d" % _player.experience.level if _player != null else "NÍVEL 1"
	essence_label.text = "Essência: %d" % Economy.essence
	free_hint_label.visible = Economy.has_free_token()
	var cost := Economy.get_reroll_cost(_reroll_count)
	reroll_button.text = "REROLL (%d)" % cost
	reroll_button.disabled = not Economy.can_afford(cost)


## ---------------------------------------------------------------- BUILD --

func _render_build_summary() -> void:
	for child in weapons_build_container.get_children():
		child.queue_free()
	var header := Label.new()
	header.text = "ARMAS %d/%d" % [_player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS]
	header.add_theme_font_size_override("font_size", 16)
	weapons_build_container.add_child(header)
	for group in _player.weapon_inventory.get_grouped_weapons():
		weapons_build_container.add_child(_build_weapon_row(group))

	for child in passives_build_container.get_children():
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
	passives_build_container.add_child(passives_header)
	for row in passive_rows:
		passives_build_container.add_child(row)

	var powers_header := Label.new()
	powers_header.text = "PODERES %d" % power_count
	powers_header.add_theme_font_size_override("font_size", 16)
	passives_build_container.add_child(powers_header)
	for row in power_rows:
		passives_build_container.add_child(row)


func _build_weapon_row(group: Dictionary) -> Control:
	var weapon_data: WeaponData = group["weapon_data"]
	var level: int = group["level"]
	var count: int = group["count"]

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var label := Label.new()
	label.text = "%s Lv.%d × %d" % [weapon_data.display_name, level, count]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 15)
	hbox.add_child(label)

	if level >= weapon_data.max_level:
		var max_label := Label.new()
		max_label.text = "MAX"
		max_label.modulate = Color(1, 0.85, 0.3, 1)
		hbox.add_child(max_label)
	elif count >= 2:
		var fuse_button := Button.new()
		fuse_button.text = "FUNDIR 2→Lv.%d" % (level + 1)
		fuse_button.custom_minimum_size = Vector2(160, 52)
		fuse_button.pressed.connect(_on_fuse_requested.bind(weapon_data.id, level, weapon_data.display_name))
		hbox.add_child(fuse_button)

	return hbox


func _build_passive_row(upgrade_data: UpgradeData, level: int) -> Control:
	var label := Label.new()
	var value_text := UpgradeOfferGenerator.format_value(upgrade_data, level)
	var max_tag := "  (MAX)" if level >= upgrade_data.max_level else ""
	label.text = "%s Lv.%d (%s)%s" % [upgrade_data.title, level, value_text, max_tag]
	label.add_theme_font_size_override("font_size", 15)
	return label


## --------------------------------------------------------------- OFFERS --

func _render_offers() -> void:
	for child in offers_container.get_children():
		child.queue_free()

	if _current_offers.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Sem mais ofertas nesta rodada. Use REROLL ou CONTINUAR."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		offers_container.add_child(empty_label)
		return

	for offer in _current_offers:
		offers_container.add_child(_build_offer_card(offer))


func _build_offer_card(offer: ShopOffer) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.17, 0.22, 1)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var category_label := Label.new()
	category_label.text = "%s · %s" % [_category_name(offer.category), offer.action_label]
	category_label.add_theme_font_size_override("font_size", 13)
	category_label.modulate = Color(1, 1, 1, 0.55)
	text_vbox.add_child(category_label)

	var title_label := Label.new()
	title_label.text = offer.title
	title_label.add_theme_font_size_override("font_size", 22)
	text_vbox.add_child(title_label)

	var desc_label := Label.new()
	desc_label.text = offer.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.modulate = Color(1, 1, 1, 0.7)
	text_vbox.add_child(desc_label)

	if offer.disabled_reason != "":
		var reason_label := Label.new()
		reason_label.text = offer.disabled_reason
		reason_label.add_theme_font_size_override("font_size", 13)
		reason_label.modulate = Color(1, 0.5, 0.5, 1)
		text_vbox.add_child(reason_label)

	var buy_button := Button.new()
	buy_button.custom_minimum_size = Vector2(110, 68)
	buy_button.disabled = offer.disabled_reason != ""
	if offer.disabled_reason != "":
		buy_button.text = "—"
	elif Economy.has_free_token():
		buy_button.text = "GRÁTIS"
	else:
		buy_button.text = str(offer.price)
	buy_button.pressed.connect(_on_buy_pressed.bind(offer))
	hbox.add_child(buy_button)

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


func _on_buy_pressed(offer: ShopOffer) -> void:
	if offer.disabled_reason != "":
		return

	if Economy.has_free_token():
		Economy.use_free_token()
	elif not Economy.spend(offer.price):
		return

	_apply_offer(offer)
	RunStats.register_upgrade()
	_current_offers.erase(offer)
	_render_offers()
	_render_build_summary()
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
	_current_offers = UpgradeOfferGenerator.generate_offers(OFFER_COUNT, _player)
	_render_offers()
	_refresh_header()


func _on_continue_pressed() -> void:
	visible = false
	closed.emit()


## --------------------------------------------------------------- FUSION --

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


## Após comprar/fundir, o inventário pode ter deixado de estar cheio — as
## ofertas de arma já geradas atualizam seu estado sem sortear um novo lote.
func _refresh_offer_disabled_states() -> void:
	for offer in _current_offers:
		if offer.weapon_data == null:
			continue
		if _player.weapon_inventory.is_full():
			offer.disabled_reason = "Inventário de armas cheio (%d/%d)" % [_player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS]
		else:
			offer.disabled_reason = ""
	_render_offers()

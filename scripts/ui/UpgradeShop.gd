class_name UpgradeShop
extends CanvasLayer

## Tela unificada de upgrades: armas, passivas e poderes numa única
## experiência, com reroll pago e uma primeira compra sempre gratuita
## (token concedido a cada level-up). A UI apenas exibe o que
## UpgradeOfferGenerator sorteia — nenhuma regra de elegibilidade mora aqui.

signal closed

const OFFER_COUNT := 4

@onready var essence_label: Label = $CenterContainer/Panel/VBox/HeaderRow/EssenceLabel
@onready var free_hint_label: Label = $CenterContainer/Panel/VBox/FreeHintLabel
@onready var offers_container: VBoxContainer = $CenterContainer/Panel/VBox/Scroll/OffersContainer
@onready var reroll_button: Button = $CenterContainer/Panel/VBox/ButtonsRow/RerollButton
@onready var continue_button: Button = $CenterContainer/Panel/VBox/ButtonsRow/ContinueButton

var _current_offers: Array[ShopOffer] = []
var _reroll_count: int = 0
var _player: Player = null


func _ready() -> void:
	visible = false
	reroll_button.pressed.connect(_on_reroll_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	Economy.essence_changed.connect(func(_v: int) -> void: _refresh_header())


func open(player: Player) -> void:
	_player = player
	_reroll_count = 0
	_current_offers = UpgradeOfferGenerator.generate_offers(OFFER_COUNT, _player)
	_render_offers()
	_refresh_header()
	visible = true


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
		offers_container.add_child(_build_card(offer))


func _build_card(offer: ShopOffer) -> Control:
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
	category_label.text = _category_name(offer.category)
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
	_refresh_header()


func _apply_offer(offer: ShopOffer) -> void:
	if offer.weapon_scene != null:
		_player.weapon_inventory.add_weapon(offer.weapon_scene)
	elif offer.upgrade_data != null:
		_apply_upgrade(offer.upgrade_data)


func _apply_upgrade(upgrade: UpgradeData) -> void:
	match upgrade.type:
		UpgradeData.Type.VITALITY:
			_player.health.apply_max_health_multiplier(1.0 + upgrade.value)
		UpgradeData.Type.XP_GAIN:
			_player.experience.xp_gain_mult += upgrade.value
		_:
			_player.stats.apply_upgrade(upgrade)


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


func _refresh_header() -> void:
	essence_label.text = "Essência: %d" % Economy.essence
	free_hint_label.visible = Economy.has_free_token()
	var cost := Economy.get_reroll_cost(_reroll_count)
	reroll_button.text = "REROLL (%d)" % cost
	reroll_button.disabled = not Economy.can_afford(cost)

class_name UpgradeOfferGenerator
extends RefCounted

## Ponto único de geração de ofertas para a UpgradeShop — a UI apenas exibe
## o que aqui é sorteado; nenhuma regra de elegibilidade fica na tela.
##
## Armas: SEMPRE elegíveis (duplicatas são o comportamento desejado — ver
## docs/GAMEPLAY.md), mesmo já possuídas; só ficam desabilitadas (com o
## motivo explicado) se o inventário estiver cheio.
## Passivas/poderes: uma vez no nível máximo, nunca mais são oferecidos.


static func generate_offers(count: int, player: Player) -> Array[ShopOffer]:
	var candidates: Array[ShopOffer] = []

	for entry in Weapons.pool:
		candidates.append(_build_weapon_offer(entry, player))

	for upgrade_data in Upgrades.pool:
		if not player.passives.can_upgrade(upgrade_data):
			continue
		candidates.append(_build_passive_offer(upgrade_data, player))

	candidates.shuffle()

	var result: Array[ShopOffer] = []
	for i in range(min(count, candidates.size())):
		result.append(candidates[i])
	return result


static func _build_weapon_offer(entry: Dictionary, player: Player) -> ShopOffer:
	var weapon_data: WeaponData = entry["data"]
	var offer := ShopOffer.new()
	offer.category = weapon_data.shop_category
	offer.weapon_data = weapon_data
	offer.weapon_scene = entry["scene"]
	offer.price = weapon_data.price
	offer.title = weapon_data.display_name
	offer.description = "Dano %d · Alcance %d · Cooldown %.1fs (Lv.1)" % [weapon_data.damage, weapon_data.range, weapon_data.cooldown]

	if player.weapon_inventory.has_weapon(weapon_data.id):
		offer.action_label = "NOVA CÓPIA"
	else:
		offer.action_label = "COMPRAR"

	if player.weapon_inventory.is_full():
		offer.disabled_reason = "Inventário de armas cheio (%d/%d)" % [player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS]

	return offer


static func _build_passive_offer(upgrade_data: UpgradeData, player: Player) -> ShopOffer:
	var offer := ShopOffer.new()
	offer.category = upgrade_data.shop_category
	offer.upgrade_data = upgrade_data
	offer.price = upgrade_data.price
	offer.title = upgrade_data.title

	var current_level := player.passives.get_level(upgrade_data.id)
	var next_level := current_level + 1
	var current_text := format_value(upgrade_data, current_level)
	var next_text := format_value(upgrade_data, next_level)

	if current_level > 0:
		offer.action_label = "MELHORAR"
		offer.description = "Nível %d → %d  (%s → %s)" % [current_level, next_level, current_text, next_text]
	else:
		offer.action_label = "ADQUIRIR"
		offer.description = "%s Nível 1: %s" % [upgrade_data.description, next_text]

	return offer


static func format_value(upgrade_data: UpgradeData, level: int) -> String:
	var total := level * upgrade_data.value
	if upgrade_data.type == UpgradeData.Type.PICKUP_RADIUS:
		return "+%dpx" % int(round(total))
	return "+%d%%" % int(round(total * 100))

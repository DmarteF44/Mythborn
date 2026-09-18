class_name UpgradeOfferGenerator
extends RefCounted

## Ponto único de geração de ofertas para a UpgradeShop — a UI apenas exibe
## o que aqui é sorteado; nenhuma regra de elegibilidade fica na tela.
##
## Armas: SEMPRE elegíveis (duplicatas são o comportamento desejado — ver
## docs/GAMEPLAY.md), mesmo já possuídas; só ficam desabilitadas (com o
## motivo explicado) se o inventário estiver cheio.
## Passivas/poderes: uma vez no nível máximo, nunca mais são oferecidos.
##
## A distribuição entre categorias é ponderada (CATEGORY_WEIGHTS) para
## evitar que a loja sorteie 4 armas ou 4 passivas seguidas com frequência.

const CATEGORY_WEIGHTS := {
	ShopCategory.Type.WEAPON: 1.0,
	ShopCategory.Type.PASSIVE: 1.3,
	ShopCategory.Type.POWER: 0.8,
}


## `exclude_ids` evita re-sortear ofertas já travadas (lock) durante um reroll.
static func generate_offers(count: int, player: Player, exclude_ids: Array[String] = []) -> Array[ShopOffer]:
	var candidates: Array[ShopOffer] = []

	for entry in Weapons.pool:
		var weapon_data: WeaponData = entry["data"]
		if exclude_ids.has(weapon_data.id):
			continue
		candidates.append(_build_weapon_offer(entry, player))

	for upgrade_data in Upgrades.pool:
		if exclude_ids.has(upgrade_data.id):
			continue
		if not player.passives.can_upgrade(upgrade_data):
			continue
		candidates.append(_build_passive_offer(upgrade_data, player))

	return _weighted_pick(candidates, count)


static func _weighted_pick(candidates: Array[ShopOffer], count: int) -> Array[ShopOffer]:
	var pool := candidates.duplicate()
	pool.shuffle()
	var result: Array[ShopOffer] = []

	while result.size() < count and not pool.is_empty():
		var total_weight := 0.0
		for offer in pool:
			total_weight += CATEGORY_WEIGHTS.get(offer.category, 1.0)

		var roll := randf() * total_weight
		var chosen_index := 0
		for i in pool.size():
			roll -= CATEGORY_WEIGHTS.get(pool[i].category, 1.0)
			if roll <= 0.0:
				chosen_index = i
				break

		result.append(pool[chosen_index])
		pool.remove_at(chosen_index)

	return result


static func _build_weapon_offer(entry: Dictionary, player: Player) -> ShopOffer:
	var weapon_data: WeaponData = entry["data"]
	var offer := ShopOffer.new()
	offer.id = weapon_data.id
	offer.category = weapon_data.shop_category
	offer.weapon_data = weapon_data
	offer.weapon_scene = entry["scene"]
	offer.base_price = weapon_data.price
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
	offer.id = upgrade_data.id
	offer.category = upgrade_data.shop_category
	offer.upgrade_data = upgrade_data
	offer.base_price = upgrade_data.price
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

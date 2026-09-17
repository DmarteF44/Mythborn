class_name UpgradeOfferGenerator
extends RefCounted

## Ponto único de geração de ofertas para a UpgradeShop — a UI apenas exibe
## o que aqui é sorteado; nenhuma regra de elegibilidade fica na tela.


static func generate_offers(count: int, player: Player) -> Array[ShopOffer]:
	var candidates: Array[ShopOffer] = []

	for entry in Weapons.pool:
		var weapon_data: WeaponData = entry["data"]
		if player.weapon_inventory.has_weapon(weapon_data.id):
			continue
		var offer := ShopOffer.new()
		offer.category = weapon_data.shop_category
		offer.weapon_data = weapon_data
		offer.weapon_scene = entry["scene"]
		offer.price = weapon_data.price
		offer.title = weapon_data.display_name
		offer.description = "Dano %d · Alcance %d · Cooldown %.1fs" % [weapon_data.damage, weapon_data.range, weapon_data.cooldown]
		if player.weapon_inventory.is_full():
			offer.disabled_reason = "Inventário de armas cheio (%d/%d)" % [player.weapon_inventory.weapons.size(), GameManager.MAX_WEAPONS]
		candidates.append(offer)

	for upgrade_data in Upgrades.pool:
		var offer := ShopOffer.new()
		offer.category = upgrade_data.shop_category
		offer.upgrade_data = upgrade_data
		offer.price = upgrade_data.price
		offer.title = upgrade_data.title
		offer.description = upgrade_data.description
		candidates.append(offer)

	candidates.shuffle()

	var result: Array[ShopOffer] = []
	for i in range(min(count, candidates.size())):
		result.append(candidates[i])
	return result

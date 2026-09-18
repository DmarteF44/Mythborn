class_name ShopOffer
extends RefCounted

## Uma oferta gerada e pronta para exibição/compra. Efêmera — nunca salva
## em disco, apenas construída pelo UpgradeOfferGenerator a cada abertura
## ou reroll da loja.

var id: String = "" ## id da arma ou da passiva — usado para lock/exclusão no reroll
var category: ShopCategory.Type = ShopCategory.Type.PASSIVE
var weapon_data: WeaponData = null
var weapon_scene: PackedScene = null
var upgrade_data: UpgradeData = null
var base_price: int = 0 ## preço antes da inflação por compras (Economy.get_price_multiplier)
var title: String = ""
var description: String = ""
var disabled_reason: String = ""
var locked: bool = false ## sobrevive ao reroll enquanto marcada

## "COMPRAR" / "NOVA CÓPIA" (arma já possuída) / "ADQUIRIR" / "MELHORAR" (passiva).
var action_label: String = "COMPRAR"


func get_price() -> int:
	return Economy.get_inflated_price(base_price)

class_name ShopOffer
extends RefCounted

## Uma oferta gerada e pronta para exibição/compra. Efêmera — nunca salva
## em disco, apenas construída pelo UpgradeOfferGenerator a cada abertura
## ou reroll da loja.

var category: ShopCategory.Type = ShopCategory.Type.PASSIVE
var weapon_data: WeaponData = null
var weapon_scene: PackedScene = null
var upgrade_data: UpgradeData = null
var price: int = 0
var title: String = ""
var description: String = ""
var disabled_reason: String = ""

## "COMPRAR" / "NOVA CÓPIA" (arma já possuída) / "ADQUIRIR" / "MELHORAR" (passiva).
var action_label: String = "COMPRAR"

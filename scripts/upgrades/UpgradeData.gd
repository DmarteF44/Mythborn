class_name UpgradeData
extends Resource

enum Type { DAMAGE, ATTACK_SPEED, MOVE_SPEED, VITALITY, XP_GAIN }

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var type: Type = Type.DAMAGE
@export var value: float = 0.0

## Usados pela loja unificada de upgrades (UpgradeShop).
@export var price: int = 15
@export var shop_category: ShopCategory.Type = ShopCategory.Type.PASSIVE

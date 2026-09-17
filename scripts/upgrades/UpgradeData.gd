class_name UpgradeData
extends Resource

## `value` é o incremento por nível (ex.: 0.1 = +10% por nível). O nível
## atual do jogador para esta passiva fica em PlayerPassives, não aqui —
## este Resource é só o catálogo/dado, compartilhado por todos os jogadores.

enum Type { DAMAGE, ATTACK_SPEED, MOVE_SPEED, VITALITY, XP_GAIN, PICKUP_RADIUS }

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var type: Type = Type.DAMAGE
@export var value: float = 0.0
@export var max_level: int = 3

## Usados pela loja unificada de upgrades (UpgradeShop).
@export var price: int = 15
@export var shop_category: ShopCategory.Type = ShopCategory.Type.PASSIVE

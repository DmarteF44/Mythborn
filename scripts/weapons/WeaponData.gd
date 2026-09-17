class_name WeaponData
extends Resource

## Dados puros de balanceamento de uma arma. O comportamento fica no script da cena.

@export var id: String = ""
@export var display_name: String = "Weapon"
@export var damage: float = 5.0
@export var cooldown: float = 1.0
@export var range: float = 60.0

## Usados pela loja unificada de upgrades (UpgradeShop). A cena a instanciar
## para esta arma NÃO fica aqui (evitaria uma referência circular entre o
## .tres e a própria cena que o usa) — fica em WeaponPool, que conhece os
## dois lados.
@export var price: int = 15
@export var shop_category: ShopCategory.Type = ShopCategory.Type.WEAPON

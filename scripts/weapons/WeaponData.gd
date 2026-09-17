class_name WeaponData
extends Resource

## Dados puros de balanceamento de uma arma. O comportamento fica no script da cena.
## Os valores aqui são o nível 1 (base); o efeito de cada nível é derivado
## pelas taxas de crescimento abaixo — nenhum número de nível fica hard-coded
## na UI ou em Weapon.gd.

@export var id: String = ""
@export var display_name: String = "Weapon"
@export var damage: float = 5.0
@export var cooldown: float = 1.0
@export var range: float = 60.0

## Progressão por nível. Uma mesma arma pode existir em várias cópias e
## níveis independentes — ver WeaponInventory (duplicatas) e fuse() (fusão).
@export var max_level: int = 5
@export var damage_growth_per_level: float = 0.3
@export var cooldown_reduction_per_level: float = 0.06
@export var range_growth_per_level: float = 0.0

## Usados pela loja unificada de upgrades (UpgradeShop). A cena a instanciar
## para esta arma NÃO fica aqui (evitaria uma referência circular entre o
## .tres e a própria cena que o usa) — fica em WeaponPool, que conhece os
## dois lados.
@export var price: int = 15
@export var shop_category: ShopCategory.Type = ShopCategory.Type.WEAPON


func get_damage_for_level(level: int) -> float:
	return damage * (1.0 + damage_growth_per_level * (level - 1))


func get_cooldown_for_level(level: int) -> float:
	return cooldown * pow(1.0 - clampf(cooldown_reduction_per_level, 0.0, 0.9), level - 1)


func get_range_for_level(level: int) -> float:
	return range * (1.0 + range_growth_per_level * (level - 1))

extends Node

## Autoload — economia temporária da run (Essência). Não persiste entre
## partidas; GameManager.start_new_run() chama reset().

const LEVEL_UP_ESSENCE_BONUS: int = 30
const REROLL_BASE_COST: int = 10
const REROLL_COST_STEP: int = 5

## Cada compra na loja encarece as próximas ~12% — sem isso, o preço de um
## item ficaria sempre igual do início ao fim da run, o que não faz sentido
## com a Essência acumulando cada vez mais rápido.
const PRICE_INFLATION_PER_PURCHASE: float = 0.12

signal essence_changed(current: int)

var essence: int = 0
var free_tokens: int = 0
var purchases_made: int = 0


func reset() -> void:
	essence = 0
	free_tokens = 0
	purchases_made = 0
	essence_changed.emit(essence)


func add(amount: int) -> void:
	essence += amount
	RunStats.register_essence_earned(amount)
	essence_changed.emit(essence)


func can_afford(cost: int) -> bool:
	return essence >= cost


func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	essence -= cost
	essence_changed.emit(essence)
	return true


## Concedido a cada level-up: essência suficiente para pelo menos uma compra
## simples, mais um "token" que torna a primeira compra da loja gratuita —
## assim subir de nível nunca é frustrante mesmo com essência baixa.
func grant_level_up_reward() -> void:
	free_tokens += 1
	add(LEVEL_UP_ESSENCE_BONUS)


func has_free_token() -> bool:
	return free_tokens > 0


func use_free_token() -> void:
	free_tokens = max(0, free_tokens - 1)


func get_reroll_cost(reroll_count: int) -> int:
	return int(round((REROLL_BASE_COST + REROLL_COST_STEP * reroll_count) * get_price_multiplier()))


## Multiplicador aplicado ao preço-base de qualquer oferta (armas/passivas)
## e ao reroll — cresce a cada compra feita na run, nunca reseta até
## GameManager.start_new_run() chamar reset().
func get_price_multiplier() -> float:
	return 1.0 + PRICE_INFLATION_PER_PURCHASE * purchases_made


func get_inflated_price(base_price: int) -> int:
	return int(round(base_price * get_price_multiplier()))


func register_purchase() -> void:
	purchases_made += 1

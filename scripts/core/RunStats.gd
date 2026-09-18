extends Node

## Autoload — estatísticas temporárias da corrida atual (não persiste entre partidas).
## GameManager.start_new_run() chama reset(); trigger_game_over() zera `active`.

var survival_time: float = 0.0
var enemies_defeated: int = 0
var level_reached: int = 1
var upgrades_taken: int = 0
var weapons_owned: int = 0
var bosses_defeated: int = 0
var evolution_stage_reached: int = 0
var total_essence_earned: int = 0
var currency_at_run_start: int = 0
var achievements_unlocked_this_run: Array[String] = []
var skins_unlocked_this_run: Array[String] = []

var active: bool = false


func reset() -> void:
	survival_time = 0.0
	enemies_defeated = 0
	level_reached = 1
	upgrades_taken = 0
	weapons_owned = 0
	bosses_defeated = 0
	evolution_stage_reached = 0
	total_essence_earned = 0
	currency_at_run_start = MetaProgress.currency
	achievements_unlocked_this_run = []
	skins_unlocked_this_run = []


func _process(delta: float) -> void:
	if active:
		survival_time += delta


func register_kill() -> void:
	enemies_defeated += 1


func register_upgrade() -> void:
	upgrades_taken += 1


func register_essence_earned(amount: int) -> void:
	total_essence_earned += amount


func set_weapons_owned(count: int) -> void:
	weapons_owned = count


static func format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]

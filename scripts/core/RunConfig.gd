extends Node

## Autoload — "quais regras valem para esta run": modo + desafio ativos.
## Separado do GameManager (que só cuida de estado/navegação) para não
## transformá-lo num script gigante.

var game_modes: Array[GameModeData] = []
var challenges: Array[ChallengeData] = []

var current_mode: GameModeData
var current_challenge: ChallengeData = null ## null = nenhum desafio ativo


func _ready() -> void:
	game_modes = [
		_make_mode("survival", "Survival", "O ciclo clássico: sobreviva, suba de nível, enfrente o chefe — e continue no Endless depois disso.", true, 900.0, 1.0),
		_make_mode("endless", "Endless", "A escalada de dificuldade do Endless começa imediatamente, sem o ciclo principal.", true, 0.0, 1.2),
	]
	current_mode = game_modes[0]

	challenges = [
		_make_challenge("inferno", "Inferno", "+50% de vida nos inimigos, -20% de XP, recompensa maior.", 1.5, 1.0, 0.8, 1.0, 1.5),
	]


func get_mode_by_id(id: String) -> GameModeData:
	for mode in game_modes:
		if mode.id == id:
			return mode
	return null


func get_challenge_by_id(id: String) -> ChallengeData:
	for challenge in challenges:
		if challenge.id == id:
			return challenge
	return null


func set_mode(id: String) -> bool:
	var mode := get_mode_by_id(id)
	if mode == null:
		return false
	current_mode = mode
	return true


func set_challenge(id: String) -> bool:
	if id == "":
		current_challenge = null
		return true
	var challenge := get_challenge_by_id(id)
	if challenge == null:
		return false
	current_challenge = challenge
	return true


## Combina o modificador do modo atual com o do desafio atual (se houver) e
## com o da localidade atual — a única fonte de "quão difícil está agora"
## além da rampa de tempo do Endless (ver DifficultyDirector).
func get_combined_modifier() -> DifficultyModifier:
	var result: DifficultyModifier = DifficultyModifier.new()
	if current_mode != null:
		result = DifficultyModifier.combine(result, current_mode.difficulty_modifier)
	if current_challenge != null:
		result = DifficultyModifier.combine(result, current_challenge.modifier)
	if Locations.current != null:
		result = DifficultyModifier.combine(result, Locations.current.difficulty_modifier)
	return result


func _make_mode(id: String, title: String, description: String, endless_enabled: bool, main_cycle_duration: float, reward_multiplier: float) -> GameModeData:
	var data := GameModeData.new()
	data.id = id
	data.display_name = title
	data.description = description
	data.endless_enabled = endless_enabled
	data.main_cycle_duration = main_cycle_duration
	data.reward_multiplier = reward_multiplier
	data.difficulty_modifier = DifficultyModifier.new()
	return data


func _make_challenge(id: String, title: String, description: String, health_mult: float, speed_mult: float, xp_mult: float, spawn_mult: float, reward_mult: float) -> ChallengeData:
	var data := ChallengeData.new()
	data.id = id
	data.display_name = title
	data.description = description
	data.reward_multiplier = reward_mult
	var modifier := DifficultyModifier.new()
	modifier.health_multiplier = health_mult
	modifier.speed_multiplier = speed_mult
	modifier.xp_multiplier = xp_mult
	modifier.spawn_multiplier = spawn_mult
	modifier.reward_multiplier = reward_mult
	data.modifier = modifier
	return data

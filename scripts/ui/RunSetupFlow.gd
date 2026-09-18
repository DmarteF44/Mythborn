class_name RunSetupFlow
extends Node

## Sequencia Personagem -> Skin -> Localidade -> Modo -> Desafio -> Resumo,
## escrevendo cada escolha em Characters/RunConfig/Locations (nunca guarda
## um segundo estado paralelo) e só então chama GameManager.start_new_run().
## Reaproveita UMA SelectionScreen genérica para os 5 primeiros passos.

enum Step { CHARACTER, SKIN, LOCATION, MODE, CHALLENGE }

@onready var selection_screen: SelectionScreen = $SelectionScreen
@onready var summary_screen: RunSummaryScreen = $RunSummaryScreen

var _step: Step = Step.CHARACTER


func _ready() -> void:
	selection_screen.option_selected.connect(_on_option_selected)
	selection_screen.back_pressed.connect(_on_selection_back)
	summary_screen.start_pressed.connect(_on_summary_start)
	summary_screen.back_pressed.connect(_on_summary_back)


func start() -> void:
	_step = Step.CHARACTER
	_open_character()


func _open_character() -> void:
	var options: Array = []
	for character in Characters.pool:
		options.append({
			"id": character.id,
			"title": character.display_name,
			"subtitle": character.origin,
			"description": character.description,
			"locked": not Characters.is_unlocked(character),
			"locked_reason": "Bloqueado.",
			"selected": character.id == RunConfig.selected_character_id,
			"action_label": "SELECIONAR",
		})
	# Slots reservados para personagens futuros — só decorativos.
	for i in 2:
		options.append({"id": "", "title": "???", "locked": true, "locked_reason": "Personagem futuro."})
	selection_screen.open("PERSONAGEM", options)


func _open_skin() -> void:
	var options: Array = []
	for skin in Skins.get_options_for_character(RunConfig.selected_character_id):
		options.append({
			"id": skin.id,
			"title": skin.display_name,
			"locked": not Skins.is_unlocked(skin),
			"locked_reason": "Ainda não desbloqueada.",
			"selected": skin.id == RunConfig.selected_skin_id,
			"action_label": "EQUIPAR",
		})
	selection_screen.open("SKIN", options)


func _open_location() -> void:
	var options: Array = []
	for location in Locations.pool:
		options.append({
			"id": location.id,
			"title": location.display_name,
			"subtitle": location.origin,
			"description": location.description,
			"locked": not UnlockConditionChecker.is_met(location.unlock_condition),
			"locked_reason": "Bloqueada.",
			"selected": location.id == Locations.current.id,
			"action_label": "SELECIONAR",
		})
	selection_screen.open("LOCALIDADE", options)


func _open_mode() -> void:
	var options: Array = []
	for mode in RunConfig.game_modes:
		options.append({
			"id": mode.id,
			"title": mode.display_name,
			"description": mode.description,
			"locked": false,
			"selected": mode.id == RunConfig.current_mode.id,
			"action_label": "SELECIONAR",
		})
	selection_screen.open("MODO", options)


func _open_challenge() -> void:
	var options: Array = [{
		"id": "",
		"title": "Normal",
		"description": "Sem modificadores.",
		"locked": false,
		"selected": RunConfig.current_challenge == null,
		"action_label": "SELECIONAR",
	}]
	for challenge in RunConfig.challenges:
		options.append({
			"id": challenge.id,
			"title": challenge.display_name,
			"description": challenge.description,
			"locked": false,
			"selected": RunConfig.current_challenge != null and RunConfig.current_challenge.id == challenge.id,
			"action_label": "SELECIONAR",
		})
	selection_screen.open("DESAFIO", options)


func _on_option_selected(id: String) -> void:
	match _step:
		Step.CHARACTER:
			if id == "":
				return
			RunConfig.set_character(id)
			_step = Step.SKIN
			selection_screen.close()
			_open_skin()
		Step.SKIN:
			RunConfig.set_skin(id)
			Skins.equip(RunConfig.selected_character_id, id)
			_step = Step.LOCATION
			selection_screen.close()
			_open_location()
		Step.LOCATION:
			Locations.set_current(id)
			_step = Step.MODE
			selection_screen.close()
			_open_mode()
		Step.MODE:
			RunConfig.set_mode(id)
			_step = Step.CHALLENGE
			selection_screen.close()
			_open_challenge()
		Step.CHALLENGE:
			RunConfig.set_challenge(id)
			selection_screen.close()
			summary_screen.open()


func _on_selection_back() -> void:
	selection_screen.close()
	match _step:
		Step.CHARACTER:
			pass # volta a mostrar o Menu Principal por baixo, nada a fazer aqui
		Step.SKIN:
			_step = Step.CHARACTER
			_open_character()
		Step.LOCATION:
			_step = Step.SKIN
			_open_skin()
		Step.MODE:
			_step = Step.LOCATION
			_open_location()
		Step.CHALLENGE:
			_step = Step.MODE
			_open_mode()


func _on_summary_back() -> void:
	summary_screen.close()
	_step = Step.CHALLENGE
	_open_challenge()


func _on_summary_start() -> void:
	summary_screen.close()
	GameManager.start_new_run()

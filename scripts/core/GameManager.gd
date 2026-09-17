extends Node

## Autoload — estado global e navegação entre menu/partida.
## Não guarda lógica de UI: apenas estado, troca de cena e pausa.
## Dados da corrida ficam em RunStats, moeda da run em Economy,
## preferências em Settings.

enum State { MAIN_MENU, PLAYING, EVOLUTION, UPGRADE_SHOP, PAUSED, GAME_OVER }

const MAX_WEAPONS: int = 12

const MAIN_MENU_SCENE := "res://scenes/main/MainMenu.tscn"
const GAME_SCENE := "res://scenes/main/Main.tscn"

signal game_over
signal state_changed(new_state: State)

var state: State = State.MAIN_MENU


func start_new_run() -> void:
	RunStats.reset()
	RunStats.active = true
	Economy.reset()
	get_tree().paused = false
	_set_state(State.PLAYING)
	get_tree().change_scene_to_file(GAME_SCENE)


func go_to_main_menu() -> void:
	RunStats.active = false
	get_tree().paused = false
	_set_state(State.MAIN_MENU)
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func open_pause() -> void:
	if state != State.PLAYING:
		return
	_set_state(State.PAUSED)
	get_tree().paused = true


func open_evolution() -> void:
	_set_state(State.EVOLUTION)
	get_tree().paused = true


func open_upgrade_shop() -> void:
	_set_state(State.UPGRADE_SHOP)
	get_tree().paused = true


func resume_gameplay() -> void:
	_set_state(State.PLAYING)
	get_tree().paused = false


func trigger_game_over() -> void:
	if state == State.GAME_OVER:
		return
	RunStats.active = false
	_set_state(State.GAME_OVER)
	get_tree().paused = true
	game_over.emit()


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(state)

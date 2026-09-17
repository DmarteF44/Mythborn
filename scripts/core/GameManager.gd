extends Node

## Autoload — estado global da partida.

enum State { PLAYING, LEVELING_UP, GAME_OVER }

const MAX_WEAPONS: int = 12

signal game_over

var state: State = State.PLAYING


func pause_for_level_up() -> void:
	state = State.LEVELING_UP
	get_tree().paused = true


func resume() -> void:
	state = State.PLAYING
	get_tree().paused = false


func trigger_game_over() -> void:
	if state == State.GAME_OVER:
		return
	state = State.GAME_OVER
	get_tree().paused = true
	game_over.emit()

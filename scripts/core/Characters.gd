extends Node

## Autoload — registro central de `CharacterData`. Fonte única de verdade
## para a tela de seleção de personagem e para Player.gd resolver qual
## personagem a run atual deve usar (via RunConfig.selected_character_id).

var pool: Array[CharacterData] = []


func _ready() -> void:
	pool = [
		preload("res://resources/characters/wukong_data.tres"),
	]


func get_by_id(id: String) -> CharacterData:
	for character in pool:
		if character.id == id:
			return character
	return null


func is_unlocked(character_data: CharacterData) -> bool:
	if MetaProgress.is_character_unlocked(character_data.id):
		return true
	return UnlockConditionChecker.is_met(character_data.unlock_condition)

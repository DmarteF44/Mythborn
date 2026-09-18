extends Node

## Autoload — catálogo de skins. Uma skin só muda aparência (aqui, o tint do
## Visual) — nunca atributos. `MetaProgress.equipped_skins` guarda qual está
## equipada por personagem; a tela de seleção de skin escreve ali via
## `equip()`, Player.gd só lê `get_equipped_tint()`.

var pool: Array[CharacterSkinData] = []


func _ready() -> void:
	pool = [
		_make("wukong_golden", "wukong", "Wukong Dourado", Color(1.7, 1.35, 0.4, 1)),
	]


## "Default" sempre existe e sempre está desbloqueada — não fica em `pool`
## porque não precisa de unlock/reward, é o estado inicial de qualquer
## personagem.
func get_default_skin(character_id: String) -> CharacterSkinData:
	var data := CharacterSkinData.new()
	data.id = "default"
	data.character_id = character_id
	data.display_name = "Padrão"
	data.tint = Color(1, 1, 1, 1)
	return data


func get_options_for_character(character_id: String) -> Array[CharacterSkinData]:
	var result: Array[CharacterSkinData] = [get_default_skin(character_id)]
	for skin in pool:
		if skin.character_id == character_id:
			result.append(skin)
	return result


func is_unlocked(skin: CharacterSkinData) -> bool:
	if skin.id == "default":
		return true
	if MetaProgress.is_skin_unlocked(skin.id):
		return true
	return UnlockConditionChecker.is_met(skin.unlock_condition)


func equip(character_id: String, skin_id: String) -> void:
	MetaProgress.equip_skin(character_id, skin_id)


func get_equipped_tint(character_id: String) -> Color:
	var equipped_id := MetaProgress.get_equipped_skin(character_id)
	if equipped_id == "default" or equipped_id == "":
		return Color(1, 1, 1, 1)
	for skin in pool:
		if skin.id == equipped_id and skin.character_id == character_id and is_unlocked(skin):
			return skin.tint
	return Color(1, 1, 1, 1)


func _make(id: String, character_id: String, title: String, tint: Color) -> CharacterSkinData:
	var data := CharacterSkinData.new()
	data.id = id
	data.character_id = character_id
	data.display_name = title
	data.tint = tint
	return data

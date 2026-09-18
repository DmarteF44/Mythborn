extends Node

## Autoload — catálogo de skins. Uma skin só muda aparência (aqui, o tint do
## Visual) — nunca atributos. Sem tela de seleção ainda: a primeira skin
## desbloqueada para o personagem atual é equipada automaticamente (ver
## limitações em docs/ARCHITECTURE.md).

var pool: Array[CharacterSkinData] = []


func _ready() -> void:
	pool = [
		_make("wukong_golden", "wukong", "Wukong Dourado", Color(1.7, 1.35, 0.4, 1)),
	]


func get_for_character(character_id: String) -> Array[CharacterSkinData]:
	var result: Array[CharacterSkinData] = []
	for skin in pool:
		if skin.character_id == character_id:
			result.append(skin)
	return result


func get_equipped_tint(character_id: String) -> Color:
	for skin in pool:
		if skin.character_id == character_id and MetaProgress.is_skin_unlocked(skin.id):
			return skin.tint
	return Color(1, 1, 1, 1)


func _make(id: String, character_id: String, title: String, tint: Color) -> CharacterSkinData:
	var data := CharacterSkinData.new()
	data.id = id
	data.character_id = character_id
	data.display_name = title
	data.tint = tint
	return data

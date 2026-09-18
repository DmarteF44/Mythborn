class_name CharacterSkinData
extends Resource

## Uma skin nunca altera atributos — só aparência (aqui, uma cor de
## modulate aplicada ao Visual do personagem; substituível por um sprite
## próprio no futuro sem mudar o resto do pipeline).

@export var id: String = ""
@export var character_id: String = ""
@export var display_name: String = ""
@export var tint: Color = Color(1, 1, 1, 1)

@export var unlock_condition: UnlockCondition
@export var reward: RewardData

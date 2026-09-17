class_name UpgradeData
extends Resource

enum Type { DAMAGE, ATTACK_SPEED, MOVE_SPEED }

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var type: Type = Type.DAMAGE
@export var value: float = 0.0

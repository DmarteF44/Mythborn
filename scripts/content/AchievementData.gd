class_name AchievementData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var secret: bool = false

@export var condition: UnlockCondition
@export var reward: RewardData

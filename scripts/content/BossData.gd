class_name BossData
extends Resource

## Metadados de um chefe. O comportamento/vida real vem de `enemy_data`
## (reaproveita 100% do Enemy/Health/targeting já existentes) — BossData só
## descreve "quem é" e "quando/como recompensa", nunca reimplementa combate.

@export var id: String = ""
@export var display_name: String = ""
@export var origin: String = ""
@export var description: String = ""

@export var enemy_data: EnemyData ## vida/velocidade/dano de contato do boss
@export var spawn_time: float = 300.0 ## segundos de sobrevivência para aparecer

@export var reward: RewardData
@export var secret: bool = false
@export var unlock_condition: UnlockCondition

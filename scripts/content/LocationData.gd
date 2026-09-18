class_name LocationData
extends Resource

## Onde a run acontece. Nenhuma informação de localidade deve ficar
## hard-coded no código de gameplay — EnemySpawner/BossDirector só leem
## Locations.current.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var origin: String = "" ## panteão/mitologia de ambientação

@export var enemy_pool: Array[EnemyData] = []
@export var elite_pool: Array[EnemyData] = [] ## reservado para o futuro
@export var boss_pool: Array[BossData] = []
@export var wave_profile: Array[WaveData] = []

@export var difficulty_modifier: DifficultyModifier
@export var initial_duration: float = 900.0 ## duração do "ciclo principal" antes do Endless
@export var endless_enabled: bool = true

@export var reward: RewardData ## recompensa por "completar" a localidade (futuro)
@export var unlock_condition: UnlockCondition

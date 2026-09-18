class_name WaveData
extends Resource

## Uma janela de tempo dentro de uma run com suas próprias regras de spawn.
## LocationData.wave_profile é uma lista ordenada destas — o EnemySpawner só
## pergunta "qual onda está ativa agora?", nunca decide os números sozinho.

@export var start_time: float = 0.0
@export var end_time: float = 999999.0
@export var spawn_interval: float = 1.5
@export var elite_chance: float = 0.0 ## reservado para o futuro (inimigos elite)

## Se vazio, o spawner usa o enemy_pool geral da localidade.
@export var enemy_pool_override: Array[EnemyData] = []

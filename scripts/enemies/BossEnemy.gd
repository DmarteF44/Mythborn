class_name BossEnemy
extends Enemy

## Reaproveita 100% do comportamento de Enemy (perseguição, contato, vida,
## targeting) — só adiciona metadados de chefe (nome, recompensa) e um
## sinal para a UI mostrar a barra de vida.

signal boss_defeated(boss_data: BossData)
signal boss_health_changed(current: float, max_value: float)

@export var boss_data: BossData


func _ready() -> void:
	enemy_data = boss_data.enemy_data
	super._ready()
	health.health_changed.connect(func(current: float, max_value: float) -> void:
		boss_health_changed.emit(current, max_value)
	)


func _on_died() -> void:
	super._on_died()
	RunStats.bosses_defeated += 1
	RewardResolver.apply(boss_data.reward)
	boss_defeated.emit(boss_data)

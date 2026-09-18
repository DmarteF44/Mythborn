class_name BossEnemy
extends Enemy

## Reaproveita 100% do comportamento de Enemy (perseguição, contato, vida,
## targeting) — só adiciona metadados de chefe (nome, recompensa), fases
## (opcional, ver BossPhaseData) e um sinal para a UI mostrar a barra de vida.
##
## Ponto de extensão para chefes futuros: sobrescrever `_on_phase_changed()`
## numa subclasse para acionar comportamentos especiais (dash, projéteis,
## invocação, telegraph visual) — a detecção de fase em si já é genérica e
## funciona sem nenhuma dessas implementações.

signal boss_defeated(boss_data: BossData)
signal boss_health_changed(current: float, max_value: float)

@export var boss_data: BossData

var _current_phase_index: int = -1


func _ready() -> void:
	enemy_data = boss_data.enemy_data
	super._ready()
	health.health_changed.connect(_on_boss_health_changed)
	_check_phase()


func _on_boss_health_changed(current: float, max_value: float) -> void:
	boss_health_changed.emit(current, max_value)
	_check_phase()


## Compara a vida atual com os limiares de BossData.phases (do mais alto
## para o mais baixo) e, ao cruzar um novo limiar, aplica o multiplicador
## daquela fase sobre os mesmos `_damage_mult`/`_speed_mult` que Enemy já
## usa — nenhuma lógica de movimento/dano é duplicada.
func _check_phase() -> void:
	if boss_data.phases.is_empty():
		return
	var ratio := health.current_health / health.max_health
	for i in range(boss_data.phases.size() - 1, -1, -1):
		if ratio <= boss_data.phases[i].health_threshold:
			if i != _current_phase_index:
				_current_phase_index = i
				_on_phase_changed(boss_data.phases[i])
			return


## Comportamento padrão: só escala dano/velocidade. Sobrescrever para
## comportamentos especiais.
func _on_phase_changed(phase: BossPhaseData) -> void:
	_damage_mult *= phase.damage_multiplier
	_speed_mult *= phase.speed_multiplier


func _on_died() -> void:
	super._on_died()
	RunStats.bosses_defeated += 1
	MetaProgress.register_boss_encounter(boss_data.id, true)
	RewardResolver.apply(boss_data.reward)
	boss_defeated.emit(boss_data)

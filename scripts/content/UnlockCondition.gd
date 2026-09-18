class_name UnlockCondition
extends Resource

## Condição reutilizável por personagens, skins, bosses secretos, localidades,
## modos, desafios e conquistas. Avaliada por UnlockConditionChecker — nenhum
## sistema deve reimplementar sua própria checagem de "está desbloqueado?".

enum Type {
	KILLS,
	SURVIVAL_TIME,
	LEVEL_REACHED,
	BOSS_DEFEATED,
	CHARACTER_EVOLUTION,
	ACHIEVEMENT,
	CURRENCY,
	COMBINATION,
	ALWAYS_MET,
}

enum Comparison { AT_LEAST, AT_MOST }

@export var type: Type = Type.ALWAYS_MET
@export var comparison: Comparison = Comparison.AT_LEAST
@export var amount: float = 0.0
@export var target_id: String = ""

## Usado apenas quando type == COMBINATION: todas devem ser satisfeitas (AND).
@export var sub_conditions: Array[UnlockCondition] = []

class_name UnlockConditionChecker
extends RefCounted

## Ponto único de avaliação de UnlockCondition — reutilizado por conquistas,
## personagens, skins, bosses secretos, localidades, modos e desafios.
## Lê apenas de fontes já centralizadas (RunStats, Economy, MetaProgress,
## Achievements), nunca duplica um contador próprio.


static func is_met(condition: UnlockCondition) -> bool:
	if condition == null:
		return true

	var current := _current_value(condition)

	match condition.type:
		UnlockCondition.Type.ALWAYS_MET:
			return true
		UnlockCondition.Type.ACHIEVEMENT:
			return Achievements.is_unlocked(condition.target_id)
		UnlockCondition.Type.COMBINATION:
			for sub in condition.sub_conditions:
				if not is_met(sub):
					return false
			return true
		_:
			if condition.comparison == UnlockCondition.Comparison.AT_MOST:
				return current <= condition.amount
			return current >= condition.amount


static func _current_value(condition: UnlockCondition) -> float:
	match condition.type:
		UnlockCondition.Type.KILLS:
			return RunStats.enemies_defeated
		UnlockCondition.Type.SURVIVAL_TIME:
			return RunStats.survival_time
		UnlockCondition.Type.LEVEL_REACHED:
			return RunStats.level_reached
		UnlockCondition.Type.BOSS_DEFEATED:
			return RunStats.bosses_defeated
		UnlockCondition.Type.CHARACTER_EVOLUTION:
			return RunStats.evolution_stage_reached
		UnlockCondition.Type.CURRENCY:
			return MetaProgress.currency
	return 0.0

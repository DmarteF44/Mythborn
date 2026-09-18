extends Node

## Autoload — escalonamento de dificuldade ao longo da run. Combina o
## modificador de RunConfig (modo + desafio + localidade) com uma rampa
## dependente do tempo assim que o Endless começa (survival_time além de
## `current_mode.main_cycle_duration`).

const ENDLESS_RAMP_PER_MINUTE := 0.12 ## +12% vida/dano/spawn por minuto de Endless


func get_modifier() -> DifficultyModifier:
	var result := RunConfig.get_combined_modifier()

	var mode := RunConfig.current_mode
	if mode != null and mode.endless_enabled:
		var ramp_start: float = mode.main_cycle_duration
		if RunStats.survival_time > ramp_start:
			var minutes_in_endless := (RunStats.survival_time - ramp_start) / 60.0
			var ramp := 1.0 + ENDLESS_RAMP_PER_MINUTE * minutes_in_endless
			result.health_multiplier *= ramp
			result.damage_multiplier *= ramp
			result.spawn_multiplier *= ramp

	return result


func get_enemy_health_mult() -> float:
	return get_modifier().health_multiplier


func get_enemy_damage_mult() -> float:
	return get_modifier().damage_multiplier


func get_enemy_speed_mult() -> float:
	return get_modifier().speed_multiplier


func get_spawn_interval_mult() -> float:
	return 1.0 / max(0.1, get_modifier().spawn_multiplier)


func get_xp_mult() -> float:
	return get_modifier().xp_multiplier


func get_reward_mult() -> float:
	return get_modifier().reward_multiplier


func is_in_endless() -> bool:
	var mode := RunConfig.current_mode
	if mode == null or not mode.endless_enabled:
		return false
	return RunStats.survival_time > mode.main_cycle_duration

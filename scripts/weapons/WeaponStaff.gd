class_name WeaponStaff
extends Weapon

## Ruyi Jingu Bang (Bastão de Sun Wukong) — arma corpo a corpo inicial:
## acerta diretamente o alvo mais próximo dentro do alcance, com um arco de
## golpe visível e flash de impacto no alvo.

@onready var swing_visual: Node2D = $SwingVisual


func _perform_attack(target: Node2D) -> void:
	var target_health := target.get_node_or_null("Health") as Health
	if target_health != null:
		target_health.take_damage(_get_effective_damage())
	_flash_target(target)
	_play_swing_feedback(target)


func _play_swing_feedback(target: Node2D) -> void:
	if swing_visual == null:
		return
	var base_angle := (target.global_position - global_position).angle()
	swing_visual.rotation = base_angle - 0.5
	swing_visual.modulate.a = 1.0
	swing_visual.visible = true

	var tween := create_tween()
	tween.tween_property(swing_visual, "rotation", base_angle + 0.5, 0.12)
	tween.parallel().tween_property(swing_visual, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func() -> void:
		swing_visual.visible = false
		swing_visual.modulate.a = 1.0
	)

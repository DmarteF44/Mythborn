class_name WeaponStaff
extends Weapon

## Arma corpo a corpo: acerta diretamente o alvo mais próximo dentro do alcance.

@onready var swing_visual: Node2D = $SwingVisual


func _perform_attack(target: Node2D) -> void:
	var target_health := target.get_node_or_null("Health") as Health
	if target_health != null:
		target_health.take_damage(_get_effective_damage())
	_play_swing_feedback(target)


func _play_swing_feedback(target: Node2D) -> void:
	if swing_visual == null:
		return
	swing_visual.look_at(target.global_position)
	swing_visual.visible = true
	var tween := create_tween()
	tween.tween_property(swing_visual, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		swing_visual.visible = false
		swing_visual.modulate.a = 1.0
	)

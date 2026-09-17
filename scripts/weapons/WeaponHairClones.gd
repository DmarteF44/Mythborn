class_name WeaponHairClones
extends Weapon

## Clones de Pelo — poder de Wukong: golpeia até 2 inimigos próximos por
## ciclo, um dano menor que o Bastão mas atingindo mais de um alvo.

func _perform_attack(_target: Node2D) -> void:
	var targets := TargetingUtils.get_enemies_in_range(global_position, _get_effective_range(), 2)
	for target in targets:
		var target_health := target.get_node_or_null("Health") as Health
		if target_health != null:
			target_health.take_damage(_get_effective_damage())
		_flash_target(target)

class_name WeaponSpark
extends Weapon

## Fagulha Divina — arma de longo alcance à base de projétil. Deliberadamente
## sem vínculo com nenhuma mitologia específica: prova de que a build de
## Wukong não fica presa a poderes chineses.

@export var projectile_scene: PackedScene


func _perform_attack(target: Node2D) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.setup(target.global_position, _get_effective_damage())

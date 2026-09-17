class_name TargetingUtils
extends RefCounted

## Ponto único de busca de alvo, reutilizado por todas as armas.


static func get_closest_enemy(from_position: Vector2, max_range: float = -1.0) -> Node2D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	var closest: Node2D = null
	var closest_distance := INF

	for enemy in tree.get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not (enemy is Node2D):
			continue
		var distance := from_position.distance_to(enemy.global_position)
		if distance < closest_distance and (max_range < 0.0 or distance <= max_range):
			closest_distance = distance
			closest = enemy

	return closest


static func get_player() -> Node2D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.get_first_node_in_group("player") as Node2D

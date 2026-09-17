class_name XPGem
extends Area2D

var xp_value: float = 5.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_xp_value(value: float) -> void:
	xp_value = value


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var experience := body.get_node_or_null("PlayerExperience") as PlayerExperience
	if experience != null:
		experience.add_xp(xp_value)
	queue_free()

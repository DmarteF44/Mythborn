class_name PickupMagnet
extends Area2D

## Atrai pickups (XP, futuramente Essência/loot) para o jogador quando
## entram no raio de coleta. O raio é controlado externamente via
## set_radius() — PlayerStats.get_pickup_radius() é a fonte de verdade.

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func set_radius(value: float) -> void:
	var shape := _collision_shape.shape as CircleShape2D
	if shape != null:
		shape.radius = value


func _on_area_entered(area: Node2D) -> void:
	if area.has_method("start_attracting"):
		area.start_attracting(get_parent())

class_name Enemy
extends CharacterBody2D

@export var enemy_data: EnemyData
@export var xp_gem_scene: PackedScene

@onready var health: Health = $Health
@onready var contact_area: Area2D = $ContactArea
@onready var contact_timer: Timer = $ContactArea/ContactTimer

var _player_in_contact: Node2D = null


func _ready() -> void:
	add_to_group("enemies")

	health.max_health = enemy_data.max_health
	health.current_health = enemy_data.max_health
	health.died.connect(_on_died)

	contact_area.body_entered.connect(_on_contact_body_entered)
	contact_area.body_exited.connect(_on_contact_body_exited)
	contact_timer.timeout.connect(_on_contact_tick)


func _physics_process(_delta: float) -> void:
	var player := TargetingUtils.get_player()
	if player != null:
		velocity = (player.global_position - global_position).normalized() * enemy_data.move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _on_contact_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_contact = body
	_deal_contact_damage()
	contact_timer.start()


func _on_contact_body_exited(body: Node2D) -> void:
	if body == _player_in_contact:
		_player_in_contact = null
		contact_timer.stop()


func _on_contact_tick() -> void:
	if _player_in_contact != null:
		_deal_contact_damage()


func _deal_contact_damage() -> void:
	var player_health := _player_in_contact.get_node_or_null("Health") as Health
	if player_health != null:
		player_health.take_damage(enemy_data.contact_damage)


func _on_died() -> void:
	_spawn_xp_gem()
	queue_free()


func _spawn_xp_gem() -> void:
	if xp_gem_scene == null:
		return
	var gem := xp_gem_scene.instantiate()
	gem.global_position = global_position
	if gem.has_method("set_xp_value"):
		gem.set_xp_value(enemy_data.xp_value)
	get_tree().current_scene.add_child(gem)

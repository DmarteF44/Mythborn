class_name XPGem
extends Area2D

## Pickup de XP com magnetismo: fica parada (IDLE) até entrar no raio do
## PickupMagnet do jogador, então acelera suavemente em direção a ele
## (ATTRACTING) até ser coletada por contato (COLLECTED). Nunca teleporta.

enum State { IDLE, ATTRACTING, COLLECTED }

@export var attract_speed: float = 260.0
@export var attract_acceleration: float = 600.0

var xp_value: float = 5.0
var state: State = State.IDLE

var _target: Node2D = null
var _current_speed: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_xp_value(value: float) -> void:
	xp_value = value


## Chamado pelo PickupMagnet quando o jogador entra no raio de coleta.
func start_attracting(target: Node2D) -> void:
	if state == State.COLLECTED:
		return
	state = State.ATTRACTING
	_target = target


func _physics_process(delta: float) -> void:
	if state != State.ATTRACTING or _target == null or not is_instance_valid(_target):
		return
	_current_speed = min(_current_speed + attract_acceleration * delta, attract_speed)
	var offset := _target.global_position - global_position
	if offset.length() <= 4.0:
		return
	global_position += offset.normalized() * _current_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if state == State.COLLECTED:
		return
	if not body.is_in_group("player"):
		return
	state = State.COLLECTED
	var experience := body.get_node_or_null("PlayerExperience") as PlayerExperience
	if experience != null:
		experience.add_xp(xp_value)
	queue_free()

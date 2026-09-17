class_name Projectile
extends Area2D

## Projétil simples em linha reta — usado por armas de longo alcance
## (ex.: Fagulha Divina). Não homing: mira a posição do alvo no instante do
## disparo, como um jogo de sobrevivência clássico.

@export var speed: float = 420.0
@export var lifetime: float = 1.5

var _velocity: Vector2 = Vector2.ZERO
var _damage: float = 0.0


func setup(target_position: Vector2, damage: float) -> void:
	_velocity = (target_position - global_position).normalized() * speed
	_damage = damage
	rotation = _velocity.angle()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += _velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	var health := body.get_node_or_null("Health") as Health
	if health != null:
		health.take_damage(_damage)
	queue_free()

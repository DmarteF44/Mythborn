class_name VirtualJoystick
extends Control

## Joystick virtual para movimento. Funciona com toque (celular) e com
## mouse (útil para testar a build web direto no navegador).

@export var max_distance: float = 60.0

@onready var base_circle: Control = $BaseCircle
@onready var knob: Control = $BaseCircle/Knob

var _base_center: Vector2
var _dragging := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_base_center = base_circle.position + base_circle.size / 2.0
	_reset_knob()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_press(event.pressed, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_press(event.pressed, event.position)
	elif event is InputEventScreenDrag and _dragging:
		_update_knob(event.position)
	elif event is InputEventMouseMotion and _dragging:
		_update_knob(event.position)


func _handle_press(pressed: bool, at_position: Vector2) -> void:
	_dragging = pressed
	if pressed:
		_update_knob(at_position)
	else:
		_release_all()
		_reset_knob()


func _update_knob(at_position: Vector2) -> void:
	var offset := at_position - _base_center
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance
	knob.position = (_base_center + offset) - knob.size / 2.0 - base_circle.position

	var normalized := offset / max_distance
	Input.action_press("move_right", clampf(normalized.x, 0.0, 1.0))
	Input.action_press("move_left", clampf(-normalized.x, 0.0, 1.0))
	Input.action_press("move_down", clampf(normalized.y, 0.0, 1.0))
	Input.action_press("move_up", clampf(-normalized.y, 0.0, 1.0))


func _reset_knob() -> void:
	knob.position = base_circle.size / 2.0 - knob.size / 2.0


func _release_all() -> void:
	Input.action_release("move_right")
	Input.action_release("move_left")
	Input.action_release("move_down")
	Input.action_release("move_up")

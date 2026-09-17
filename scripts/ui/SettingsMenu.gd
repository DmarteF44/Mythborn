class_name SettingsMenu
extends CanvasLayer

## Painel de configurações reutilizável — instanciado tanto pelo Menu
## Principal quanto pelo Pause. Não decide o que acontece ao fechar,
## apenas se esconde; quem o abriu continua visível por baixo.

@onready var sound_button: Button = $Panel/Background/VBox/SoundRow/SoundButton
@onready var music_button: Button = $Panel/Background/VBox/MusicRow/MusicButton
@onready var vibration_button: Button = $Panel/Background/VBox/VibrationRow/VibrationButton
@onready var back_button: Button = $Panel/Background/VBox/BackButton


func _ready() -> void:
	visible = false
	sound_button.pressed.connect(_on_sound_pressed)
	music_button.pressed.connect(_on_music_pressed)
	vibration_button.pressed.connect(_on_vibration_pressed)
	back_button.pressed.connect(close)


func open() -> void:
	_refresh_labels()
	visible = true


func close() -> void:
	visible = false


func _on_sound_pressed() -> void:
	Settings.set_sound_enabled(not Settings.sound_enabled)
	_refresh_labels()


func _on_music_pressed() -> void:
	Settings.set_music_enabled(not Settings.music_enabled)
	_refresh_labels()


func _on_vibration_pressed() -> void:
	Settings.set_vibration_enabled(not Settings.vibration_enabled)
	_refresh_labels()


func _refresh_labels() -> void:
	sound_button.text = "ON" if Settings.sound_enabled else "OFF"
	music_button.text = "ON" if Settings.music_enabled else "OFF"
	vibration_button.text = "ON" if Settings.vibration_enabled else "OFF"

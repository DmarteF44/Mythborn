extends Node

## Autoload — preferências do jogador. Persistidas em user://settings.cfg.
## Cada opção é real: som/música mutam buses de áudio de verdade (mesmo sem
## nenhum som ainda tocando) e vibração aciona o motor de vibração do aparelho.

const SAVE_PATH := "user://settings.cfg"

var sound_enabled: bool = true
var music_enabled: bool = true
var vibration_enabled: bool = true


func _ready() -> void:
	_load()
	_apply_audio_state()


func set_sound_enabled(value: bool) -> void:
	sound_enabled = value
	_apply_audio_state()
	_save()


func set_music_enabled(value: bool) -> void:
	music_enabled = value
	_apply_audio_state()
	_save()


func set_vibration_enabled(value: bool) -> void:
	vibration_enabled = value
	_save()


func trigger_haptic(duration_ms: int = 60) -> void:
	if vibration_enabled:
		Input.vibrate_handheld(duration_ms)


func _apply_audio_state() -> void:
	_set_bus_mute("SFX", not sound_enabled)
	_set_bus_mute("Music", not music_enabled)


func _set_bus_mute(bus_name: String, muted: bool) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index != -1:
		AudioServer.set_bus_mute(index, muted)


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "music_enabled", music_enabled)
	config.set_value("settings", "vibration_enabled", vibration_enabled)
	config.save(SAVE_PATH)


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	sound_enabled = config.get_value("settings", "sound_enabled", true)
	music_enabled = config.get_value("settings", "music_enabled", true)
	vibration_enabled = config.get_value("settings", "vibration_enabled", true)

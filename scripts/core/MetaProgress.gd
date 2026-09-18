extends Node

## Autoload — tudo que PERSISTE entre partidas (conta do jogador). Nunca se
## mistura com RunStats/Economy (que são temporários e resetam a cada run).

const SAVE_PATH := "user://meta_progress.cfg"
const SAVE_VERSION := 1

signal currency_changed(amount: int)
signal unlocked(kind: String, id: String)

var currency: int = 0 ## Fragmentos Míticos
var unlocked_characters: Array[String] = ["wukong"]
var unlocked_skins: Array[String] = []
var unlocked_achievements: Array[String] = []
var meta_upgrade_levels: Dictionary = {}
var records: Dictionary = {}


func _ready() -> void:
	_load()


func add_currency(amount: int) -> void:
	if amount <= 0:
		return
	currency += amount
	currency_changed.emit(currency)
	_save()


func spend_currency(cost: int) -> bool:
	if currency < cost:
		return false
	currency -= cost
	currency_changed.emit(currency)
	_save()
	return true


func unlock_character(id: String) -> void:
	if unlocked_characters.has(id):
		return
	unlocked_characters.append(id)
	unlocked.emit("character", id)
	_save()


func unlock_skin(id: String) -> void:
	if unlocked_skins.has(id):
		return
	unlocked_skins.append(id)
	unlocked.emit("skin", id)
	_save()


func unlock_achievement(id: String) -> void:
	if unlocked_achievements.has(id):
		return
	unlocked_achievements.append(id)
	unlocked.emit("achievement", id)
	_save()


func is_character_unlocked(id: String) -> bool:
	return unlocked_characters.has(id)


func is_skin_unlocked(id: String) -> bool:
	return unlocked_skins.has(id)


func get_meta_upgrade_level(id: String) -> int:
	return meta_upgrade_levels.get(id, 0)


func set_meta_upgrade_level(id: String, level: int) -> void:
	meta_upgrade_levels[id] = level
	_save()


## Guarda o melhor valor de um recorde (ex.: "best_survival_time").
func update_record(key: String, value: float, higher_is_better: bool = true) -> bool:
	var current: float = records.get(key, -INF if higher_is_better else INF)
	var improved: bool = value > current if higher_is_better else value < current
	if improved:
		records[key] = value
		_save()
	return improved


func get_record(key: String, default: float = 0.0) -> float:
	return records.get(key, default)


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "version", SAVE_VERSION)
	config.set_value("meta", "currency", currency)
	config.set_value("meta", "unlocked_characters", unlocked_characters)
	config.set_value("meta", "unlocked_skins", unlocked_skins)
	config.set_value("meta", "unlocked_achievements", unlocked_achievements)
	config.set_value("meta", "meta_upgrade_levels", meta_upgrade_levels)
	config.set_value("meta", "records", records)
	config.save(SAVE_PATH)


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	# `version` está reservado para migração futura de save (ainda não há
	# formatos antigos a migrar nesta etapa).
	currency = config.get_value("meta", "currency", 0)
	unlocked_characters = config.get_value("meta", "unlocked_characters", ["wukong"])
	unlocked_skins = config.get_value("meta", "unlocked_skins", [])
	unlocked_achievements = config.get_value("meta", "unlocked_achievements", [])
	meta_upgrade_levels = config.get_value("meta", "meta_upgrade_levels", {})
	records = config.get_value("meta", "records", {})

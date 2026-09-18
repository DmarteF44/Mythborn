extends Node

## Autoload — catálogo de conquistas + checagem automática. Escuta o estado
## já centralizado em RunStats/Economy (nenhum evento espalhado pelo
## projeto) e persiste o desbloqueio via MetaProgress.

signal achievement_unlocked(id: String)

var pool: Array[AchievementData] = []


func _ready() -> void:
	pool = [
		_make("first_kill", "Primeiro Sangue", "Derrote seu primeiro inimigo.", false,
			_cond(UnlockCondition.Type.KILLS, 1), _reward(0, 10, "", "")),
		_make("first_level", "Em Ascensão", "Alcance o nível 2.", false,
			_cond(UnlockCondition.Type.LEVEL_REACHED, 2), _reward(20, 0, "", "")),
		_make("evolution_sun_wukong", "O Rei Macaco", "Evolua para Sun Wukong.", false,
			_cond(UnlockCondition.Type.CHARACTER_EVOLUTION, 1), _reward(30, 0, "", "")),
		_make("boss_slayer", "Caçador de Lendas", "Derrote um chefe.", false,
			_cond(UnlockCondition.Type.BOSS_DEFEATED, 1), _reward(100, 0, "", "wukong_golden")),
		_make("survivor_5min", "Sobrevivente", "Sobreviva por 5 minutos em uma run.", false,
			_cond(UnlockCondition.Type.SURVIVAL_TIME, 300), _reward(50, 0, "", "")),
		_make("awakened_rush", "Despertar Precoce", "Alcance o Despertar em menos de 5 minutos.", true,
			_combo([
				_cond(UnlockCondition.Type.CHARACTER_EVOLUTION, 2),
				_cond(UnlockCondition.Type.SURVIVAL_TIME, 300, UnlockCondition.Comparison.AT_MOST),
			]),
			_reward(150, 0, "", "")),
	]


func _process(_delta: float) -> void:
	if not RunStats.active:
		return
	for achievement in pool:
		if is_unlocked(achievement.id):
			continue
		if UnlockConditionChecker.is_met(achievement.condition):
			_unlock(achievement)


func is_unlocked(id: String) -> bool:
	return MetaProgress.unlocked_achievements.has(id)


## Concede diretamente (usado por recompensas de boss/loja que apontam para
## uma conquista específica), sem precisar que a condição seja reavaliada.
func force_unlock(id: String) -> void:
	if is_unlocked(id):
		return
	for achievement in pool:
		if achievement.id == id:
			_unlock(achievement)
			return
	MetaProgress.unlock_achievement(id)


func get_by_id(id: String) -> AchievementData:
	for achievement in pool:
		if achievement.id == id:
			return achievement
	return null


func _unlock(achievement: AchievementData) -> void:
	MetaProgress.unlock_achievement(achievement.id)
	RewardResolver.apply(achievement.reward)
	if RunStats.active:
		RunStats.achievements_unlocked_this_run.append(achievement.id)
	achievement_unlocked.emit(achievement.id)


func _make(id: String, title: String, description: String, secret: bool, condition: UnlockCondition, reward: RewardData) -> AchievementData:
	var data := AchievementData.new()
	data.id = id
	data.display_name = title
	data.description = description
	data.secret = secret
	data.condition = condition
	data.reward = reward
	return data


func _cond(type: UnlockCondition.Type, amount: float, comparison: UnlockCondition.Comparison = UnlockCondition.Comparison.AT_LEAST) -> UnlockCondition:
	var c := UnlockCondition.new()
	c.type = type
	c.amount = amount
	c.comparison = comparison
	return c


func _combo(sub_conditions: Array[UnlockCondition]) -> UnlockCondition:
	var c := UnlockCondition.new()
	c.type = UnlockCondition.Type.COMBINATION
	c.sub_conditions = sub_conditions
	return c


func _reward(currency_amount: int, essence_amount: int, unlock_character_id: String, unlock_skin_id: String) -> RewardData:
	var r := RewardData.new()
	r.currency_amount = currency_amount
	r.essence_amount = essence_amount
	r.unlock_character_id = unlock_character_id
	r.unlock_skin_id = unlock_skin_id
	return r

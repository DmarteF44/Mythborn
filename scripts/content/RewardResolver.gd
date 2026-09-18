class_name RewardResolver
extends RefCounted

## Ponto único de aplicação de recompensas — nenhum sistema credita moeda ou
## desbloqueia conteúdo "na mão".


static func apply(reward: RewardData) -> void:
	if reward == null:
		return
	if reward.currency_amount > 0:
		MetaProgress.add_currency(reward.currency_amount)
	if reward.essence_amount > 0:
		Economy.add(reward.essence_amount)
	if reward.unlock_character_id != "":
		MetaProgress.unlock_character(reward.unlock_character_id)
	if reward.unlock_skin_id != "":
		MetaProgress.unlock_skin(reward.unlock_skin_id)
	if reward.unlock_achievement_id != "":
		Achievements.force_unlock(reward.unlock_achievement_id)

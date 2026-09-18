class_name RewardData
extends Resource

## Uma recompensa pode conter múltiplos itens ao mesmo tempo (ex.: derrotar
## um boss pode dar Essência + progresso de conquista). Aplicada de forma
## centralizada por RewardResolver — nenhum sistema aplica recompensa "na mão".

@export var currency_amount: int = 0 ## Fragmentos Míticos (conta, permanente)
@export var essence_amount: int = 0 ## Essência (run atual, temporária)
@export var unlock_character_id: String = ""
@export var unlock_skin_id: String = ""
@export var unlock_achievement_id: String = "" ## desbloqueia uma conquista diretamente

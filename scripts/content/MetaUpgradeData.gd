class_name MetaUpgradeData
extends Resource

## Progressão permanente (entre partidas), paga em Fragmentos Míticos —
## equivalente meta de UpgradeData, mas nunca reseta com a run.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

@export var type: UpgradeData.Type = UpgradeData.Type.DAMAGE
@export var value_per_level: float = 0.02
@export var max_level: int = 5
@export var cost_per_level: int = 50

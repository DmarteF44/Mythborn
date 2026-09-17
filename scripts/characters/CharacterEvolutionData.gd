class_name CharacterEvolutionData
extends Resource

## Um estágio de evolução de um personagem (ex.: WUKONG -> SUN WUKONG).
## A lista ordenada dessas entradas em CharacterData é a única fonte de
## verdade sobre quando/como um personagem evolui — nada disso fica
## hard-coded em Player.gd ou na UI.

enum Stage { INITIAL, EVOLVED, AWAKENED }

@export var stage: Stage = Stage.INITIAL
@export var level_required: int = 1
@export var display_name: String = ""

## Multiplicadores aplicados UMA VEZ ao atingir este estágio (não por segundo).
@export var health_bonus_mult: float = 1.0
@export var move_speed_bonus_mult: float = 1.0
@export var damage_bonus_mult: float = 1.0
@export var attack_speed_bonus_mult: float = 1.0

## Arma/poder concedido ao entrar neste estágio (opcional).
@export var unlocked_power_scene: PackedScene
@export var unlocked_power_label: String = ""

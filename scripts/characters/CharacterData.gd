class_name CharacterData
extends Resource

## Define quem o jogador é. Um personagem novo (Zeus, Hades, ...) é apenas
## um novo .tres desta classe — Player.gd não precisa saber quantos existem.

@export var id: String = ""
@export var character_name: String = ""
@export var display_name: String = ""
@export var origin: String = ""
@export var description: String = ""

@export var base_health: float = 30.0
@export var base_move_speed: float = 220.0

@export var starting_weapon: PackedScene

## Ordenado por level_required crescente; o índice 0 é sempre o estágio inicial.
@export var evolutions: Array[CharacterEvolutionData] = []

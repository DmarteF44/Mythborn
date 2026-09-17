extends Node

## Autoload — catálogo de armas/poderes disponíveis na loja unificada.
## Adicionar uma nova = adicionar uma entrada aqui, sem tocar na loja.
##
## Cada entrada é {"data": WeaponData, "scene": PackedScene}. Guardar a cena
## separada do WeaponData evita uma referência circular entre o .tres da
## arma e a cena que o carrega como seu próprio weapon_data.

var pool: Array[Dictionary] = []


func _ready() -> void:
	pool = [
		{"data": preload("res://resources/weapons/staff_data.tres"), "scene": preload("res://scenes/weapons/Staff.tscn")},
		{"data": preload("res://resources/weapons/hair_clones_data.tres"), "scene": preload("res://scenes/weapons/HairClones.tscn")},
		{"data": preload("res://resources/weapons/spark_data.tres"), "scene": preload("res://scenes/weapons/Spark.tscn")},
	]

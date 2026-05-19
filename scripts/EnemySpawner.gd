class_name EnemySpawner
extends Node2D

@export var fase_numero: int = 1

var _ondas: Array = []
var _ondas_lancadas: int = 0
var _inimigos_vivos: int = 0
var _fase_encerrada: bool = false
var _player: Player

signal fase_completa

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	_configurar_ondas(fase_numero)

func _process(_delta: float) -> void:
	if GameManager.estado_atual != GameManager.Estado.JOGANDO:
		return
	if _fase_encerrada or not _player:
		return
	if _ondas_lancadas >= _ondas.size():
		return

	var onda: Dictionary = _ondas[_ondas_lancadas]
	if _player.global_position.x >= onda["posicao_x"]:
		_lancar_onda(onda)
		_ondas_lancadas += 1

func _configurar_ondas(numero: int) -> void:
	var lixo_papel: PackedScene = preload("res://scenes/enemies/Lixo.tscn")
	var lixo_plastico: PackedScene = preload("res://scenes/enemies/Lixo.tscn")
	var lixo_metal: PackedScene = preload("res://scenes/enemies/Lixo.tscn")
	var lixo_organico: PackedScene = preload("res://scenes/enemies/Lixo.tscn")
	var lixo_especial: PackedScene = preload("res://scenes/enemies/LixoEspecial.tscn")

	match numero:
		1: # Área: Papel
			_ondas = [
				{ "cena": lixo_papel, "quantidade": 3, "posicao_x": 400.0 },
				{ "cena": lixo_papel, "quantidade": 4, "posicao_x": 800.0 },
				{ "cena": lixo_especial, "quantidade": 2, "posicao_x": 1200.0 },
				{ "cena": lixo_papel, "quantidade": 5, "posicao_x": 1600.0 },
			]
		2: # Área: Plástico
			_ondas = [
				{ "cena": lixo_plastico, "quantidade": 4, "posicao_x": 400.0 },
				{ "cena": lixo_plastico, "quantidade": 5, "posicao_x": 800.0 },
				{ "cena": lixo_especial, "quantidade": 3, "posicao_x": 1100.0 },
				{ "cena": lixo_plastico, "quantidade": 6, "posicao_x": 1500.0 },
				{ "cena": lixo_especial, "quantidade": 2, "posicao_x": 1900.0 },
			]
		3: # Área: Metal
			_ondas = [
				{ "cena": lixo_metal, "quantidade": 5, "posicao_x": 350.0 },
				{ "cena": lixo_especial, "quantidade": 3, "posicao_x": 700.0 },
				{ "cena": lixo_metal, "quantidade": 6, "posicao_x": 1050.0 },
				{ "cena": lixo_especial, "quantidade": 4, "posicao_x": 1400.0 },
				{ "cena": lixo_metal, "quantidade": 7, "posicao_x": 1750.0 },
			]
		4: # Área: Orgânico
			_ondas = [
				{ "cena": lixo_organico, "quantidade": 6, "posicao_x": 300.0 },
				{ "cena": lixo_especial, "quantidade": 4, "posicao_x": 650.0 },
				{ "cena": lixo_organico, "quantidade": 7, "posicao_x": 1000.0 },
				{ "cena": lixo_especial, "quantidade": 5, "posicao_x": 1350.0 },
				{ "cena": lixo_organico, "quantidade": 8, "posicao_x": 1700.0 },
				{ "cena": lixo_especial, "quantidade": 3, "posicao_x": 2050.0 },
			]

func _lancar_onda(onda: Dictionary) -> void:
	var cena: PackedScene = onda["cena"]
	var quantidade: int = onda["quantidade"]
	var pos_x: float = onda["posicao_x"] + 300.0

	for i in range(quantidade):
		var inimigo: Inimigo = cena.instantiate() as Inimigo
		get_parent().add_child(inimigo)
		inimigo.global_position = Vector2(pos_x + i * 120.0, _player.global_position.y)
		inimigo.tree_exited.connect(_on_inimigo_saiu)
		_inimigos_vivos += 1

func _on_inimigo_saiu() -> void:
	_inimigos_vivos -= 1
	if _ondas_lancadas >= _ondas.size() and _inimigos_vivos <= 0 and not _fase_encerrada:
		_fase_encerrada = true
		fase_completa.emit()

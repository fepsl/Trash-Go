class_name EnemySpawner
extends Node2D

const MULT_VIDA_POR_FASE: Array[float] = [1.0, 1.3, 1.8, 2.5]

@export var fase_numero: int = 1

var _ondas: Array = []
var _ondas_lancadas: int = 0
var _inimigos_vivos: int = 0
var _fase_encerrada: bool = false
var _aguardando_retomada: bool = false
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
	var n := GameManager.num_loops

	match numero:
		1: # Papel
			_ondas = [
				{ "cena": lixo_papel,    "quantidade": 2 + n, "posicao_x": 500.0 },
				{ "cena": lixo_papel,    "quantidade": 3 + n, "posicao_x": 1500.0 },
				{ "cena": lixo_especial, "quantidade": 1 + n, "posicao_x": 2500.0 },
				{ "cena": lixo_papel,    "quantidade": 3 + n, "posicao_x": 3500.0 },
			]
		2: # Plastico
			_ondas = [
				{ "cena": lixo_plastico, "quantidade": 2 + n, "posicao_x": 500.0 },
				{ "cena": lixo_plastico, "quantidade": 3 + n, "posicao_x": 1500.0 },
				{ "cena": lixo_especial, "quantidade": 2 + n, "posicao_x": 2500.0 },
				{ "cena": lixo_plastico, "quantidade": 3 + n, "posicao_x": 3500.0 },
				{ "cena": lixo_especial, "quantidade": 2 + n, "posicao_x": 4500.0 },
			]
		3: # Metal
			_ondas = [
				{ "cena": lixo_metal,    "quantidade": 3 + n, "posicao_x": 500.0 },
				{ "cena": lixo_especial, "quantidade": 2 + n, "posicao_x": 1500.0 },
				{ "cena": lixo_metal,    "quantidade": 4 + n, "posicao_x": 2500.0 },
				{ "cena": lixo_especial, "quantidade": 2 + n, "posicao_x": 3500.0 },
				{ "cena": lixo_metal,    "quantidade": 4 + n, "posicao_x": 4500.0 },
			]
		4: # Organico
			_ondas = [
				{ "cena": lixo_organico, "quantidade": 3 + n,  "posicao_x": 500.0 },
				{ "cena": lixo_especial, "quantidade": 2 + n,  "posicao_x": 1500.0 },
				{ "cena": lixo_organico, "quantidade": 4 + n,  "posicao_x": 2500.0 },
				{ "cena": lixo_especial, "quantidade": 3 + n,  "posicao_x": 3500.0 },
				{ "cena": lixo_organico, "quantidade": 4 + n,  "posicao_x": 4500.0 },
				{ "cena": lixo_especial, "quantidade": 2 + n,  "posicao_x": 5500.0 },
			]

func _lancar_onda(onda: Dictionary) -> void:
	var cena: PackedScene = onda["cena"]
	var quantidade: int = onda["quantidade"]
	var pos_x: float = onda["posicao_x"] + 600.0
	var mult_fase: float = MULT_VIDA_POR_FASE[fase_numero - 1]
	var mult_loop: float = 1.0 + GameManager.num_loops * 0.4
	var mult: float = mult_fase * mult_loop

	for i in range(quantidade):
		var inimigo: Inimigo = cena.instantiate() as Inimigo
		get_parent().add_child(inimigo)
		inimigo.vida_base = int(inimigo.vida_base * mult)
		inimigo.vida_atual = inimigo.vida_base
		inimigo.slot_offset = 120.0 + i * 150.0
		inimigo.global_position = Vector2(
			_player.global_position.x + inimigo.slot_offset + 500.0,
			_player.global_position.y
		)
		inimigo.tree_exited.connect(_on_inimigo_saiu)
		_inimigos_vivos += 1

func _on_inimigo_saiu() -> void:
	_inimigos_vivos -= 1
	if _inimigos_vivos <= 0:
		if _player:
			_player.em_combate = false
		if _ondas_lancadas >= _ondas.size() and not _fase_encerrada:
			_fase_encerrada = true
			fase_completa.emit()
	elif not _aguardando_retomada and _player:
		_aguardando_retomada = true
		_player.em_combate = false
		await get_tree().create_timer(1.5).timeout
		if not is_inside_tree():
			return
		_aguardando_retomada = false

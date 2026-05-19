extends Node2D

var _fase_node: Node2D = null

var _fases: Array[PackedScene] = [
	preload("res://scenes/world/Fase1.tscn"),
	preload("res://scenes/world/Fase2.tscn"),
	preload("res://scenes/world/Fase3.tscn"),
	preload("res://scenes/world/Fase4.tscn"),
]

func _ready() -> void:
	GameManager.registrar_player($Player)
	GameManager.estado_mudou.connect(_on_estado_mudou)
	_on_estado_mudou(GameManager.estado_atual)

func _on_estado_mudou(estado: GameManager.Estado) -> void:
	match estado:
		GameManager.Estado.INICIO:
			_limpar_mundo()
		GameManager.Estado.JOGANDO:
			_carregar_fase()
		GameManager.Estado.BOSS:
			_spawnar_boss()

func _limpar_mundo() -> void:
	if _fase_node:
		_fase_node.queue_free()
		_fase_node = null
	for filho in get_children():
		if filho is Boss:
			filho.queue_free()
	$Player.global_position = Vector2(100.0, 300.0)
	$Player.velocity = Vector2.ZERO

func _carregar_fase() -> void:
	if _fase_node:
		_fase_node.queue_free()
	var idx: int = GameManager.fase_atual - 1
	_fase_node = _fases[idx].instantiate() as Node2D
	add_child(_fase_node)
	move_child(_fase_node, 0)
	_fase_node.get_node("EnemySpawner").fase_completa.connect(GameManager._on_fase_completa)
	$Player.reiniciar_posicao()

func _spawnar_boss() -> void:
	var boss: Boss = preload("res://scenes/enemies/Boss.tscn").instantiate() as Boss
	boss.global_position = Vector2($Player.global_position.x + 500.0, $Player.global_position.y)
	add_child(boss)

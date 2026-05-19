extends CanvasLayer

func _ready() -> void:
	GameManager.estado_mudou.connect(_on_estado_mudou)
	_atualizar_visibilidade(GameManager.estado_atual)

func _on_reiniciar_pressed() -> void:
	GameManager.resetar_estado()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_estado_mudou(novo_estado: GameManager.Estado) -> void:
	_atualizar_visibilidade(novo_estado)

func _atualizar_visibilidade(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.GAME_OVER

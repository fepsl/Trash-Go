extends CanvasLayer

func _ready() -> void:
	GameManager.estado_mudou.connect(_on_estado_mudou)
	_atualizar_visibilidade(GameManager.estado_atual)

func _on_jogar_pressed() -> void:
	GameManager.mudar_estado(GameManager.Estado.JOGANDO)

func _on_estado_mudou(novo_estado: GameManager.Estado) -> void:
	_atualizar_visibilidade(novo_estado)

func _atualizar_visibilidade(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.INICIO

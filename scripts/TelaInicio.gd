extends CanvasLayer

var _som_botao: AudioStreamPlayer

func _ready() -> void:
	_som_botao = AudioStreamPlayer.new()
	_som_botao.stream = preload("res://assets/sounds/bassattack.ogg")
	_som_botao.volume_db = -5.0
	add_child(_som_botao)
	GameManager.estado_mudou.connect(_on_estado_mudou)
	_atualizar_visibilidade(GameManager.estado_atual)

func _on_jogar_pressed() -> void:
	_som_botao.play()
	GameManager.mudar_estado(GameManager.Estado.JOGANDO)

func _on_estado_mudou(novo_estado: GameManager.Estado) -> void:
	_atualizar_visibilidade(novo_estado)

func _atualizar_visibilidade(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.INICIO

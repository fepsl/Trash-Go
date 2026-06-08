extends CanvasLayer

var _som_botao: AudioStreamPlayer

@onready var _label_materiais: Label = $VBoxContainer/LabelMateriais
@onready var _botao_vida: Button = $VBoxContainer/BotaoVida
@onready var _botao_dano: Button = $VBoxContainer/BotaoDano
@onready var _botao_recarga: Button = $VBoxContainer/BotaoRecarga
@onready var _botao_velocidade: Button = $VBoxContainer/BotaoVelocidade

func _ready() -> void:
	_som_botao = AudioStreamPlayer.new()
	_som_botao.stream = preload("res://assets/sounds/bassattack.ogg")
	_som_botao.volume_db = -5.0
	add_child(_som_botao)
	visible = false
	GameManager.estado_mudou.connect(_on_estado_mudou)

func _on_estado_mudou(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.UPGRADE
	if visible:
		_atualizar_botoes()

func _atualizar_botoes() -> void:
	_label_materiais.text = "Materiais: %d" % GameManager.materiais
	var custo_vida := GameManager.custo_upgrade(GameManager.CUSTO_BASE_VIDA, GameManager.nivel_upgrade_vida)
	var custo_dano := GameManager.custo_upgrade(GameManager.CUSTO_BASE_DANO, GameManager.nivel_upgrade_dano)
	var custo_recarga := GameManager.custo_upgrade(GameManager.CUSTO_BASE_RECARGA, GameManager.nivel_upgrade_recarga)
	var custo_velocidade := GameManager.custo_upgrade(GameManager.CUSTO_BASE_VELOCIDADE, GameManager.nivel_upgrade_velocidade)
	_botao_vida.text = "Mais Vida (%d mat)" % custo_vida
	_botao_vida.disabled = GameManager.materiais < custo_vida
	_botao_dano.text = "Mais Dano (%d mat)" % custo_dano
	_botao_dano.disabled = GameManager.materiais < custo_dano
	_botao_recarga.text = "Recarga (%d mat)" % custo_recarga
	_botao_recarga.disabled = GameManager.materiais < custo_recarga
	_botao_velocidade.text = "Velocidade (%d mat)" % custo_velocidade
	_botao_velocidade.disabled = GameManager.materiais < custo_velocidade

func _on_vida_pressed() -> void:
	var custo := GameManager.custo_upgrade(GameManager.CUSTO_BASE_VIDA, GameManager.nivel_upgrade_vida)
	if GameManager.materiais < custo:
		return
	_som_botao.play()
	GameManager.materiais -= custo
	GameManager.nivel_upgrade_vida += 1
	GameManager.vida_maxima += 25 + GameManager.num_loops * 15
	GameManager.vida_atual = GameManager.vida_maxima
	GameManager.vida_atualizada.emit(GameManager.vida_atual, GameManager.vida_maxima)
	_atualizar_botoes()

func _on_dano_pressed() -> void:
	var custo := GameManager.custo_upgrade(GameManager.CUSTO_BASE_DANO, GameManager.nivel_upgrade_dano)
	if GameManager.materiais < custo:
		return
	_som_botao.play()
	GameManager.materiais -= custo
	GameManager.nivel_upgrade_dano += 1
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.dano_ataque += 5 + GameManager.num_loops * 3
	_atualizar_botoes()

func _on_recarga_pressed() -> void:
	var custo := GameManager.custo_upgrade(GameManager.CUSTO_BASE_RECARGA, GameManager.nivel_upgrade_recarga)
	if GameManager.materiais < custo:
		return
	_som_botao.play()
	GameManager.materiais -= custo
	GameManager.nivel_upgrade_recarga += 1
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.reduzir_recarga_ataque(0.02 + GameManager.num_loops * 0.01)
	_atualizar_botoes()

func _on_velocidade_pressed() -> void:
	var custo := GameManager.custo_upgrade(GameManager.CUSTO_BASE_VELOCIDADE, GameManager.nivel_upgrade_velocidade)
	if GameManager.materiais < custo:
		return
	_som_botao.play()
	GameManager.materiais -= custo
	GameManager.nivel_upgrade_velocidade += 1
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.velocidade += 20.0 + GameManager.num_loops * 10.0
	_atualizar_botoes()

func _on_continuar_pressed() -> void:
	_som_botao.play()
	GameManager.mudar_estado(GameManager.Estado.JOGANDO)

extends CanvasLayer

const CUSTO_VIDA: int = 5
const CUSTO_DANO: int = 8
const CUSTO_RECARGA: int = 6
const CUSTO_VELOCIDADE: int = 7

@onready var _label_materiais: Label = $VBoxContainer/LabelMateriais
@onready var _botao_vida: Button = $VBoxContainer/BotaoVida
@onready var _botao_dano: Button = $VBoxContainer/BotaoDano
@onready var _botao_recarga: Button = $VBoxContainer/BotaoRecarga
@onready var _botao_velocidade: Button = $VBoxContainer/BotaoVelocidade

func _ready() -> void:
	visible = false
	GameManager.estado_mudou.connect(_on_estado_mudou)

func _on_estado_mudou(estado: GameManager.Estado) -> void:
	visible = estado == GameManager.Estado.UPGRADE
	if visible:
		_atualizar_botoes()

func _atualizar_botoes() -> void:
	_label_materiais.text = "Materiais: %d" % GameManager.materiais
	_botao_vida.disabled = GameManager.materiais < CUSTO_VIDA
	_botao_dano.disabled = GameManager.materiais < CUSTO_DANO
	_botao_recarga.disabled = GameManager.materiais < CUSTO_RECARGA
	_botao_velocidade.disabled = GameManager.materiais < CUSTO_VELOCIDADE

func _on_vida_pressed() -> void:
	if GameManager.materiais < CUSTO_VIDA:
		return
	GameManager.materiais -= CUSTO_VIDA
	GameManager.vida_maxima += 25
	GameManager.vida_atual = GameManager.vida_maxima
	GameManager.vida_atualizada.emit(GameManager.vida_atual, GameManager.vida_maxima)
	_atualizar_botoes()

func _on_dano_pressed() -> void:
	if GameManager.materiais < CUSTO_DANO:
		return
	GameManager.materiais -= CUSTO_DANO
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.dano_ataque += 5
	_atualizar_botoes()

func _on_recarga_pressed() -> void:
	if GameManager.materiais < CUSTO_RECARGA:
		return
	GameManager.materiais -= CUSTO_RECARGA
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.reduzir_recarga_ataque(0.02)
	_atualizar_botoes()

func _on_velocidade_pressed() -> void:
	if GameManager.materiais < CUSTO_VELOCIDADE:
		return
	GameManager.materiais -= CUSTO_VELOCIDADE
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.velocidade += 20.0
	_atualizar_botoes()

func _on_continuar_pressed() -> void:
	GameManager.mudar_estado(GameManager.Estado.JOGANDO)

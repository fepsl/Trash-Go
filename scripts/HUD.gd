class_name HUD
extends CanvasLayer

const NOMES_CURTOS: Dictionary = {
	"Escudo": "ESC",
	"Ataque em Área": "AÁR",
	"Projétil": "PRJ",
	"Velocidade+": "VEL",
	"Cura ao Matar": "CUR",
	"Ricochete": "RIC",
}

@export var textura_slot_ativo: Texture2D
@export var textura_slot_inativo: Texture2D

@onready var barra_vida: TextureProgressBar = $PainelVida/ConteudoVida/BarraVida
@onready var label_vida: Label = $PainelVida/ConteudoVida/LabelVida
@onready var label_materiais: Label = $PainelMateriais/ConteudoMateriais/LabelMateriais
@onready var notif_poder: Label = $NotifPoder
@onready var timer_notif: Timer = $TimerNotif
@onready var painel_poderes: HBoxContainer = $PainelPoderes

var slots_poder: Array[NinePatchRect] = []

func _ready() -> void:
	for i in range(6):
		slots_poder.append(painel_poderes.get_node("SlotPoder%d" % i) as NinePatchRect)

	GameManager.vida_atualizada.connect(_on_vida_atualizada)
	GameManager.material_coletado.connect(_on_material_coletado)
	GameManager.poder_concedido.connect(_on_poder_concedido)
	GameManager.estado_mudou.connect(_on_estado_mudou)
	timer_notif.timeout.connect(_on_timer_notif_timeout)

	barra_vida.max_value = GameManager.vida_maxima
	barra_vida.value = GameManager.vida_atual
	label_vida.text = "%d/%d" % [GameManager.vida_atual, GameManager.vida_maxima]
	label_materiais.text = "%d" % GameManager.materiais
	_atualizar_visibilidade(GameManager.estado_atual)

func _on_vida_atualizada(atual: int, vida_max: int) -> void:
	barra_vida.max_value = vida_max
	barra_vida.value = atual
	label_vida.text = "%d/%d" % [atual, vida_max]

func _on_material_coletado(_qtd: int) -> void:
	label_materiais.text = "%d" % GameManager.materiais

func _on_poder_concedido(poder: String) -> void:
	var idx := GameManager.poderes_ativos.size() - 1
	if idx >= 0 and idx < slots_poder.size():
		slots_poder[idx].texture = textura_slot_ativo
		var icone := slots_poder[idx].get_node("Icone") as Label
		icone.text = NOMES_CURTOS.get(poder, poder.substr(0, 3).to_upper())

	notif_poder.text = "Poder: %s" % poder
	notif_poder.visible = true
	timer_notif.start()

func _on_timer_notif_timeout() -> void:
	notif_poder.visible = false

func _on_estado_mudou(novo_estado: GameManager.Estado) -> void:
	_atualizar_visibilidade(novo_estado)

func _atualizar_visibilidade(estado: GameManager.Estado) -> void:
	var visivel := estado in [
		GameManager.Estado.JOGANDO,
		GameManager.Estado.BOSS,
		GameManager.Estado.UPGRADE,
	]
	visible = visivel

class_name HUD
extends CanvasLayer

const ICONES: Array[Texture2D] = [
	preload("res://assets/icons/abilities/escudo.svg"),
	preload("res://assets/icons/abilities/ataque_area.svg"),
	preload("res://assets/icons/abilities/projetil.svg"),
	preload("res://assets/icons/abilities/velocidade.svg"),
	preload("res://assets/icons/abilities/cura_ao_matar.svg"),
	preload("res://assets/icons/abilities/ricochete.svg"),
]
const DESCRICOES: Array[String] = [
	"Escudo · Bloqueia um golpe e recarrega em 5 segundos.",
	"Ataque em Área · Atinge os inimigos próximos.",
	"Projétil · Dispara ao atacar.",
	"Velocidade+ · Aumenta a velocidade de movimento em 50%.",
	"Cura ao Matar · Recupera vida ao derrotar inimigos.",
	"Ricochete · Amplia o alcance do ataque.",
]

var _tweens_slot: Dictionary = {}
var _tween_vida: Tween
var _tween_dano: Tween
var _tween_materiais: Tween
var _vida_anterior: int = 0

@export var textura_slot_ativo: Texture2D
@export var textura_slot_inativo: Texture2D

@onready var barra_vida: ProgressBar = $PainelVida/ConteudoVida/BarraVida
@onready var barra_dano: ProgressBar = $PainelVida/ConteudoVida/BarraDano
@onready var label_vida: Label = $PainelVida/ConteudoVida/LabelVida
@onready var label_materiais: Label = $PainelMateriais/ConteudoMateriais/LabelMateriais
@onready var notif_poder: Label = $NotifPoder
@onready var timer_notif: Timer = $TimerNotif
@onready var painel_poderes: HBoxContainer = $PainelPoderes

var slots_poder: Array[NinePatchRect] = []

func _ready() -> void:
	for i in range(6):
		slots_poder.append(painel_poderes.get_node("SlotPoder%d" % i) as NinePatchRect)
		slots_poder[i].get_node("Icone").texture = ICONES[i]
		slots_poder[i].tooltip_text = DESCRICOES[i]
	_atualizar_poderes()

	GameManager.vida_atualizada.connect(_on_vida_atualizada)
	GameManager.material_coletado.connect(_on_material_coletado)
	GameManager.poder_concedido.connect(_on_poder_concedido)
	GameManager.estado_mudou.connect(_on_estado_mudou)
	timer_notif.timeout.connect(_on_timer_notif_timeout)

	# Estilo local: a cor de vida não é compartilhada com outras instâncias da HUD.
	barra_vida.add_theme_stylebox_override("fill", barra_vida.get_theme_stylebox("fill").duplicate())
	_sincronizar_vida()
	label_materiais.text = "%d" % GameManager.materiais
	_atualizar_visibilidade(GameManager.estado_atual)

func _on_vida_atualizada(atual: int, vida_max: int) -> void:
	_parar_animacoes_vida()
	var vida_exibida := clampi(atual, 0, vida_max)
	barra_vida.max_value = vida_max
	barra_dano.max_value = vida_max
	label_vida.text = "%d / %d" % [vida_exibida, vida_max]
	_atualizar_cor_vida(vida_exibida, vida_max)
	_tween_vida = create_tween()
	_tween_vida.tween_property(barra_vida, "value", float(vida_exibida), 0.16)
	if vida_exibida < _vida_anterior:
		_tween_dano = create_tween()
		_tween_dano.tween_interval(0.25)
		_tween_dano.tween_property(barra_dano, "value", float(vida_exibida), 0.35)
	else:
		barra_dano.value = vida_exibida
	_vida_anterior = vida_exibida

func _parar_animacoes_vida() -> void:
	if _tween_vida and _tween_vida.is_valid():
		_tween_vida.kill()
	if _tween_dano and _tween_dano.is_valid():
		_tween_dano.kill()

func _sincronizar_vida() -> void:
	_parar_animacoes_vida()
	var atual := clampi(GameManager.vida_atual, 0, GameManager.vida_maxima)
	barra_vida.max_value = GameManager.vida_maxima
	barra_dano.max_value = GameManager.vida_maxima
	barra_vida.value = atual
	barra_dano.value = atual
	label_vida.text = "%d / %d" % [atual, GameManager.vida_maxima]
	_vida_anterior = atual
	_atualizar_cor_vida(atual, GameManager.vida_maxima)

func _atualizar_cor_vida(atual: int, vida_max: int) -> void:
	var proporcao := float(atual) / maxf(1.0, float(vida_max))
	var cor := Color("87de7a")
	if proporcao <= 0.25:
		cor = Color("ee7071")
	elif proporcao <= 0.5:
		cor = Color("efc56d")
	var estilo := barra_vida.get_theme_stylebox("fill") as StyleBoxFlat
	estilo.bg_color = cor
	estilo.border_color = cor.lightened(0.2)

func _on_material_coletado(_qtd: int) -> void:
	label_materiais.text = "%d" % GameManager.materiais
	if _tween_materiais and _tween_materiais.is_valid():
		_tween_materiais.kill()
	label_materiais.modulate = Color(1.3, 1.2, 0.8)
	_tween_materiais = create_tween()
	_tween_materiais.tween_property(label_materiais, "modulate", Color.WHITE, 0.3)

func _on_poder_concedido(poder: String) -> void:
	_atualizar_poderes()
	# Identificar pelo poder evita trocar o último ícone em recompensas repetidas.
	for idx in range(slots_poder.size()):
		if GameManager._nome_poder(idx) != poder:
			continue
		var icone := slots_poder[idx].get_node("Icone") as TextureRect
		if _tweens_slot.has(idx) and _tweens_slot[idx].is_valid():
			_tweens_slot[idx].kill()
		icone.pivot_offset = icone.size * 0.5
		icone.scale = Vector2(0.82, 0.82)
		var tween := create_tween()
		_tweens_slot[idx] = tween
		tween.tween_property(icone, "scale", Vector2(1.1, 1.1), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(icone, "scale", Vector2.ONE, 0.15)

	notif_poder.text = "Poder: %s" % poder
	notif_poder.visible = true
	timer_notif.start()

func _atualizar_poderes() -> void:
	for i in range(slots_poder.size()):
		var ativo := i in GameManager.poderes_ativos
		var icone := slots_poder[i].get_node("Icone") as TextureRect
		slots_poder[i].texture = textura_slot_ativo if ativo else textura_slot_inativo
		icone.modulate = Color.WHITE if ativo else Color(0.42, 0.46, 0.5, 0.5)
		slots_poder[i].tooltip_text = DESCRICOES[i] + ("" if ativo else "\nDerrote chefes para desbloquear.")
		(slots_poder[i].get_node("Estado") as Label).text = "ATIVO" if ativo else "—"
		(slots_poder[i].get_node("Estado") as Label).modulate = Color(0.65, 1.0, 0.78) if ativo else Color(0.6, 0.64, 0.68)

func _on_timer_notif_timeout() -> void:
	notif_poder.visible = false

func _on_estado_mudou(novo_estado: GameManager.Estado) -> void:
	_atualizar_poderes()
	# Compras de melhorias alteram materiais sem emitir material_coletado.
	label_materiais.text = "%d" % GameManager.materiais
	if novo_estado == GameManager.Estado.INICIO:
		_sincronizar_vida()
		notif_poder.visible = false
		timer_notif.stop()
	_atualizar_visibilidade(novo_estado)

func _atualizar_visibilidade(estado: GameManager.Estado) -> void:
	var visivel := estado in [
		GameManager.Estado.JOGANDO,
		GameManager.Estado.BOSS,
		GameManager.Estado.UPGRADE,
	]
	visible = visivel

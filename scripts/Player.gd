class_name Player
extends CharacterBody2D

const VELOCIDADE_BASE: float = 150.0
const IMPULSO_DESVIO: float = -400.0
const GRAVIDADE: float = 980.0

@export var velocidade: float = VELOCIDADE_BASE
@export var dano_ataque: int = 10

var em_combate: bool = false
var _hitbox: Area2D
var _timer_ataque: Timer
var _escudo_carregado: bool = false
var _timer_recarga_escudo: Timer
var _sprite: AnimatedSprite2D
var _tomando_dano: bool = false
var _atacando: bool = false
var _morrendo: bool = false

signal player_morreu

func _ready() -> void:
	add_to_group("player")
	_sprite = $AnimatedSprite2D
	_sprite.animation_finished.connect(_on_animacao_ataque_terminada)
	_hitbox = $HitBox
	_hitbox.add_to_group("hitbox_player")
	_hitbox.area_entered.connect(_on_hitbox_area_entered)
	_timer_ataque = $TimerAtaque
	_timer_ataque.timeout.connect(_on_timer_ataque_timeout)
	GameManager.poder_concedido.connect(_on_poder_concedido)
	_timer_recarga_escudo = Timer.new()
	_timer_recarga_escudo.one_shot = true
	_timer_recarga_escudo.wait_time = 5.0
	_timer_recarga_escudo.timeout.connect(_recarregar_escudo)
	add_child(_timer_recarga_escudo)

func _physics_process(delta: float) -> void:
	var estados_ativos := [GameManager.Estado.JOGANDO, GameManager.Estado.BOSS]
	if GameManager.estado_atual not in estados_ativos or _morrendo:
		return

	if em_combate:
		velocity.x = 0.0
	else:
		var vel_atual: float = velocidade
		if GameManager.Poder.VELOCIDADE in GameManager.poderes_ativos:
			vel_atual *= 1.5
		velocity.x = vel_atual

	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = IMPULSO_DESVIO

	if Input.is_action_just_pressed("atacar") and _timer_ataque.is_stopped() and not _atacando:
		_ativar_hitbox()

	move_and_slide()
	_atualizar_animacao()

func receber_dano(valor: int) -> void:
	var estados_ativos := [GameManager.Estado.JOGANDO, GameManager.Estado.BOSS]
	if GameManager.estado_atual not in estados_ativos or _morrendo:
		return
	if GameManager.Poder.ESCUDO in GameManager.poderes_ativos and _escudo_carregado:
		_escudo_carregado = false
		_timer_recarga_escudo.start()
		return
	GameManager.vida_atual -= valor
	GameManager.vida_atualizada.emit(GameManager.vida_atual, GameManager.vida_maxima)
	if GameManager.vida_atual <= 0:
		_morrendo = true
		_sprite.play("morte")
	else:
		_flash_hit()

func reiniciar_posicao() -> void:
	global_position = Vector2(100.0, 300.0)
	velocity = Vector2.ZERO
	_morrendo = false
	em_combate = false

func reduzir_recarga_ataque(valor: float) -> void:
	_timer_ataque.wait_time = max(0.3, _timer_ataque.wait_time - valor)

func _flash_hit() -> void:
	if _tomando_dano:
		return
	_tomando_dano = true
	modulate = Color(1.5, 0.5, 0.5, 1.0)
	await get_tree().create_timer(0.2).timeout
	if is_inside_tree():
		modulate = Color.WHITE
	_tomando_dano = false

func _atualizar_animacao() -> void:
	if _atacando or _morrendo:
		return
	var estados_ativos := [GameManager.Estado.JOGANDO, GameManager.Estado.BOSS]
	if GameManager.estado_atual in estados_ativos and not em_combate:
		_sprite.play("run")
	else:
		_sprite.play("idle")

func _ativar_hitbox() -> void:
	_atacando = true
	_sprite.play("attack")
	if GameManager.Poder.RICOCHETE in GameManager.poderes_ativos:
		_hitbox.scale = Vector2(1.8, 1.8)
	if GameManager.Poder.ATAQUE_AREA in GameManager.poderes_ativos:
		_aplicar_dano_area()
	if GameManager.Poder.PROJETIL in GameManager.poderes_ativos:
		_spawnar_projetil()
	_hitbox.monitoring = true
	_timer_ataque.start()

func _on_animacao_ataque_terminada() -> void:
	if _sprite.animation == &"attack":
		_atacando = false
	elif _sprite.animation == &"morte":
		player_morreu.emit()

func _on_timer_ataque_timeout() -> void:
	_hitbox.monitoring = false
	_hitbox.scale = Vector2(1.0, 1.0)

func _on_hitbox_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Inimigo:
		(parent as Inimigo).receber_dano(dano_ataque)
	elif parent is Boss:
		(parent as Boss).receber_dano(dano_ataque)

func _on_poder_concedido(_nome: String) -> void:
	if GameManager.Poder.ESCUDO in GameManager.poderes_ativos:
		_escudo_carregado = true

func _recarregar_escudo() -> void:
	if GameManager.Poder.ESCUDO in GameManager.poderes_ativos:
		_escudo_carregado = true

func _aplicar_dano_area() -> void:
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		if global_position.distance_to(inimigo.global_position) <= 150.0:
			if inimigo is Inimigo:
				(inimigo as Inimigo).receber_dano(dano_ataque)
			elif inimigo is Boss:
				(inimigo as Boss).receber_dano(dano_ataque)

func _spawnar_projetil() -> void:
	var proj: Node2D = preload("res://scenes/Projetil.tscn").instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position + Vector2(50.0, 0.0)

class_name Player
extends CharacterBody2D

const VELOCIDADE_BASE: float = 150.0
const GRAVIDADE: float = 980.0
const ESCALA_SPRITE: float = 0.94
const ESCALA_CORRIDA: float = 0.56
const OFFSET_SPRITE := Vector2(-160.0, -264.0)
const OFFSET_CORRIDA := Vector2(-320.0, -464.0)

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
var _som_ataque: AudioStreamPlayer
var _som_dano: AudioStreamPlayer
var _reacao_dano: float = 0.0
var _tween_dano: Tween
var _tween_morte: Tween
var _escala_visual: float = ESCALA_SPRITE

@onready var _efeitos = $Efeitos

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
	_som_ataque = AudioStreamPlayer.new()
	_som_ataque.stream = preload("res://assets/sounds/hit1.ogg")
	_som_ataque.volume_db = -5.0
	add_child(_som_ataque)
	_som_dano = AudioStreamPlayer.new()
	_som_dano.stream = preload("res://assets/sounds/fallsmall.ogg")
	_som_dano.volume_db = -5.0
	add_child(_som_dano)

func _process(delta: float) -> void:
	var jogando := GameManager.estado_atual in [GameManager.Estado.JOGANDO, GameManager.Estado.BOSS]
	_efeitos.correndo = jogando and not _morrendo and is_on_floor() and absf(velocity.x) > 1.0
	_efeitos.velocidade_ativa = GameManager.Poder.VELOCIDADE in GameManager.poderes_ativos
	_efeitos.escudo_ativo = jogando and not _morrendo and _escudo_carregado and GameManager.Poder.ESCUDO in GameManager.poderes_ativos
	_efeitos.visible = jogando or _morrendo
	_reacao_dano = move_toward(_reacao_dano, 0.0, delta * 5.0)
	if _morrendo:
		return
	# O pivô fica nos pés; a reação não desloca a base nem a colisão.
	_sprite.scale = Vector2(_escala_visual * (1.0 - _reacao_dano * 0.075), _escala_visual * (1.0 + _reacao_dano * 0.05))
	_sprite.position.x = -_reacao_dano * 6.0
	if not jogando:
		_tocar_animacao(&"idle")

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

	if Input.is_action_just_pressed("atacar") and _timer_ataque.is_stopped() and not _atacando and not _ponteiro_sobre_interface():
		_ativar_hitbox()

	move_and_slide()
	_atualizar_animacao()

func _ponteiro_sobre_interface() -> bool:
	for controle in get_tree().get_nodes_in_group("bloqueia_ataque"):
		if controle is Control and controle.is_visible_in_tree() and controle.get_global_rect().has_point(controle.get_global_mouse_position()):
			return true
	return false

func receber_dano(valor: int) -> void:
	var estados_ativos := [GameManager.Estado.JOGANDO, GameManager.Estado.BOSS]
	if GameManager.estado_atual not in estados_ativos or _morrendo:
		return
	if GameManager.Poder.ESCUDO in GameManager.poderes_ativos and _escudo_carregado:
		_escudo_carregado = false
		_efeitos.bloquear()
		_timer_recarga_escudo.start()
		return
	_som_dano.play()
	_flash_hit()
	GameManager.vida_atual -= valor
	GameManager.vida_atualizada.emit(GameManager.vida_atual, GameManager.vida_maxima)
	if GameManager.vida_atual <= 0:
		_morrendo = true
		_atacando = false
		_hitbox.set_deferred("monitoring", false)
		_timer_ataque.stop()
		_tocar_animacao(&"morte")
		_tween_morte = create_tween().set_parallel(true)
		_tween_morte.tween_property(_sprite, "modulate:a", 0.0, 0.25).set_delay(0.6)
		_tween_morte.chain().tween_callback(func(): player_morreu.emit())

func reiniciar_posicao() -> void:
	if _tween_morte and _tween_morte.is_valid():
		_tween_morte.kill()
	if _tween_dano and _tween_dano.is_valid():
		_tween_dano.kill()
	global_position = Vector2(100.0, 300.0)
	velocity = Vector2.ZERO
	_morrendo = false
	_atacando = false
	_tomando_dano = false
	_reacao_dano = 0.0
	_sprite.rotation = 0.0
	_sprite.position = Vector2(0.0, 94.0)
	_sprite.scale = Vector2.ONE * ESCALA_SPRITE
	_sprite.modulate = Color.WHITE
	_tocar_animacao(&"idle")
	_timer_ataque.stop()
	_hitbox.set_deferred("monitoring", false)
	_hitbox.scale = Vector2.ONE
	_efeitos.reiniciar()
	_timer_recarga_escudo.stop()
	_escudo_carregado = GameManager.Poder.ESCUDO in GameManager.poderes_ativos
	em_combate = false

func reduzir_recarga_ataque(valor: float) -> void:
	_timer_ataque.wait_time = max(0.3, _timer_ataque.wait_time - valor)

func _flash_hit() -> void:
	if _tomando_dano:
		return
	_tomando_dano = true
	_reacao_dano = 1.0
	_sprite.modulate = Color(1.0, 0.5, 0.4)
	_tween_dano = create_tween()
	_tween_dano.tween_property(_sprite, "modulate", Color.WHITE, 0.22)
	_tween_dano.tween_callback(func(): _tomando_dano = false)

func _atualizar_animacao() -> void:
	if _atacando or _morrendo:
		return
	var estados_ativos := [GameManager.Estado.JOGANDO, GameManager.Estado.BOSS]
	if GameManager.estado_atual in estados_ativos and not em_combate:
		_tocar_animacao(&"run", clampf(absf(velocity.x) / VELOCIDADE_BASE, 0.8, 2.0))
	else:
		_tocar_animacao(&"idle")

func _tocar_animacao(nome: StringName, ritmo: float = 1.0) -> void:
	# A corrida usa um atlas maior; manter altura e apoio compatíveis com as demais poses.
	_escala_visual = ESCALA_CORRIDA if nome == &"run" else ESCALA_SPRITE
	_sprite.offset = OFFSET_CORRIDA if nome == &"run" else OFFSET_SPRITE
	_sprite.scale = Vector2.ONE * _escala_visual
	_sprite.speed_scale = ritmo
	_sprite.play(nome)

func _ativar_hitbox() -> void:
	_atacando = true
	_tocar_animacao(&"attack")
	_som_ataque.play()
	_efeitos.atacar(GameManager.Poder.ATAQUE_AREA in GameManager.poderes_ativos, 1.35 if GameManager.Poder.RICOCHETE in GameManager.poderes_ativos else 1.0)
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
		_atualizar_animacao()

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

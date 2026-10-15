class_name Boss
extends CharacterBody2D

const VIDA_BASE: int = 220
const DANO_CONTATO: int = 12
const DANO_AREA: int = 18
const GRAVIDADE: float = 980.0
const MARGEM_ATAQUE: float = 200.0

@export var velocidade_normal: float = 70.0
@export var velocidade_agressiva: float = 140.0
@export var multiplicador_vida: float = 1.0

var vida_atual: int
var _player: Player
var _fase_agressiva: bool = false
var _em_range: bool = false
var _timer_ataque: Timer
var _hitbox_ataque: Area2D
var _atacando: bool = false
var _morrendo: bool = false
var _tween_hit: Tween

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

signal boss_derrotado

func _ready() -> void:
	vida_atual = int(VIDA_BASE * multiplicador_vida * (1.0 + GameManager.num_loops * 0.35))
	_sprite.animation_finished.connect(_on_animacao_terminada)
	_player = get_tree().get_first_node_in_group("player") as Player
	add_to_group("inimigos")
	boss_derrotado.connect(GameManager._on_boss_derrotado)
	_timer_ataque = $TimerAtaque
	_timer_ataque.timeout.connect(_on_timer_ataque_timeout)
	_hitbox_ataque = $HitBoxAtaque
	_hitbox_ataque.monitoring = false
	_hitbox_ataque.area_entered.connect(_on_hitbox_ataque_area_entered)
	_timer_ataque.start()

func _physics_process(delta: float) -> void:
	if _morrendo:
		return
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	if _player:
		var dist: float = _player.global_position.x - global_position.x
		if abs(dist) > MARGEM_ATAQUE:
			_em_range = false
			var vel: float = velocidade_agressiva if _fase_agressiva else velocidade_normal
			velocity.x = sign(dist) * vel
			_sprite.flip_h = dist > 0
			if not _atacando:
				_sprite.play("move")
		else:
			_em_range = true
			velocity.x = 0.0
			_sprite.flip_h = dist > 0
			if not _atacando:
				_sprite.play("idle")
			if not _player.em_combate:
				_player.em_combate = true
	else:
		velocity.x = 0.0
		if not _atacando:
			_sprite.play("idle")

	move_and_slide()

func receber_dano(valor: int) -> void:
	if _morrendo:
		return
	vida_atual -= valor
	if not _fase_agressiva and vida_atual <= int(VIDA_BASE * multiplicador_vida) / 2.0:
		_ativar_fase_agressiva()
	if vida_atual <= 0:
		_morrer()
	else:
		_flash_hit()

func _flash_hit() -> void:
	if _tween_hit and _tween_hit.is_valid():
		_tween_hit.kill()
	_sprite.modulate = Color(1.5, 0.65, 0.5)
	_tween_hit = create_tween()
	_tween_hit.tween_property(_sprite, "modulate", Color.WHITE, 0.16)

func _on_animacao_terminada() -> void:
	if _sprite.animation == &"morte":
		boss_derrotado.emit()
		queue_free()
	elif _sprite.animation == &"attack":
		_atacando = false
		_sprite.play("idle")

func _ativar_fase_agressiva() -> void:
	_fase_agressiva = true
	_timer_ataque.wait_time = 1.5
	_sprite.speed_scale = 1.2
	_sprite.self_modulate = Color(1.0, 0.82, 0.7)

func _morrer() -> void:
	_morrendo = true
	_atacando = false
	velocity = Vector2.ZERO
	_timer_ataque.stop()
	_hitbox_ataque.set_deferred("monitoring", false)
	$HurtBox.set_deferred("monitorable", false)
	remove_from_group("inimigos")
	if _tween_hit and _tween_hit.is_valid():
		_tween_hit.kill()
	_sprite.modulate = Color.WHITE
	_sprite.self_modulate = Color.WHITE
	_sprite.speed_scale = 1.0
	_sprite.play("morte")

func _on_timer_ataque_timeout() -> void:
	if _morrendo:
		return
	if _em_range and _player and is_instance_valid(_player):
		_atacando = true
		_sprite.play("attack")
		_player.receber_dano(DANO_CONTATO + GameManager.num_loops * 6)
	if _fase_agressiva:
		_atacar_area()
	_timer_ataque.start()

func _atacar_area() -> void:
	_atacando = true
	_sprite.play("attack")
	_hitbox_ataque.monitoring = true
	await get_tree().create_timer(0.3).timeout
	if is_inside_tree():
		_hitbox_ataque.monitoring = false

func _on_hitbox_ataque_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent is Player:
		(parent as Player).receber_dano(DANO_AREA + GameManager.num_loops * 9)

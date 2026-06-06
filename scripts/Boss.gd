class_name Boss
extends CharacterBody2D

const VIDA_BASE: int = 300
const DANO_CONTATO: int = 20
const DANO_AREA: int = 30
const GRAVIDADE: float = 980.0
const MARGEM_ATAQUE: float = 200.0
const _IDLE_FRAME_H: float = 216.0
const _MOVE_FRAME_H: float = 299.0

@export var velocidade_normal: float = 70.0
@export var velocidade_agressiva: float = 140.0
@export var multiplicador_vida: float = 1.0

var vida_atual: int
var _player: Player
var _fase_agressiva: bool = false
var _em_range: bool = false
var _timer_ataque: Timer
var _hitbox_ataque: Area2D
var _sprite_y_base: float

signal boss_derrotado

func _ready() -> void:
	vida_atual = int(VIDA_BASE * multiplicador_vida)
	_sprite_y_base = $AnimatedSprite2D.position.y
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
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	if _player:
		var dist: float = _player.global_position.x - global_position.x
		if abs(dist) > MARGEM_ATAQUE:
			_em_range = false
			var vel: float = velocidade_agressiva if _fase_agressiva else velocidade_normal
			velocity.x = sign(dist) * vel
			$AnimatedSprite2D.flip_h = dist > 0
			$AnimatedSprite2D.position.y = _sprite_y_base + (_IDLE_FRAME_H - _MOVE_FRAME_H) / 2.0 * $AnimatedSprite2D.scale.y
			$AnimatedSprite2D.play("move")
		else:
			_em_range = true
			velocity.x = 0.0
			$AnimatedSprite2D.flip_h = dist > 0
			$AnimatedSprite2D.position.y = _sprite_y_base
			$AnimatedSprite2D.play("idle")
			if not _player.em_combate:
				_player.em_combate = true
	else:
		velocity.x = 0.0
		$AnimatedSprite2D.position.y = _sprite_y_base
		$AnimatedSprite2D.play("idle")

	move_and_slide()

func receber_dano(valor: int) -> void:
	vida_atual -= valor
	if not _fase_agressiva and vida_atual <= int(VIDA_BASE * multiplicador_vida) / 2.0:
		_ativar_fase_agressiva()
	if vida_atual <= 0:
		_morrer()
	else:
		_flash_hit()

func _flash_hit() -> void:
	modulate = Color(1.5, 0.5, 0.5, 1.0)
	await get_tree().create_timer(0.12).timeout
	if is_inside_tree():
		modulate = Color.WHITE

func _ativar_fase_agressiva() -> void:
	_fase_agressiva = true
	_timer_ataque.wait_time = 1.5

func _morrer() -> void:
	boss_derrotado.emit()
	call_deferred("queue_free")

func _on_timer_ataque_timeout() -> void:
	if _em_range and _player and is_instance_valid(_player):
		_player.receber_dano(DANO_CONTATO)
	if _fase_agressiva:
		_atacar_area()
	_timer_ataque.start()

func _atacar_area() -> void:
	_hitbox_ataque.monitoring = true
	await get_tree().create_timer(0.3).timeout
	if is_inside_tree():
		_hitbox_ataque.monitoring = false

func _on_hitbox_ataque_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent is Player:
		(parent as Player).receber_dano(DANO_AREA)

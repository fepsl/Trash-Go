class_name Inimigo
extends CharacterBody2D

const DANO_BASE: int = 7
const GRAVIDADE: float = 980.0
const _REDUCAO_RECARGA: float = 0.04
const _RECARGA_MINIMA: float = 0.3

@export var margem_ataque: float = 70.0

@export var velocidade: float = 80.0
@export var vida_base: int = 30
@export var material_drop: int = 1

var vida_atual: int
var _chegou_ao_slot: bool = false
var _timer_ataque: Timer
var _atacando: bool = false
var _morrendo: bool = false
var _tween_hit: Tween

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

signal inimigo_morreu(material_drop: int)

var _player: Player

func _ready() -> void:
	vida_atual = vida_base
	_sprite.animation_finished.connect(_on_animacao_terminada)
	add_to_group("inimigos")
	inimigo_morreu.connect(GameManager._on_inimigo_morreu)
	_player = get_tree().get_first_node_in_group("player") as Player
	_timer_ataque = Timer.new()
	_timer_ataque.wait_time = max(0.4, 1.5 - GameManager.num_loops * 0.25)
	_timer_ataque.timeout.connect(_atacar_player)
	add_child(_timer_ataque)

func _physics_process(delta: float) -> void:
	if _morrendo:
		return
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	if _player:
		var dist: float = _player.global_position.x - global_position.x
		if abs(dist) > margem_ataque:
			_chegou_ao_slot = false
			_timer_ataque.stop()
			velocity.x = sign(dist) * velocidade
			_sprite.flip_h = dist > 0
			if not _atacando:
				_sprite.play("move")
		else:
			velocity.x = 0.0
			_sprite.flip_h = dist > 0
			if not _atacando:
				_sprite.play("idle")
			_player.em_combate = true
			if not _chegou_ao_slot:
				_chegou_ao_slot = true
				_timer_ataque.start()
	else:
		velocity.x = 0.0
		if not _atacando:
			_sprite.play("idle")

	_separar_de_outros_inimigos()
	move_and_slide()

func receber_dano(valor: int) -> void:
	if _morrendo:
		return
	vida_atual -= valor
	if vida_atual <= 0:
		_morrer()
	else:
		_flash_hit()

func _morrer() -> void:
	_morrendo = true
	_atacando = false
	velocity = Vector2.ZERO
	_timer_ataque.stop()
	remove_from_group("inimigos")
	$HurtBox.set_deferred("monitorable", false)
	if _tween_hit and _tween_hit.is_valid():
		_tween_hit.kill()
	_sprite.modulate = Color.WHITE
	_sprite.play("morte")
	inimigo_morreu.emit(material_drop)

func _flash_hit() -> void:
	if _tween_hit and _tween_hit.is_valid():
		_tween_hit.kill()
	_sprite.modulate = Color(1.4, 0.65, 0.55)
	_tween_hit = create_tween()
	_tween_hit.tween_property(_sprite, "modulate", Color.WHITE, 0.16)

func _on_animacao_terminada() -> void:
	if _sprite.animation == &"morte":
		queue_free()
	elif _sprite.animation == &"attack":
		_atacando = false
		_sprite.play("idle")

func _atacar_player() -> void:
	if _morrendo:
		return
	if _player and is_instance_valid(_player):
		_atacando = true
		_sprite.play("attack")
		_player.receber_dano(DANO_BASE + GameManager.num_loops * 7)
	_timer_ataque.wait_time = max(_RECARGA_MINIMA, _timer_ataque.wait_time - _REDUCAO_RECARGA)

func _separar_de_outros_inimigos() -> void:
	if not _player or abs(_player.global_position.x - global_position.x) <= margem_ataque:
		return
	for outro in get_tree().get_nodes_in_group("inimigos"):
		if outro == self:
			continue
		var dx: float = global_position.x - outro.global_position.x
		if abs(dx) < 100.0 and abs(global_position.y - outro.global_position.y) < 30.0:
			velocity.x += signf(dx) * velocidade


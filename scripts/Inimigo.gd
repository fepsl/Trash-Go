class_name Inimigo
extends CharacterBody2D

const DANO_BASE: int = 7
const GRAVIDADE: float = 980.0

@export var margem_ataque: float = 70.0
const _IDLE_FRAME_H: float = 216.0
const _MOVE_FRAME_H: float = 299.0

@export var velocidade: float = 80.0
@export var vida_base: int = 30
@export var material_drop: int = 1
@export var slot_offset: float = 100.0  # offset de spawn; não afeta mais a distância de parada

var vida_atual: int
var _chegou_ao_slot: bool = false
var _timer_ataque: Timer
var _sprite_y_base: float

signal inimigo_morreu(material_drop: int)

var _player: Player

func _ready() -> void:
	vida_atual = vida_base
	_sprite_y_base = $AnimatedSprite2D.position.y
	add_to_group("inimigos")
	inimigo_morreu.connect(GameManager._on_inimigo_morreu)
	_player = get_tree().get_first_node_in_group("player") as Player
	_timer_ataque = Timer.new()
	_timer_ataque.wait_time = max(0.4, 1.5 - GameManager.num_loops * 0.25)
	_timer_ataque.timeout.connect(_atacar_player)
	add_child(_timer_ataque)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	if _player:
		var dist: float = _player.global_position.x - global_position.x
		if abs(dist) > margem_ataque:
			_chegou_ao_slot = false
			_timer_ataque.stop()
			velocity.x = sign(dist) * velocidade
			$AnimatedSprite2D.flip_h = dist > 0
			$AnimatedSprite2D.position.y = _sprite_y_base + (_IDLE_FRAME_H - _MOVE_FRAME_H) / 2.0 * $AnimatedSprite2D.scale.y
			$AnimatedSprite2D.play("move")
		else:
			velocity.x = 0.0
			$AnimatedSprite2D.flip_h = dist > 0
			$AnimatedSprite2D.position.y = _sprite_y_base
			$AnimatedSprite2D.play("idle")
			_player.em_combate = true
			if not _chegou_ao_slot:
				_chegou_ao_slot = true
				_timer_ataque.start()
	else:
		velocity.x = 0.0
		$AnimatedSprite2D.position.y = _sprite_y_base
		$AnimatedSprite2D.play("idle")

	_separar_de_outros_inimigos()
	move_and_slide()

func receber_dano(valor: int) -> void:
	vida_atual -= valor
	if vida_atual <= 0:
		_morrer()
	else:
		_flash_hit()

func _morrer() -> void:
	_timer_ataque.stop()
	var efeito := preload("res://scenes/EfeitoMorte.tscn").instantiate() as AnimatedSprite2D
	get_parent().add_child(efeito)
	efeito.global_position = global_position
	inimigo_morreu.emit(material_drop)
	call_deferred("queue_free")

func _flash_hit() -> void:
	var cor_original := modulate
	modulate = Color.RED
	await get_tree().create_timer(0.12).timeout
	if is_inside_tree():
		modulate = cor_original

func _atacar_player() -> void:
	if _player and is_instance_valid(_player):
		_player.receber_dano(DANO_BASE + GameManager.num_loops * 7)

func _separar_de_outros_inimigos() -> void:
	if not _player or abs(_player.global_position.x - global_position.x) <= margem_ataque:
		return
	for outro in get_tree().get_nodes_in_group("inimigos"):
		if outro == self:
			continue
		var dx: float = global_position.x - outro.global_position.x
		if abs(dx) < 100.0 and abs(global_position.y - outro.global_position.y) < 30.0:
			velocity.x += signf(dx) * velocidade


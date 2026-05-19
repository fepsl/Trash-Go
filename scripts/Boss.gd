class_name Boss
extends CharacterBody2D

const VIDA_BASE: int = 300
const DANO_CONTATO: int = 20
const DANO_AREA: int = 30
const GRAVIDADE: float = 980.0

@export var velocidade_normal: float = 70.0
@export var velocidade_agressiva: float = 140.0

var vida_atual: int
var _player: Player
var _fase_agressiva: bool = false
var _timer_ataque: Timer
var _hitbox_ataque: Area2D

signal boss_derrotado

func _ready() -> void:
	vida_atual = VIDA_BASE
	_player = get_tree().get_first_node_in_group("player") as Player
	add_to_group("inimigos")
	boss_derrotado.connect(GameManager._on_boss_derrotado)
	$HurtBox.area_entered.connect(_on_hurtbox_area_entered)
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
		var direcao: float = sign(_player.global_position.x - global_position.x)
		var vel: float = velocidade_agressiva if _fase_agressiva else velocidade_normal
		velocity.x = direcao * vel
		$AnimatedSprite2D.flip_h = direcao < 0
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()

func receber_dano(valor: int) -> void:
	vida_atual -= valor
	if not _fase_agressiva and vida_atual <= VIDA_BASE / 2.0:
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
	if _fase_agressiva:
		_atacar_area()
	_timer_ataque.start()

func _atacar_area() -> void:
	_hitbox_ataque.monitoring = true
	await get_tree().create_timer(0.3).timeout
	if is_inside_tree():
		_hitbox_ataque.monitoring = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox_player") and _player:
		receber_dano(_player.dano_ataque)

func _on_hitbox_ataque_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent is Player:
		(parent as Player).receber_dano(DANO_AREA)

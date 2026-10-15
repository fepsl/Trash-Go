extends Area2D

const VELOCIDADE: float = 400.0
const DANO: int = 10

var _atingiu: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _timer_vida: Timer = $TimerVida

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	_sprite.animation_finished.connect(_on_animacao_terminada)
	_timer_vida.timeout.connect(queue_free)
	_timer_vida.start()
	_sprite.play("voo")

func _physics_process(delta: float) -> void:
	if not _atingiu:
		position.x += VELOCIDADE * delta

func _on_body_entered(body: Node2D) -> void:
	if _atingiu:
		return
	if body is Inimigo:
		_impactar()
		(body as Inimigo).receber_dano(DANO)
	elif body is Boss:
		_impactar()
		(body as Boss).receber_dano(DANO)
	elif body is StaticBody2D:
		_impactar()

func _impactar() -> void:
	_atingiu = true
	_timer_vida.stop()
	set_deferred("monitoring", false)
	_sprite.play("impacto")
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.0, 0.22)

func _on_animacao_terminada() -> void:
	if _sprite.animation == &"impacto":
		queue_free()

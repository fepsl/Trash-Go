extends Area2D

const VELOCIDADE: float = 400.0
const DANO: int = 10

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(2.5).timeout.connect(queue_free)

func _process(delta: float) -> void:
	position.x += VELOCIDADE * delta

func _on_body_entered(body: Node2D) -> void:
	if body is Inimigo:
		(body as Inimigo).receber_dano(DANO)
		call_deferred("queue_free")
	elif body is Boss:
		(body as Boss).receber_dano(DANO)
		call_deferred("queue_free")
	elif body is StaticBody2D:
		call_deferred("queue_free")

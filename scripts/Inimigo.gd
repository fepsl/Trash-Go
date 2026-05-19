class_name Inimigo
extends CharacterBody2D

const DANO_BASE: int = 10
const GRAVIDADE: float = 980.0

@export var velocidade: float = 80.0
@export var vida_base: int = 30
@export var material_drop: int = 1

var vida_atual: int

signal inimigo_morreu(material_drop: int)

var _player: Player

func _ready() -> void:
	vida_atual = vida_base
	add_to_group("inimigos")
	inimigo_morreu.connect(GameManager._on_inimigo_morreu)
	$HurtBox.area_entered.connect(_on_hurtbox_area_entered)
	_player = get_tree().get_first_node_in_group("player") as Player

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	if _player:
		var direcao: float = sign(_player.global_position.x - global_position.x)
		velocity.x = direcao * velocidade
		$AnimatedSprite2D.flip_h = direcao < 0
		$AnimatedSprite2D.play("move")
	else:
		velocity.x = 0.0
		$AnimatedSprite2D.play("idle")

	move_and_slide()

func receber_dano(valor: int) -> void:
	vida_atual -= valor
	if vida_atual <= 0:
		_morrer()
	else:
		_flash_hit()

func _morrer() -> void:
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

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	pass

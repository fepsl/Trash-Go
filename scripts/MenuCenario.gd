@tool
extends Control
## A mesma arte das fases, com luz e partículas discretas para os menus.

const FUNDOS: Array[Texture2D] = [
	preload("res://assets/backgrounds/pixel/fase1_cidade.png"),
	preload("res://assets/backgrounds/pixel/fase2_aterro.png"),
	preload("res://assets/backgrounds/pixel/fase3_rio.png"),
	preload("res://assets/backgrounds/pixel/fase4_fabrica.png"),
]

@export var oficina: bool = false
var fase: int = 1
var _tempo: float = 0.0
var _sombra_lateral: GradientTexture2D
var _sombra_inferior: GradientTexture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lateral := Gradient.new()
	lateral.offsets = PackedFloat32Array([0.0, 0.3, 0.65, 1.0])
	lateral.colors = PackedColorArray([
		Color(0.025, 0.045, 0.07, 0.68 if oficina else 0.91),
		Color(0.025, 0.045, 0.07, 0.68 if oficina else 0.7),
		Color(0.025, 0.045, 0.07, 0.68 if oficina else 0.22),
		Color(0.025, 0.045, 0.07, 0.68 if oficina else 0.05),
	])
	_sombra_lateral = GradientTexture2D.new()
	_sombra_lateral.gradient = lateral
	_sombra_lateral.width = 256
	_sombra_lateral.height = 1
	var inferior := Gradient.new()
	inferior.offsets = PackedFloat32Array([0.0, 0.45, 0.8, 1.0])
	inferior.colors = PackedColorArray([Color(0.025, 0.04, 0.06, 0), Color(0.025, 0.04, 0.06, 0.06), Color(0.025, 0.04, 0.06, 0.36), Color(0.025, 0.04, 0.06, 0.7)])
	_sombra_inferior = GradientTexture2D.new()
	_sombra_inferior.gradient = inferior
	_sombra_inferior.width = 1
	_sombra_inferior.height = 256
	_sombra_inferior.fill_to = Vector2.DOWN

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_tempo += delta
	queue_redraw()

func _draw() -> void:
	var textura := FUNDOS[clampi(fase - 1, 0, 3)]
	var proporcao := maxf(size.x / textura.get_width(), size.y / textura.get_height())
	var dimensao := textura.get_size() * proporcao
	draw_texture_rect(textura, Rect2((size - dimensao) * 0.5, dimensao), false)
	# Gradientes contínuos evitam emendas e preservam o pôr do sol.
	if _sombra_lateral and _sombra_inferior:
		draw_texture_rect(_sombra_lateral, Rect2(Vector2.ZERO, size), false)
		draw_texture_rect(_sombra_inferior, Rect2(Vector2.ZERO, size), false)
	for i in range(24):
		var x := fposmod(i * 173.0 + sin(_tempo * 0.2 + i) * 25.0, maxf(size.x, 1))
		var y := fposmod(i * 79.0 - _tempo * (5 + i % 4), maxf(size.y, 1))
		var brilho := 0.12 + (sin(_tempo + i) + 1) * 0.12
		draw_rect(Rect2(Vector2(x, y).floor(), Vector2(2, 2)), Color(1.0, 0.79, 0.46, brilho))

extends Node2D
## Movimento secundário da corrida, sincronizado com os quadros das pernas.
## A malha usa o atlas original: não recorta braços nem abre emendas na cintura.

const COLUNAS: int = 12
const LINHAS: int = 16
const ESCALA_CORRIDA: float = 0.56
const QUADRIL := Vector2(-8.0, -76.0)
const PESCOCO := Vector2(-5.0, -140.0)

var _malha: Polygon2D
var _bases: Dictionary = {}
var _uvs: Dictionary = {}
var _base := PackedVector2Array()

@onready var _sprite: AnimatedSprite2D = get_parent()

func _ready() -> void:
	_malha = Polygon2D.new()
	_malha.name = "MalhaCorrida"
	_malha.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_malha)
	var faces: Array[PackedInt32Array] = []
	for y in range(LINHAS):
		for x in range(COLUNAS):
			var i := y * (COLUNAS + 1) + x
			faces.append(PackedInt32Array([i, i + 1, i + COLUNAS + 2]))
			faces.append(PackedInt32Array([i, i + COLUNAS + 2, i + COLUNAS + 1]))
	_malha.polygons = faces
	_sprite.animation_changed.connect(_sincronizar_quadro)
	_sprite.frame_changed.connect(_sincronizar_quadro)
	_sincronizar_quadro()

func _sincronizar_quadro() -> void:
	var correndo := _sprite.animation == &"run"
	_malha.visible = correndo
	# self_modulate esconde só o desenho original; o flash de dano em modulate
	# continua sendo herdado pela malha, assim como escala e posição do sprite.
	_sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.0 if correndo else 1.0)
	if not correndo:
		return
	var atlas := _sprite.sprite_frames.get_frame_texture(&"run", _sprite.frame) as AtlasTexture
	if not _bases.has(_sprite.frame):
		var pontos := PackedVector2Array()
		var coordenadas := PackedVector2Array()
		for y in range(LINHAS + 1):
			for x in range(COLUNAS + 1):
				var local := atlas.region.size * Vector2(float(x) / COLUNAS, float(y) / LINHAS)
				pontos.append(_sprite.offset + atlas.margin.position + local)
				coordenadas.append(atlas.region.position + local)
		_bases[_sprite.frame] = pontos
		_uvs[_sprite.frame] = coordenadas
	_base = _bases[_sprite.frame]
	_malha.texture = atlas.atlas
	_malha.uv = _uvs[_sprite.frame]
	_atualizar_movimento()

func _process(_delta: float) -> void:
	if _malha.visible and _sprite.is_playing():
		_atualizar_movimento()

func _atualizar_movimento() -> void:
	var quadros := _sprite.sprite_frames.get_frame_count(&"run")
	var fase := (_sprite.frame + _sprite.frame_progress) / quadros * TAU
	var inclinacao := 0.035 + sin(fase * 2.0 - 0.4) * 0.045
	var ombros := sin(fase * 2.0 - PI / 3.0) * 1.8
	var mochila := sin(fase * 2.0 - 0.9) * 2.0
	var pontos := PackedVector2Array()
	pontos.resize(_base.size())
	for i in range(_base.size()):
		var p := _base[i] * ESCALA_CORRIDA
		var superior := 1.0 - smoothstep(-75.0, -48.0, p.y)
		var cabeca := 1.0 - smoothstep(-157.0, -135.0, p.y)
		var ferramenta := smoothstep(12.0, 40.0, p.x) * smoothstep(-150.0, -110.0, p.y) * (1.0 - smoothstep(-50.0, -25.0, p.y))
		var costas := (1.0 - smoothstep(-28.0, -5.0, p.x)) * superior
		# Abaixo da cintura o peso é zero: as pernas e o apoio ficam intactos.
		var deslocado := QUADRIL + (p - QUADRIL).rotated(inclinacao * superior)
		deslocado.y += ombros * superior + mochila * costas
		# Cabeça compensa parte da inclinação.
		deslocado += ((p - PESCOCO).rotated(-inclinacao * 0.4) - (p - PESCOCO)) * cabeca
		# A garra mantém a pose do atlas, sem balanço ou deformação adicional.
		deslocado = deslocado.lerp(p, ferramenta)
		pontos[i] = deslocado / ESCALA_CORRIDA
	_malha.polygon = pontos

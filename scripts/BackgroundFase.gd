extends CanvasLayer
## Reutiliza a arte em duas faixas: cenário distante e piso na velocidade do mundo.
## A repetição alterna o espelhamento para unir bordas sem faixas vazias.

@export var textura: Texture2D
@export var linha_chao: int = 870
@export var inicio_piso: int = 820
@export_range(0.0, 1.0) var velocidade_fundo: float = 0.25
@export var base_visual: float = 394.0

var _fundos: Array[Sprite2D] = []
var _pisos: Array[Sprite2D] = []
var _largura_tile: int = 0
var _altura_fundo: int = 0
var _altura_piso: int = 0
var _altura_superficie: int = 0
var _tamanho_viewport: Vector2 = Vector2.ZERO
var _chao_tela: int = -10000

func _ready() -> void:
	layer = -10
	_atualizar()

func _process(_delta: float) -> void:
	_atualizar()

func _atualizar() -> void:
	if not textura:
		return
	var tamanho := get_viewport().get_visible_rect().size
	var camera := get_viewport().get_canvas_transform()
	var chao := roundi((camera * Vector2(0.0, base_visual)).y)
	if tamanho != _tamanho_viewport or chao != _chao_tela:
		_configurar(tamanho, chao)
	var deslocamento := -camera.origin.x
	var topo_piso := _chao_tela - _altura_superficie
	_posicionar(_fundos, deslocamento * velocidade_fundo, topo_piso - _altura_fundo)
	_posicionar(_pisos, deslocamento, topo_piso)

func _configurar(tamanho: Vector2, chao: int) -> void:
	_tamanho_viewport = tamanho
	_chao_tela = chao
	var largura := textura.get_width()
	var altura := textura.get_height()
	var linha := clampi(linha_chao, 1, altura - 1)
	var inicio := clampi(inicio_piso, 1, linha)
	# Cobrir acima e abaixo dos pés, mesmo quando a câmera muda de posição.
	var escala := maxf(maxf(1.0, chao) / linha, maxf(1.0, tamanho.y - chao) / (altura - linha))
	_largura_tile = maxi(1, ceili(largura * escala))
	_altura_fundo = maxi(1, ceili(inicio * escala))
	_altura_piso = maxi(1, ceili((altura - inicio) * escala))
	_altura_superficie = roundi((linha - inicio) * escala)
	var quantidade := ceili(tamanho.x / _largura_tile) + 2
	_ajustar_quantidade(_fundos, quantidade)
	_ajustar_quantidade(_pisos, quantidade)
	for sprite in _fundos:
		sprite.region_rect = Rect2(0, 0, largura, inicio)
		sprite.scale = Vector2(float(_largura_tile) / largura, float(_altura_fundo) / inicio)
	for sprite in _pisos:
		sprite.region_rect = Rect2(0, inicio, largura, altura - inicio)
		sprite.scale = Vector2(float(_largura_tile) / largura, float(_altura_piso) / (altura - inicio))

func _ajustar_quantidade(tiles: Array[Sprite2D], quantidade: int) -> void:
	while tiles.size() < quantidade:
		var sprite := Sprite2D.new()
		sprite.texture = textura
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.region_enabled = true
		sprite.region_filter_clip_enabled = true
		add_child(sprite)
		tiles.append(sprite)
	while tiles.size() > quantidade:
		var sprite: Sprite2D = tiles.pop_back()
		sprite.queue_free()

func _posicionar(tiles: Array[Sprite2D], deslocamento: float, altura: int) -> void:
	var primeiro := floori(deslocamento / _largura_tile)
	var resto := roundi(fposmod(deslocamento, float(_largura_tile)))
	for i in range(tiles.size()):
		tiles[i].position = Vector2(i * _largura_tile - resto, altura)
		tiles[i].flip_h = posmod(primeiro + i, 2) == 1

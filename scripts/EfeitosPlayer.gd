extends Node2D
## Efeitos locais: acompanham o personagem sem alterar movimento ou colisões.

var escudo_ativo: bool = false
var correndo: bool = false
var velocidade_ativa: bool = false
var _tempo: float = 0.0
var _ataque: float = 0.0
var _area: bool = false
var _alcance: float = 1.0
var _impacto_escudo: float = 0.0
var _poeira: float = 0.0

func _process(delta: float) -> void:
	_tempo += delta
	_ataque = maxf(0.0, _ataque - delta)
	_impacto_escudo = maxf(0.0, _impacto_escudo - delta)
	if correndo:
		_poeira = fmod(_poeira + delta * 3.0, 1.0)
	queue_redraw()

func atacar(em_area: bool, alcance: float) -> void:
	_ataque = 0.3
	_area = em_area
	_alcance = alcance

func bloquear() -> void:
	_impacto_escudo = 0.35

func reiniciar() -> void:
	_ataque = 0.0
	_impacto_escudo = 0.0
	_poeira = 0.0

func _draw() -> void:
	# Sombra suave ancorada na mesma base dos pés em todas as animações.
	draw_set_transform(Vector2(0, 93), 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, 38.0, Color(0.02, 0.06, 0.07, 0.12))
	draw_circle(Vector2.ZERO, 29.0, Color(0.02, 0.06, 0.07, 0.18))
	draw_set_transform(Vector2.ZERO)
	if correndo:
		for i in range(4):
			var fase := fmod(_poeira + i * 0.25, 1.0)
			var pos := Vector2(-18.0 - fase * 48.0, 90.0 - sin(fase * PI) * 12.0)
			draw_circle(pos, 2.0 + fase * 3.0, Color(0.85, 0.82, 0.64, (1.0 - fase) * 0.28))
		if velocidade_ativa:
			for i in range(3):
				var x := -30.0 - fmod(_tempo * 140.0 + i * 23.0, 35.0)
				draw_line(Vector2(x - 28.0, -34.0 + i * 34.0), Vector2(x, -34.0 + i * 34.0), Color(0.76, 0.95, 0.56, 0.5), 3.0, true)
	if escudo_ativo or _impacto_escudo > 0.0:
		var pulso := 0.65 + sin(_tempo * 3.0) * 0.12
		if _impacto_escudo > 0.0:
			pulso = _impacto_escudo / 0.35
		draw_set_transform(Vector2(0, 3), 0.0, Vector2(0.76, 1.0))
		draw_circle(Vector2.ZERO, 102.0, Color(0.25, 0.8, 1.0, 0.045 * pulso))
		draw_arc(Vector2.ZERO, 102.0, -1.3, 1.3, 32, Color(0.48, 0.91, 1.0, 0.65 * pulso), 3.0, true)
		draw_arc(Vector2.ZERO, 102.0, 1.8, 4.45, 32, Color(0.48, 0.91, 1.0, 0.22 * pulso), 2.0, true)
		draw_set_transform(Vector2.ZERO)
	if _ataque > 0.0:
		var progresso := 1.0 - _ataque / 0.3
		var alpha := sin(progresso * PI)
		var raio := (62.0 + progresso * 42.0) * _alcance
		var cor := Color(0.64, 1.0, 0.75, alpha * 0.85)
		draw_arc(Vector2(10, 14), raio, -1.2 + progresso * 0.3, 1.0 + progresso * 0.3, 28, Color(cor, alpha * 0.13), 18.0, true)
		draw_arc(Vector2(10, 14), raio, -1.2 + progresso * 0.3, 1.0 + progresso * 0.3, 28, cor, 4.0 * (1.0 - progresso) + 1.0, true)
		if _area:
			draw_set_transform(Vector2(0, 88), 0.0, Vector2(1.0, 0.32))
			draw_arc(Vector2.ZERO, 30.0 + progresso * 120.0, 0.0, TAU, 64, Color(1.0, 0.72, 0.32, alpha * 0.7), 4.0, true)
			draw_set_transform(Vector2.ZERO)

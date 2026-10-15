extends Node2D

@export var base: float = 88.0
@export var largura: float = 36.0

func _draw() -> void:
	draw_set_transform(Vector2(0.0, base), 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, largura, Color(0.015, 0.04, 0.05, 0.12))
	draw_circle(Vector2.ZERO, largura * 0.74, Color(0.015, 0.04, 0.05, 0.2))

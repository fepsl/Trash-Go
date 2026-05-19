extends AnimatedSprite2D

func _ready() -> void:
	play("explode")
	animation_finished.connect(queue_free)

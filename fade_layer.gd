
extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.6)
	await tween.finished

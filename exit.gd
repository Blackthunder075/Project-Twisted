

extends Area2D

@export_file("*.tscn") var next_level: String
@export var fade_layer: CanvasLayer

var changing_level := false

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if changing_level:
		return

	if body.is_in_group("player") and next_level != "":
		changing_level = true

		if fade_layer:
			await fade_layer.fade_out()

		get_tree().change_scene_to_file(next_level)

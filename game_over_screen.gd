
extends Control

@onready var retry_button: Button = $RetryButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)


func show_game_over() -> void:
	visible = true
	get_tree().paused = true


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

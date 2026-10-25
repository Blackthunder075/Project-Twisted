

extends Node2D

var knockback_velocity: Vector2 = Vector2.ZERO

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: float = 60.0
const KNOCKBACK_DECAY: float = 500.0

@export var max_health: int = 3
var health: int
var direction: float = 1.0


func _ready() -> void:
	health = max_health


func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1.0
		animated_sprite.flip_h = true

	elif ray_cast_left.is_colliding():
		direction = 1.0
		animated_sprite.flip_h = false

	position += knockback_velocity * delta
	position.x += direction * SPEED * delta

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		KNOCKBACK_DECAY * delta
	)


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	print("Enemy health: ", health)

	if health <= 0:
		queue_free()
		return

	animated_sprite.modulate = Color.RED

	await get_tree().create_timer(0.12).timeout

	if is_inside_tree():
		animated_sprite.modulate = Color.WHITE


func apply_knockback(knockback_direction: Vector2, force: float) -> void:
	knockback_velocity = knockback_direction * force


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass

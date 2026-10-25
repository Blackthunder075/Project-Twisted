


extends CharacterBody2D

@export var max_health: int = 5

const SPEED: float = 140.0
const JUMP_VELOCITY: float = -300.0
const ATTACK_COOLDOWN: float = 0.25
const ATTACK_DAMAGE: int = 1
const KNOCKBACK_FORCE: float = 180.0

var health: int
var is_invulnerable: bool = false
var is_attacking: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = get_tree().current_scene.get_node("CanvasLayer/HealthBar")


func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health


func take_damage(amount: int) -> void:
	if is_invulnerable:
		return

	health = max(health - amount, 0)
	health_bar.value = health

	if health <= 0:
		var game_over = get_tree().current_scene.get_node_or_null("CanvasLayer/GameOverScreen")
		if game_over:
			game_over.show_game_over()
		return

	is_invulnerable = true
	animated_sprite.modulate = Color.RED

	await get_tree().create_timer(0.8).timeout

	if not is_inside_tree():
		return

	animated_sprite.modulate = Color.WHITE
	is_invulnerable = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("attack"):
		attack()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction: float = Input.get_axis("move_left", "move_right")

	if direction < 0:
		animated_sprite.flip_h = true
		attack_area.position.x = -30
	elif direction > 0:
		animated_sprite.flip_h = false
		attack_area.position.x = 30

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		elif not is_attacking:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	attack_area.monitoring = true

	await get_tree().physics_frame

	var areas: Array[Area2D] = attack_area.get_overlapping_areas()

	for area in areas:
		if not is_instance_valid(area):
			continue

		var enemy: Node = area.get_parent()

		if not is_instance_valid(enemy):
			continue

		if enemy.has_method("take_damage"):
			enemy.take_damage(ATTACK_DAMAGE)

			if enemy.has_method("apply_knockback"):
				var knockback_direction: float = sign(
					enemy.global_position.x - global_position.x
				)

				if knockback_direction == 0:
					knockback_direction = -1 if animated_sprite.flip_h else 1

				enemy.apply_knockback(
					Vector2(knockback_direction, 0.0),
					KNOCKBACK_FORCE
				)

	attack_area.monitoring = false

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	if is_inside_tree():
		is_attacking = false

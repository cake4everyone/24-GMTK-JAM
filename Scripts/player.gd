extends CharacterBody2D

const SPEED = 500.0
const ACCELERATION = 30
const JUMP_VELOCITY = -1200.0

const WALL_JUMP_PUSHBACK = 500
const WALL_SLIDE_FRICTION = 100

var slidingr = false
var slidingl = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var doubleJump := true

func _physics_process(delta):
	var input_dir: Vector2 = input()

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(SPEED * input_dir, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION)

	velocity.y += gravity
	if Input.is_action_just_pressed("ui_accept"):
		jump()
	if is_on_floor():
		doubleJump = true

	for body in $Range.get_overlapping_bodies():
		if body.get_parent() is Platform && is_on_floor():
			body.get_parent().enabled = true

	slide(delta)
	move_and_slide()

func input():
	var input_dir = Vector2.ZERO

	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	return input_dir

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif doubleJump && !slidingr && !slidingl:
		velocity.y = JUMP_VELOCITY * 0.8
		doubleJump = false

	if slidingl:
		velocity.y = JUMP_VELOCITY * 0.7
		velocity.x = WALL_JUMP_PUSHBACK

	if slidingr:
		velocity.y = JUMP_VELOCITY * 0.7
		velocity.x = -WALL_JUMP_PUSHBACK

func slide(delta):
	if !is_on_floor():
		if check_for_wall("l") is StaticBody2D:
			var body = check_for_wall("l")
			slidingl = true
			body.get_parent().enabled = false
		elif check_for_wall("r") is StaticBody2D:
			var body = check_for_wall("r")
			slidingr = true
			body.get_parent().enabled = false
		else:
			slide_cooldown()
	else:
		slide_cooldown()

	if slidingl || slidingr:
		velocity.y += WALL_SLIDE_FRICTION * delta
		velocity.y = min(velocity.y, WALL_SLIDE_FRICTION)

func slide_cooldown():
	await get_tree().create_timer(0.05).timeout
	slidingl = false
	slidingr = false

func check_for_wall(d):
	if d == "l":
		for body in $Left.get_overlapping_bodies():
			if body is StaticBody2D:
				return body
		return false
	elif d == "r":
		for body in $Right.get_overlapping_bodies():
			if body is StaticBody2D:
				return body
		return false
	return

func _on_range_body_exited(body):
	if body is StaticBody2D && body.get_parent() is Platform:
		body.get_parent().enabled = true


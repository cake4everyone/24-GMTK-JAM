extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -1500.0
const ACCELERATION = 50

const WALL_JUMP_PUSHBACK = 500
const WALL_SLIDE_FRICTION = 100

var sliding = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var doubleJump := true

func _physics_process(delta):
	var input_dir: Vector2 = input()
	
	if(input_dir != Vector2.ZERO):
		velocity = velocity.move_toward(SPEED * input_dir, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION)
	
	velocity.y += gravity
	if Input.is_action_just_pressed("ui_accept"):
		jump()
	if is_on_floor():
		doubleJump = true
	
	slide(delta)
	move_and_slide()
	
func input():
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left","ui_right")
	input_dir = input_dir.normalized()
	return input_dir
	
func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif doubleJump && !sliding:
		velocity.y = JUMP_VELOCITY * 0.8
		doubleJump = false

	if sliding && Input.is_action_pressed("ui_left"):
		velocity.y = JUMP_VELOCITY * 0.7
		velocity.x = WALL_JUMP_PUSHBACK
		
	if sliding && Input.is_action_pressed("ui_right"):
		velocity.y = JUMP_VELOCITY * 0.7
		velocity.x = -WALL_JUMP_PUSHBACK
		
func slide(delta):
	if is_on_wall() && !is_on_floor():
		if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left"):
			sliding = true
		else:
			slide_cooldown()
	else: 
		slide_cooldown()
		
	if sliding:
		velocity.y += WALL_SLIDE_FRICTION * delta
		velocity.y = min(velocity.y, WALL_SLIDE_FRICTION)
		
func slide_cooldown():
	await get_tree().create_timer(0.05).timeout
	sliding = false
	

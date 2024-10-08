extends CharacterBody2D
class_name Player

const SPEED = 500.0
const ACCELERATION = 30
const JUMP_VELOCITY = -1200.0

const WALL_JUMP_PUSHBACK = 500
const WALL_SLIDE_FRICTION = 100

var slidingr = false
var slidingl = false
var facingR = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var doubleJump := true

func _ready():
	$ShapeCast2D.shape = $CollisionShape2D.shape
	$ShapeCast2D.target_position = Vector2(0, $Range/CollisionShape2D.shape.radius)
	
	if SceneManager.currentWorld == 3:
		gravity = 40
	else:
		gravity = 80

func _process(_delta):
	$Jump.volume_db = SceneManager.volumeSFX
	if Input.is_action_pressed("RightMouseDown"):
		$Vignette.show()
	else:
		$Vignette.hide()

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

	var p: Platform = get_standing_platform()
	if p != null: p.enabled = false

	slide(delta)
	move_and_slide()
	animate(input_dir)
	

func input():
	var input_dir = Vector2.ZERO

	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	return input_dir

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		$Jump.play()
	elif doubleJump && !slidingr && !slidingl:
		velocity.y = JUMP_VELOCITY * 0.8
		$Jump.play()
		doubleJump = false

	if slidingl:
		$Jump.play()
		velocity.y = JUMP_VELOCITY * 0.7
		velocity.x = WALL_JUMP_PUSHBACK

	if slidingr:
		$Jump.play()
		velocity.y = JUMP_VELOCITY * 0.7
		velocity.x = -WALL_JUMP_PUSHBACK

func slide(delta):
	var wall: Node2D = check_for_wall()
	if is_on_floor() || !wall:
		slide_cooldown()
		return
	if wall.get_parent() is Platform:
		wall.get_parent().enabled = false

	if slidingl || slidingr:
		velocity.y += WALL_SLIDE_FRICTION * delta
		velocity.y = min(velocity.y, WALL_SLIDE_FRICTION)

func slide_cooldown():
	if get_tree():
		await get_tree().create_timer(0.05).timeout
		slidingl = false
		slidingr = false

func check_for_wall() -> Node2D:
	for body: Node2D in $Left.get_overlapping_bodies():
		if body != self:
			slidingl = true
			return body
	for body: Node2D in $Right.get_overlapping_bodies():
		if body != self:
			slidingr = true
			return body
	return null

func animate(input_dir):
	if !is_on_floor():
		if slidingl || slidingr:
			$Animations.play("slide")
		elif velocity.y < 0:
			$Animations.play("jump")
		else:
			$Animations.play("fall")
	
	if is_on_floor() && velocity.x == 0:
		$Animations.play("idle")

	if velocity.x != 0 && is_on_floor() && !is_on_wall():
		$Animations.play("walk")
		
	if input_dir.x == 1 || slidingr:
		$Sprite2D.scale.x = 2
	elif input_dir.x == -1 || slidingl:
		$Sprite2D.scale.x = -2

func _on_range_body_exited(body):
	if body is StaticBody2D && body.get_parent() is Platform:
		body.get_parent().enabled = false

func get_standing_platform() -> Platform:
	var collider: Object = $ShapeCast2D.get_collider(0)
	if collider != null && collider.get_parent() is Platform:
		return collider.get_parent()
	return null

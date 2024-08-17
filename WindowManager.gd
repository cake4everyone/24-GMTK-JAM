extends Control

var colShape: CollisionShape2D

var camPreviousPos: Vector2
var resizeLeft: bool
var resizeRight: bool
var resizeTop: bool
var resizeBottom: bool

var deactivated := false

const BORDER_SIZE := 10

func _ready():
	colShape = get_node("StaticBody2D/CollisionShape2D")
	colShape.global_position = get_position() + get_size() / 2
	colShape.shape = RectangleShape2D.new()
	colShape.shape.size = get_size()

	$Mouse.position = Vector2(-BORDER_SIZE, -BORDER_SIZE)
	$Mouse.size = get_size() + Vector2(2 * BORDER_SIZE, 2 * BORDER_SIZE)

func _process(_delta):
	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		change_size(%Player/Camera2D.get_screen_center_position() - camPreviousPos)
		camPreviousPos = %Player/Camera2D.get_screen_center_position()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		mouse_button(event)

	if event is InputEventMouseMotion:
		mouse_motion(event)

func mouse_button(_event: InputEventMouse):
	if !deactivated && Input.is_action_just_pressed("LeftMouseDown"):
		resizeLeft = is_on_left_border()
		resizeRight = is_on_right_border()
		resizeTop = is_on_top_border()
		resizeBottom = is_on_bottom_border()
		camPreviousPos = %Player/Camera2D.get_screen_center_position()

	if Input.is_action_just_released("LeftMouseDown"):
		resizeLeft = false
		resizeRight = false
		resizeTop = false
		resizeBottom = false

func mouse_motion(event: InputEventMouseMotion):
	var rect: Rect2 = get_global_rect()
	var localPlayerPos = %Player.position - get_global_position()
	var safeMargin = %Player.get_child(0).shape.size.x / 2

	if localPlayerPos.x > 0 - safeMargin && localPlayerPos.y > -100 && localPlayerPos.x < rect.size.x + safeMargin && localPlayerPos.y < 20:
		deactivated = true
	elif (localPlayerPos.x < 0 - safeMargin || localPlayerPos.y < -100 || localPlayerPos.x > rect.size.x + safeMargin || localPlayerPos.y > 20) && %Player.is_on_floor():
		deactivated = false

	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		change_size(event.relative)

	if deactivated:
		$Mouse.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN # X
	elif (is_on_top_border() || is_on_bottom_border()) && !is_on_right_border() && !is_on_left_border():
		$Mouse.mouse_default_cursor_shape = Control.CURSOR_VSIZE # ↕
	elif (is_on_left_border() || is_on_right_border()) && !is_on_top_border() && !is_on_bottom_border():
		$Mouse.mouse_default_cursor_shape = Control.CURSOR_HSIZE # ↔
	elif is_on_bottom_border() && is_on_left_border() || is_on_top_border() && is_on_right_border():
		$Mouse.mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE # ↗
	elif is_on_top_border() && is_on_left_border() || is_on_bottom_border() && is_on_right_border():
		$Mouse.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE # ↘
	else:
		$Mouse.mouse_default_cursor_shape = Control.CURSOR_ARROW

func is_on_left_border() -> bool:
	var rect: Rect2 = get_global_rect()
	var pos: Vector2 = get_local_mouse_position()

	return pos.x >= -BORDER_SIZE && pos.x <= BORDER_SIZE && pos.y >= -BORDER_SIZE && pos.y <= rect.size.y + BORDER_SIZE

func is_on_right_border() -> bool:
	var rect: Rect2 = get_global_rect()
	var pos: Vector2 = get_local_mouse_position()

	return pos.x >= rect.size.x - BORDER_SIZE && pos.x <= rect.size.x + BORDER_SIZE && pos.y >= -BORDER_SIZE && pos.y <= rect.size.y + BORDER_SIZE

func is_on_top_border() -> bool:
	var rect: Rect2 = get_global_rect()
	var pos: Vector2 = get_local_mouse_position()

	return pos.x >= -BORDER_SIZE && pos.x <= rect.size.x + BORDER_SIZE && pos.y >= -BORDER_SIZE && pos.y <= BORDER_SIZE

func is_on_bottom_border() -> bool:
	var rect: Rect2 = get_global_rect()
	var pos: Vector2 = get_local_mouse_position()

	return pos.x >= -BORDER_SIZE && pos.x <= rect.size.x + BORDER_SIZE && pos.y >= rect.size.y - BORDER_SIZE && pos.y <= rect.size.y + BORDER_SIZE

func change_size(change: Vector2):
	var newSize: Vector2 = get_size()
	var newPos: Vector2 = get_position()

	if resizeRight:
		newSize.x += change.x
	if resizeBottom:
		newSize.y += change.y

	if resizeLeft:
		newSize.x -= change.x
		newPos.x += change.x
		set_position(newPos)

	if resizeTop:
		newSize.y -= change.y
		newPos.y += change.y
		set_position(newPos)

	set_size(newSize)
	colShape.shape.size = newSize
	colShape.global_position = Vector2(get_position().x + (newSize.x / 2), get_position().y + (newSize.y / 2))

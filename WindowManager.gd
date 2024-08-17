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
	print("1: " + str(colShape))
	colShape.shape = RectangleShape2D.new()
	colShape.shape.size = Vector2(get_size().x, get_size().y)
	colShape.global_position = Vector2(get_position().x + (get_size().x / 2), get_position().y + (get_size().y / 2))
	print("2: " + str(colShape))
	$Mouse.position = Vector2(-BORDER_SIZE, -BORDER_SIZE)
	$Mouse.size = get_size() + Vector2(2 * BORDER_SIZE, 2 * BORDER_SIZE)

func _process(_delta):
	print("%s left: %s, right: %s, top: %s, bottom: %s" % [str(colShape), is_on_left_border(), is_on_right_border(), is_on_top_border(), is_on_bottom_border()])

	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		var newSize: Vector2 = get_size()
		var newPos: Vector2 = get_position()

		var camRelative: Vector2 = camPreviousPos - %Player/Camera2D.get_screen_center_position()

		if resizeRight:
			newSize.x -= camRelative.x
		if resizeBottom:
			newSize.y -= camRelative.y
			
		if resizeLeft:
			newSize.x += camRelative.x
			newPos.x -= camRelative.x
			set_position(newPos)
			
		if resizeTop:
			newSize.y += camRelative.y
			newPos.y -= camRelative.y
			set_position(newPos)

		set_size(newSize)
		colShape.shape.size = newSize
		colShape.global_position = Vector2(get_position().x + (newSize.x / 2), get_position().y + (newSize.y / 2))
		camPreviousPos = %Player/Camera2D.get_screen_center_position()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		mouse_button(event)

	if event is InputEventMouseMotion:
		mouse_motion(event)

func mouse_button(event: InputEventMouse):
	var rect: Rect2 = get_global_rect()
	var localPlayerPos = %Player.position - get_global_position()

	if localPlayerPos.x > 0 && localPlayerPos.y > -100 && localPlayerPos.x < rect.size.x && localPlayerPos.y < 20:
		deactivated = true
	elif (localPlayerPos.x < 0 || localPlayerPos.y < -100 || localPlayerPos.x > rect.size.x || localPlayerPos.y > 20) && %Player.is_on_floor():
		deactivated = false

	if Input.is_action_just_released("LeftMouseDown"):
		resizeLeft = false
		resizeRight = false
		resizeTop = false
		resizeBottom = false
		
	if deactivated:
		return
	
	if Input.is_action_just_pressed("LeftMouseDown"):
		if is_on_right_border():
			resizeRight = true
			print(colShape, "right")

		if is_on_bottom_border():
			resizeBottom = true
			print(colShape, "bottom")

		if is_on_left_border():
			resizeLeft = true
			print(colShape, "left")

		if is_on_top_border():
			resizeTop = true
			print(colShape, "top")

		if resizeRight || resizeLeft || resizeBottom || resizeTop:
			camPreviousPos = %Player/Camera2D.get_screen_center_position()

func mouse_motion(event: InputEventMouseMotion):
	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		var newSize: Vector2 = get_size()
		var newPos: Vector2 = get_position()

		if resizeRight:
			newSize.x += event.relative.x
		if resizeBottom:
			newSize.y += event.relative.y

		if resizeLeft:
			newSize.x -= event.relative.x
			newPos.x += event.relative.x
			set_position(newPos)

		if resizeTop:
			newSize.y -= event.relative.y
			newPos.y += event.relative.y
			set_position(newPos)

		set_size(newSize)
		colShape.shape.size = newSize
		colShape.global_position = Vector2(get_position().x + (newSize.x / 2), get_position().y + (newSize.y / 2))
		#print(colShape)

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

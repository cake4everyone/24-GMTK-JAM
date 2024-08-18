@tool
extends Control
class_name Platform

func _get_configuration_warnings():
	var warnings = []
	var found_marker = false
	for child in get_children():
		if !(child is Marker2D):
			continue
		if found_marker:
			warnings.append("There is already a child node of type 'Marker2D' as anchor.")
		else:
			found_marker = true

	if !found_marker:
		warnings.append("Node of type 'Marker2D' as anchor is missing.")
	return warnings

@export var inverted: bool
@export var locked: bool
@onready var Player = %Player
@onready var Camera = %Camera2D
var anchorPoint: Vector2
var color: Color = Color.WHITE

var colShape: CollisionShape2D

var camPreviousPos: Vector2
var resizeLeft: bool
var resizeRight: bool
var resizeTop: bool
var resizeBottom: bool

var deactivated := true
var enabled := false
var mouse_inside: bool

var pending_change: Vector2 = Vector2.ZERO

const BORDER_SIZE := 10

func _ready():
	update_configuration_warnings()
	colShape = get_node("StaticBody2D/CollisionShape2D")
	colShape.shape = RectangleShape2D.new()
	update_collider_size()

	$Mouse.position = Vector2(-BORDER_SIZE, -BORDER_SIZE)
	$Mouse.size = get_size() + Vector2(2 * BORDER_SIZE, 2 * BORDER_SIZE)

	for child in get_children():
		if !(child is Marker2D):
			continue
		anchorPoint = child.position / get_size()

	if get_parent() is PlatformGroup:
		color = get_parent().color

func update_collider_size():
	colShape.position = get_size() / 2
	colShape.shape.size = get_size()

func _physics_process(_delta):
	# dont process physics if no player exist
	if Player == null: return

	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		change_size(Camera.get_screen_center_position() - camPreviousPos)
		camPreviousPos = Camera.get_screen_center_position()

	if locked || !enabled:
		deactivated = true
	elif enabled && Player.is_on_floor():
		deactivated = false

	if !pending_change.is_zero_approx():
		change_pending_size()
		pending_change = Vector2.ZERO

func _process(_delta):
	$Lock.position = get_size() * anchorPoint

	if deactivated:
		$Sprite.self_modulate = color.darkened(0.75)
	else:
		$Sprite.self_modulate = color

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
		camPreviousPos = Camera.get_screen_center_position()

	if Input.is_action_just_released("LeftMouseDown"):
		if mouse_inside == false:
			$Lock.hide()
		resizeLeft = false
		resizeRight = false
		resizeTop = false
		resizeBottom = false

func mouse_motion(event: InputEventMouseMotion):
	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		change_size(event.relative)
		if !$Lock.is_visible():
			$Lock.show()

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
	if deactivated || change == Vector2.ZERO:
		return
	if !(resizeLeft || resizeRight):
		change.x = 0
	if !(resizeTop || resizeBottom):
		change.y = 0
	if resizeLeft:
		change.x = -change.x
	if resizeTop:
		change.y = -change.y

	if inverted:
		change = -change

	pending_change += change

func change_pending_size():
	if not get_parent() is PlatformGroup:
		set_new_change(validate_change(pending_change))
		return

	var group: PlatformGroup = get_parent()
	group.change_size(pending_change)

func validate_change(change: Vector2) -> Vector2:
	if inverted:
		change = -change

	var newSize: Vector2 = get_size() + change
	newSize.x = max(newSize.x, 3 * BORDER_SIZE)
	newSize.y = max(newSize.y, 3 * BORDER_SIZE)

	var newChange: Vector2 = newSize - get_size()
	if inverted:
		newChange = -newChange

	return newChange

func set_new_change(change: Vector2):
	if inverted:
		change = -change
	set_size(get_size() + change)
	set_position(get_position() - anchorPoint * change)

	update_collider_size()

func _on_mouse_mouse_entered():
	mouse_inside = true
	$Lock.show()
func _on_mouse_mouse_exited():
	mouse_inside = false
	$Lock.hide()

func _enable(en):
	enabled = en
	print(en)

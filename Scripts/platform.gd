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
var group
var color: Color = Color.WHITE

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
	$StaticBody2D/CollisionShape2D.shape = RectangleShape2D.new()
	$Area2D/CollisionShape2D.shape = RectangleShape2D.new()
	$Area2D/ShapeCastLeft.shape = SegmentShape2D.new()
	$Area2D/ShapeCastLeft.add_exception($StaticBody2D)
	$Area2D/ShapeCastRight.shape = SegmentShape2D.new()
	$Area2D/ShapeCastRight.add_exception($StaticBody2D)
	$Area2D/ShapeCastTop.shape = SegmentShape2D.new()
	$Area2D/ShapeCastTop.add_exception($StaticBody2D)
	$Area2D/ShapeCastBottom.shape = SegmentShape2D.new()
	$Area2D/ShapeCastBottom.add_exception($StaticBody2D)

	$Mouse.position = Vector2(-BORDER_SIZE, -BORDER_SIZE)
	$Mouse.size = get_size() + Vector2(2 * BORDER_SIZE, 2 * BORDER_SIZE)

	for child in get_children():
		if !(child is Marker2D):
			continue
		anchorPoint = child.position / get_size()

	if get_parent() is PlatformGroup:
		group = get_parent()
		color = group.color
	else:
		group = self

	update_collider_size()
	update_area_size()

func update_collider_size():
	$StaticBody2D/CollisionShape2D.position = get_size() / 2
	$StaticBody2D/CollisionShape2D.shape.size = get_size()
	print("col pos: %s" % [$StaticBody2D/CollisionShape2D.get_global_position()])

func update_area_size():
	var change: Vector2 = group.pending_change
	#if inverted:
	#	change = -change

	var newSize: Vector2 = get_size() + change
	newSize.x = max(newSize.x, 3 * BORDER_SIZE)
	newSize.y = max(newSize.y, 3 * BORDER_SIZE)
	change = newSize - get_size()
	var posChange = anchorPoint * -change

	$Area2D.position = posChange + newSize / 2
	$Area2D/CollisionShape2D.shape.size = newSize

	$Area2D/ShapeCastLeft.target_position = Vector2(newSize.x / -2, 0)
	$Area2D/ShapeCastLeft.shape.a = Vector2(0, newSize.y / -2)
	$Area2D/ShapeCastLeft.shape.b = Vector2(0, newSize.y / 2)
	$Area2D/ShapeCastRight.target_position = Vector2(newSize.x / 2, 0)
	$Area2D/ShapeCastRight.shape.a = Vector2(0, newSize.y / -2)
	$Area2D/ShapeCastRight.shape.b = Vector2(0, newSize.y / 2)
	$Area2D/ShapeCastTop.target_position = Vector2(0, newSize.y / -2)
	$Area2D/ShapeCastTop.shape.a = Vector2(newSize.x / -2, 0)
	$Area2D/ShapeCastTop.shape.b = Vector2(newSize.x / 2, 0)
	$Area2D/ShapeCastBottom.target_position = Vector2(0, newSize.y / 2)
	$Area2D/ShapeCastBottom.shape.a = Vector2(newSize.x / -2, 0)
	$Area2D/ShapeCastBottom.shape.b = Vector2(newSize.x / 2, 0)

	var p: Vector2 = $Area2D/CollisionShape2D.get_global_position()

	print("%s change %s  \tarea size: %s->%s  \tarea: %s  \tpos: %s  \tlrtb: (%f, %f, %f, %f)" % [self.name, change, self.size, newSize, $Area2D/CollisionShape2D.get_global_position(), self.position + posChange, (p - newSize / 2).x, (p + newSize / 2).x, (p - newSize / 2).y, (p + newSize / 2).y])

func _physics_process(_delta):
	# dont process physics if no player exist
	if Player == null: return

	if resizeRight || resizeLeft || resizeBottom || resizeTop:
		compute_change(Camera.get_screen_center_position() - camPreviousPos)
		camPreviousPos = Camera.get_screen_center_position()

	if locked || !enabled:
		deactivated = true
	elif enabled && Player.is_on_floor():
		deactivated = false

	if !pending_change.is_zero_approx():
		change_size()

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
		compute_change(event.relative)
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

func compute_change(change: Vector2):
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
	
	group.add_change(change)

func add_change(change: Vector2):
	#if inverted:
	#	change = -change

	pending_change += change
	update_area_size()

## Request to change size. Only called when this platform is in no group. If this platform has a
## group the group's [change_size] method is called instead. Which does basically the same, but for
## each child instead.
func change_size():
	pending_change = validate_change(pending_change)
	if pending_change.is_zero_approx(): return
	set_new_change(pending_change)
	pending_change = Vector2.ZERO
	update_collider_size()

func validate_change(change: Vector2) -> Vector2:
	#if inverted:
	#	change = -change
	#ShapeCast2D

	$Area2D/ShapeCastLeft.force_shapecast_update()
	$Area2D/ShapeCastRight.force_shapecast_update()
	$Area2D/ShapeCastTop.force_shapecast_update()
	$Area2D/ShapeCastBottom.force_shapecast_update()

	var collider = $Area2D/ShapeCastLeft.get_collider(0)
	var fraction: float
	var direction: Vector2 = Vector2.ZERO
	if collider:
		var fractionLeft: float = $Area2D/ShapeCastLeft.get_closest_collision_safe_fraction()
		if fractionLeft > fraction && fractionLeft < 1:
			fraction = fractionLeft
			direction = Vector2.RIGHT * (1 - fraction) * $Area2D/ShapeCastLeft.target_position
		print("Left found (%s): %s (%s) at %f/%f" % [$Area2D/ShapeCastLeft.is_colliding(), collider.get_parent().get_name(), collider.get_name(), $Area2D/ShapeCastLeft.get_closest_collision_safe_fraction(), $Area2D/ShapeCastLeft.get_closest_collision_unsafe_fraction()])
	collider = $Area2D/ShapeCastRight.get_collider(0)
	if collider:
		var fractionRight: float = $Area2D/ShapeCastRight.get_closest_collision_safe_fraction()
		if fractionRight > fraction && fractionRight < 1:
			fraction = fractionRight
			direction = Vector2.LEFT * (1 - fraction) * $Area2D/ShapeCastRight.target_position
		print("Right found (%s): %s (%s) at %f/%f" % [$Area2D/ShapeCastRight.is_colliding(), collider.get_parent().get_name(), collider.get_name(), $Area2D/ShapeCastRight.get_closest_collision_safe_fraction(), $Area2D/ShapeCastRight.get_closest_collision_unsafe_fraction()])
	collider = $Area2D/ShapeCastTop.get_collider(0)
	if collider:
		var fractionTop: float = $Area2D/ShapeCastTop.get_closest_collision_safe_fraction()
		if fractionTop > fraction && fractionTop < 1:
			fraction = fractionTop
			direction = Vector2.DOWN * (1 - fraction) * $Area2D/ShapeCastTop.target_position
		print("Top found (%s): %s (%s) at %f/%f" % [$Area2D/ShapeCastTop.is_colliding(), collider.get_parent().get_name(), collider.get_name(), $Area2D/ShapeCastTop.get_closest_collision_safe_fraction(), $Area2D/ShapeCastTop.get_closest_collision_unsafe_fraction()])
	collider = $Area2D/ShapeCastBottom.get_collider(0)
	if collider:
		var fractionBottom: float = $Area2D/ShapeCastBottom.get_closest_collision_safe_fraction()
		if fractionBottom > fraction && fractionBottom < 1:
			fraction = fractionBottom
			direction = Vector2.UP * (1 - fraction) * $Area2D/ShapeCastBottom.target_position
		print("Bottom found (%s): %s (%s) at %f/%f" % [$Area2D/ShapeCastBottom.is_colliding(), collider.get_parent().get_name(), collider.get_name(), $Area2D/ShapeCastBottom.get_closest_collision_safe_fraction(), $Area2D/ShapeCastBottom.get_closest_collision_unsafe_fraction()])
	if fraction != 0:
		print("needs change %s with biggest fraction %f (instead of %s)" % [direction, fraction, change])
		change += direction

	var newSize: Vector2 = get_size() + change
	newSize.x = max(newSize.x, 3 * BORDER_SIZE)
	newSize.y = max(newSize.y, 3 * BORDER_SIZE)

	#for collider: Node2D in $Area2D.get_overlapping_bodies():
	#	if collider.get_parent() == self: continue
	#	print("%s overlaps with body %s (%s)" % [get_name(), collider.get_name(), collider.get_parent().get_name()])
	#	return Vector2.ZERO
	#for collider: Node2D in $Area2D.get_overlapping_areas():
	#	if collider.get_parent() == self: continue
	#	print("%s overlaps with area %s (%s)" % [get_name(), collider.get_name(), collider.get_parent().get_name()])
	#	return Vector2.ZERO

	var newChange: Vector2 = newSize - get_size()
	#if inverted:
	#	newChange = -newChange

	return newChange

func set_new_change(change: Vector2):
	#if inverted:
	#	change = -change
	print("%s change %s  \tset: size %s->%s \tpos %s->%s \t" % [self.name, change, self.size, self.size + change, self.position, self.position - change * anchorPoint])
	set_size(get_size() + change)
	set_position(get_position() + -change * anchorPoint)

func _on_mouse_mouse_entered():
	mouse_inside = true
	$Lock.show()
func _on_mouse_mouse_exited():
	mouse_inside = false
	$Lock.hide()

func _enable(en):
	enabled = en
	print(en)

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
var show_inverted: bool

var pending_change: Vector2 = Vector2.ZERO

const BORDER_SIZE := 10

func _ready():
	if Engine.is_editor_hint():
		update_configuration_warnings()
		return
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

	if locked:
		$Anchor.frame = 1

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
	$StaticBody2D/CollisionShape2D.position = self.size / 2
	$StaticBody2D/CollisionShape2D.shape.size = self.size
	if show_inverted:
		var distance = Vector2($Anchor.texture.get_width() / 2 + $Inverted.texture.get_width(), 0) / 2
		$Anchor.position = self.size * anchorPoint - distance / 2
		$Inverted.position = self.size * anchorPoint + distance / 2
	else:
		$Anchor.position = self.size * anchorPoint
func update_area_size(change: Vector2 = Vector2.ZERO):
	## a vector giving half the size of the new platform
	var newSize: Vector2 = (self.size + change)
	var posChange = anchorPoint * -change
	$Area2D.position = posChange + newSize / 2
	$Area2D/CollisionShape2D.shape.size = newSize

	var invertedAnchor: Vector2 = Vector2(1 - anchorPoint.x, 1 - anchorPoint.y)
	$Area2D/ShapeCastLeft.position = -newSize / 2 + anchorPoint * newSize
	$Area2D/ShapeCastLeft.target_position = Vector2.LEFT * newSize * anchorPoint
	$Area2D/ShapeCastLeft.shape.a = Vector2.UP * newSize * anchorPoint
	$Area2D/ShapeCastLeft.shape.b = Vector2.DOWN * newSize * invertedAnchor
	$Area2D/ShapeCastLeft.force_shapecast_update()

	$Area2D/ShapeCastRight.position = -newSize / 2 + anchorPoint * newSize
	$Area2D/ShapeCastRight.target_position = Vector2.RIGHT * newSize * invertedAnchor
	$Area2D/ShapeCastRight.shape.a = Vector2.UP * newSize * anchorPoint
	$Area2D/ShapeCastRight.shape.b = Vector2.DOWN * newSize * invertedAnchor
	$Area2D/ShapeCastRight.force_shapecast_update()

	$Area2D/ShapeCastTop.position = -newSize / 2 + anchorPoint * newSize
	$Area2D/ShapeCastTop.target_position = Vector2.UP * newSize * anchorPoint
	$Area2D/ShapeCastTop.shape.a = Vector2.LEFT * newSize * anchorPoint
	$Area2D/ShapeCastTop.shape.b = Vector2.RIGHT * newSize * invertedAnchor
	$Area2D/ShapeCastTop.force_shapecast_update()

	$Area2D/ShapeCastBottom.position = -newSize / 2 + anchorPoint * newSize
	$Area2D/ShapeCastBottom.target_position = Vector2.DOWN * newSize * invertedAnchor
	$Area2D/ShapeCastBottom.shape.a = Vector2.LEFT * newSize * anchorPoint
	$Area2D/ShapeCastBottom.shape.b = Vector2.RIGHT * newSize * invertedAnchor
	$Area2D/ShapeCastBottom.force_shapecast_update()

func _physics_process(_delta):
	if locked || !enabled:
		deactivated = true
	elif enabled && %Player && %Player.is_on_floor():
		deactivated = false

	# dont process physics in editor
	if Engine.is_editor_hint(): return

	if is_resizing():
		add_change(%Camera2D.get_screen_center_position() - camPreviousPos)
		camPreviousPos = %Camera2D.get_screen_center_position()

	if !pending_change.is_zero_approx():
		change_size()

func _process(_delta):
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
		camPreviousPos = %Camera2D.get_screen_center_position()

	if Input.is_action_just_released("LeftMouseDown"):
		resizeLeft = false
		resizeRight = false
		resizeTop = false
		resizeBottom = false
		group.icon_lock(inverted, mouse_inside)

func is_resizing() -> bool:
	return resizeRight || resizeLeft || resizeBottom || resizeTop

func mouse_motion(event: InputEventMouseMotion):
	if is_resizing():
		add_change(event.relative)
		$Anchor.show()
		if show_inverted:
			$Inverted.show()

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

func add_change(change: Vector2):
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
		group.pending_change -= change
	else:
		group.pending_change += change

## Request to change size. Only called when this platform is in no group. If this platform has a
## group the group's [change_size] method is called instead. Which does basically the same, but for
## each child instead.
func change_size():
	validate_change()
	if pending_change.is_zero_approx(): return
	set_new_change()
	pending_change = Vector2.ZERO
	update_collider_size()

func validate_change() -> bool:
	var change: Vector2 = group.pending_change
	if inverted:
		change = -change

	update_area_size(change)

	var fraction: float
	var direction: Vector2 = Vector2.ZERO
	var fractionLeft: float = $Area2D/ShapeCastLeft.get_closest_collision_safe_fraction()
	if fractionLeft > fraction && fractionLeft < 1:
		fraction = fractionLeft
		direction = Vector2.RIGHT * (1 - fraction) * $Area2D/ShapeCastLeft.target_position
	var fractionRight: float = $Area2D/ShapeCastRight.get_closest_collision_safe_fraction()
	if fractionRight > fraction && fractionRight < 1:
		fraction = fractionRight
		direction = Vector2.LEFT * (1 - fraction) * $Area2D/ShapeCastRight.target_position
	var fractionTop: float = $Area2D/ShapeCastTop.get_closest_collision_safe_fraction()
	if fractionTop > fraction && fractionTop < 1:
		fraction = fractionTop
		direction = Vector2.DOWN * (1 - fraction) * $Area2D/ShapeCastTop.target_position
	var fractionBottom: float = $Area2D/ShapeCastBottom.get_closest_collision_safe_fraction()
	if fractionBottom > fraction && fractionBottom < 1:
		fraction = fractionBottom
		direction = Vector2.UP * (1 - fraction) * $Area2D/ShapeCastBottom.target_position
	change += direction

	var newSize: Vector2 = get_size() + change
	newSize.x = max(newSize.x, 3 * BORDER_SIZE)
	newSize.y = max(newSize.y, 3 * BORDER_SIZE)
	change = newSize - get_size()

	if inverted:
		change = -change

	var previous_pending_change: Vector2 = group.pending_change
	group.pending_change = change
	return previous_pending_change != change


func set_new_change():
	var change: Vector2 = group.pending_change
	if inverted:
		change = -change

	self.size += change
	self.position += -change * anchorPoint

func _on_mouse_mouse_entered():
	mouse_inside = true
	if !group.is_resizing():
		group.icon_lock(inverted)
func _on_mouse_mouse_exited():
	mouse_inside = false
	if !group.is_resizing():
		group.icon_lock(inverted, false)

func icon_lock(inv: bool, s: bool = true):
	if s:
		$Anchor.show()
		show_inverted = inv != inverted
		if show_inverted:
			update_collider_size()
			show_inverted = true
			$Inverted.show()
		else:
			$Inverted.hide()
		
	else:
		$Anchor.hide()
		$Inverted.hide()

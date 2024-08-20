@tool
extends Node
class_name PlatformGroup

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() == 0:
		return ["This PlatformGroup has no Platform and can be deleted."]

	var warnings: PackedStringArray = []
	for child in get_children():
		if child is Platform:
			continue
		warnings.append("The node '%s' is of type '%s'. PlatformGroup only accepts type 'Platform'." % [child.name, child.get_class()])
	return warnings

@export var color: Color

var pending_change: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		update_configuration_warnings()
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	if !pending_change.is_zero_approx():
		change_size()

func change_size():
	for child: Platform in get_children():
		if !child.validate_change(): continue
		if pending_change.is_zero_approx(): return

	for child: Platform in get_children():
		child.set_new_change()

	pending_change = Vector2.ZERO
	update_collider_size()

func update_collider_size():
	for child: Platform in get_children():
		child.update_collider_size()

func icon_lock(inv: bool, s: bool = true):
	for child: Platform in get_children():
		child.icon_lock(inv, s)

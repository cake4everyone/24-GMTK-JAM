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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func change_size(change: Vector2):
	for child: Platform in get_children():
		change = child.validate_change(change)
		if change.is_zero_approx(): return

	for child: Platform in get_children():
		child.set_new_change(change)

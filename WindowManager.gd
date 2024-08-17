extends Control

var colShape: CollisionShape2D

var start: Vector2
var initialPos: Vector2
var isMoving := false
var isResizing := false
var resizeX: bool
var resizeY: bool
var initialSize: Vector2
var newWidth := 1
var newHeight := 1

func _ready():
	colShape = get_node("StaticBody2D/CollisionShape2D")
	print("1: " + str(colShape))
	colShape.shape.size = Vector2(get_size().x, get_size().y)
	colShape.global_position = Vector2(get_position().x + (get_size().x / 2), get_position().y + (get_size().y / 2))
	print("2: " + str(colShape))

func _input(event):
	if Input.is_action_just_pressed("LeftMouseDown"):
		var rect: Rect2 = get_global_rect()
		var localMousePos: Vector2 = event.position - get_global_position()
		
		if (localMousePos.x < rect.size.x && localMousePos.x >= rect.size.x - 20 && localMousePos.y > 0 && localMousePos.y < rect.size.y):
			start.x = event.position.x
			initialSize.x = get_size().x
			resizeX = true
			isResizing = true
			print("1 right")
			
		if (localMousePos.y < rect.size.y && localMousePos.y >= rect.size.y - 20 && localMousePos.x > 0 && localMousePos.x < rect.size.x):
			start.y = event.position.y
			initialSize.y = get_size().y
			resizeY = true
			isResizing = true
			print("2 down")
			
		if (localMousePos.x > 0 && localMousePos.x <= 20 && localMousePos.y > 0 && localMousePos.y < rect.size.y):
			start.x = event.position.x
			initialPos.x = get_global_position().x
			initialSize.x = get_size().x
			resizeX = true
			isResizing = true
			print("3 left")
			
		if (localMousePos.y > 0 && localMousePos.y <= 20 && localMousePos.x > 0 && localMousePos.x < rect.size.x):
			start.y = event.position.y
			initialPos.y = get_global_position().y
			initialSize.y = get_size().y
			resizeY = true
			isResizing = true
			print("4 up")
				
			
	if Input.is_action_pressed("LeftMouseDown"):
		if (isResizing):
			newWidth = get_size().x
			newHeight = get_size().y
			
			if (resizeX):
				newWidth = initialSize.x - (start.x - event.position.x)
			if (resizeY):
				newHeight = initialSize.y - (start.y - event.position.y)
				
			if (initialPos.x != 0):
				newWidth = initialSize.x + (start.x - event.position.x)
				set_position(Vector2(initialPos.x - (newWidth - initialSize.x), get_position().y))
				
			if (initialPos.y != 0):
				newHeight = initialSize.y + (start.y - event.position.y)
				set_position(Vector2(get_position().x, initialPos.y - (newHeight - initialSize.y)))
			
			
			set_size(Vector2(newWidth, newHeight))
			colShape.shape.size = Vector2(newWidth, newHeight)
			colShape.global_position = Vector2(get_position().x + (newWidth / 2), get_position().y + (newHeight / 2))
			print(colShape)
		
		
	if Input.is_action_just_released("LeftMouseDown"):
		initialPos = Vector2(0, 0)
		resizeX = false
		resizeY = false
		isResizing = false

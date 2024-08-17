extends StaticBody2D

signal Enable
signal Disable

func enable(en):
	Enable.emit(en)

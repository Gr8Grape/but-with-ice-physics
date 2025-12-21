extends Node


var mass = 0

func _process(_delta: float) -> void:
	$"CanvasLayer/mass value".text = str(mass)

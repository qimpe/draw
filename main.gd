extends Control
"""extends Node

@export var stroke_scene: PackedScene # Сюда перетащи BrushStroke.tscn в инспекторе
var current_stroke: BrushStroke = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			#var global_pos = get_global_mouse_position() 
			start_drawing(global_pos)
		else:
			stop_drawing()

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and current_stroke:
		#current_stroke.add_point(get_global_mouse_position())




func start_drawing(pos:Vector2)->void:
	current_stroke = stroke_scene.instantiate()
	current_stroke.color = Color.BLACK # Или любой другой
	current_stroke.size = 5.0
	add_child(current_stroke)
	current_stroke.add_point(pos)

func stop_drawing():
	current_stroke=null
"""

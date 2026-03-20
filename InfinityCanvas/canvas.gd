extends SubViewportContainer
class_name InfiniteCanvas



const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")


@onready var _brush_tool
@onready var _camera=$SubViewport/Camera2D
@onready var _strokes=$SubViewport/Strokes

func _gui_input(event: InputEvent) -> void:
	_process_event(event)

var is_drawing = false
var current_stroke = null

func _process_event(event: InputEvent) -> void:
	if !get_viewport().is_input_handled():
		_camera.tool_event(event)

	if !get_viewport().is_input_handled():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_drawing = true
				var world_pos = _camera.get_canvas_transform().affine_inverse() * event.position
				start_drawing(world_pos, 1)
			else:
				stop_drawing()

		# Проверка на движение (процесс рисования)
		if event is InputEventMouseMotion and is_drawing:
			if current_stroke:
				var world_pos = _camera.get_canvas_transform().affine_inverse() * event.position
				current_stroke.add_point(world_pos, event.pressure)
	


func start_drawing(pos: Vector2, pressure: float) -> void:
	current_stroke = BRUSH_STROKE.instantiate()
	current_stroke.color = Color.BLACK # Или любой другой
	current_stroke.size = 5.0
	_strokes.add_child(current_stroke)
	current_stroke.add_point(pos, pressure)

func stop_drawing():
	is_drawing = false
	current_stroke=null

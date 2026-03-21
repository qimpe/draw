extends SubViewportContainer
class_name InfiniteCanvas



const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")


@onready var _camera=$SubViewport/Camera2D
@onready var strokes=$SubViewport/Strokes
@onready var brush_tool = BrushTool.new()
@onready var eraser_tool = EraserTool.new()


var active_tool=null

func _ready():
	add_child(brush_tool)
	add_child(eraser_tool)
	active_tool=brush_tool



func _gui_input(event: InputEvent) -> void:
	_process_event(event)



func _process_event(event: InputEvent) -> void:
	# 1. Сначала даем камере обработать ввод (зум, панорамирование)

	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		active_tool = eraser_tool
		print("Переключено на ластик")
		accept_event()
		return 

	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		active_tool = brush_tool
		print("Переключено на ластик")
		accept_event()
		return 

	

	if !get_viewport().is_input_handled():
		_camera.handle_input(event)
		
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_camera.handle_input(event)
		return

	if !get_viewport().is_input_handled():
		if active_tool == brush_tool:
			active_tool.handle_input(event, strokes,_camera)
		elif active_tool == eraser_tool:
			active_tool.handle_input(event, _camera,strokes )





"""func _process_event(event: InputEvent) -> void:
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
	"""


"""func start_drawing(pos: Vector2, pressure: float) -> void:
	current_stroke = BRUSH_STROKE.instantiate()
	current_stroke.color = current_brush_color
	current_stroke.size = current_brush_size
	strokes.add_child(current_stroke)
	current_stroke.add_point(pos, pressure)

func stop_drawing():
	is_drawing = false
	current_stroke=null
"""

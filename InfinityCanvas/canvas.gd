extends SubViewportContainer
class_name InfiniteCanvas



const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")


@onready var _camera=$SubViewport/Camera2D
@onready var strokes=$SubViewport/Strokes
@onready var brush_tool = BrushTool.new()
@onready var eraser_tool = EraserTool.new()


var active_tool=null

func _ready():
	EventBus.eraser_tool_active.connect(func():active_tool=eraser_tool)
	EventBus.brush_tool_active.connect(func():active_tool=brush_tool)
	EventBus.open_file.connect(load_from_json)
	EventBus.save_file.connect(save_to_json)
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



func save_to_json(path: String):
	var data = {
		"strokes": []
	}
	
	# Собираем данные из всех узлов-штрихов
	for stroke in strokes.get_children():
		if stroke is BrushStroke:
			var stroke_data = {
				"points": [],
				"color": stroke.line.default_color.to_html(),
				"width": stroke.line.width
			}
			# Превращаем Vector2 в массив [x, y]
			for p in stroke.points:
				stroke_data["points"].append([p.x, p.y])
			
			data["strokes"].append(stroke_data)
	
	# Записываем в файл
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("Файл сохранен: ", path)

func load_from_json(path: String):
	if not FileAccess.file_exists(path):
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_string)
	if data == null:
		return
	
	# Очищаем текущий холст перед загрузкой
	for child in strokes.get_children():
		child.queue_free()
		
	# Восстанавливаем штрихи
	for s_data in data["strokes"]:
		var new_stroke = BRUSH_STROKE.instantiate()
		strokes.add_child(new_stroke)
		
		# Настраиваем параметры
		new_stroke.line.default_color = Color(s_data["color"])
		new_stroke.line.width = s_data["width"]
		
		# Заполняем точки
		for p_array in s_data["points"]:
			var pos = Vector2(p_array[0], p_array[1])
			new_stroke.add_point(pos) # Не забудь, что add_point должен добавлять и в массив, и в Line2D


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

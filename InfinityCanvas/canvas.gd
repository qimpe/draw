extends SubViewportContainer
class_name InfiniteCanvas

## Главный компонент бесконечного холста.
## Управляет инструментами, вводом, undo/redo и сохранением/загрузкой.

const BRUSH_STROKE: PackedScene = preload("res://BrushStroke/BrushStroke.tscn")

@onready var _camera: Camera2D = $SubViewport/Camera2D
@onready var strokes: Node = $SubViewport/Strokes
@onready var brush_tool: BrushTool = BrushTool.new()
@onready var eraser_tool: EraserTool = EraserTool.new()

var active_tool: Node
var undo_stack: Array[BrushStroke] = []
var redo_stack: Array[BrushStroke] = []

func _ready() -> void:
	_connect_signals()
	_initialize_tools()

func _connect_signals() -> void:
	EventBus.eraser_tool_active.connect(func(): active_tool = eraser_tool)
	EventBus.brush_tool_active.connect(func(): active_tool = brush_tool)
	EventBus.stroke_ended.connect(_on_stroke_ended)
	EventBus.open_file.connect(load_from_json)
	EventBus.save_file.connect(save_to_json)
	EventBus.undo.connect(undo_stroke)
	EventBus.redo.connect(redo_stroke)

func _initialize_tools() -> void:
	add_child(brush_tool)
	add_child(eraser_tool)
	active_tool = brush_tool

func _on_stroke_ended(stroke: BrushStroke) -> void:
	undo_stack.append(stroke)
	redo_stack.clear()

func undo_stroke() -> void:
	if undo_stack.is_empty():
		return
	
	var stroke: BrushStroke = undo_stack.pop_back()
	strokes.remove_child(stroke)
	redo_stack.append(stroke)

func redo_stroke() -> void:
	if redo_stack.is_empty():
		return
	
	var stroke: BrushStroke = redo_stack.pop_back()
	strokes.add_child(stroke)
	undo_stack.append(stroke)

func _gui_input(event: InputEvent) -> void:
	_process_event(event)

func _process_event(event: InputEvent) -> void:
	_handle_tool_shortcuts(event)
	_handle_camera_input(event)
	_handle_tool_input(event)

func _handle_tool_shortcuts(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				active_tool = eraser_tool
				accept_event()
			KEY_B:
				active_tool = brush_tool
				accept_event()

func _handle_camera_input(event: InputEvent) -> void:
	if not get_viewport().is_input_handled():
		_camera.handle_input(event)

func _handle_tool_input(event: InputEvent) -> void:
	if not get_viewport().is_input_handled():
		if active_tool == brush_tool:
			active_tool.handle_input(event, strokes, _camera)
		elif active_tool == eraser_tool:
			active_tool.handle_input(event, _camera, strokes)

func save_to_json(path: String) -> void:
	var data: Dictionary = {"strokes": []}
	
	for stroke in strokes.get_children():
		if stroke is BrushStroke:
			var stroke_data: Dictionary = {
				"points": [],
				"color": stroke.line.default_color.to_html(),
				"width": stroke.line.width
			}
			for point in stroke.points:
				stroke_data["points"].append([point.x, point.y])
			data["strokes"].append(stroke_data)
	
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_from_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_string)
	if data == null:
		return
	
	_clear_canvas()
	_restore_strokes(data["strokes"])

func _clear_canvas() -> void:
	for child in strokes.get_children():
		child.queue_free()
	undo_stack.clear()
	redo_stack.clear()

func _restore_strokes(strokes_data: Array) -> void:
	for stroke_data in strokes_data:
		var new_stroke: BrushStroke = BRUSH_STROKE.instantiate()
		strokes.add_child(new_stroke)
		new_stroke.line.default_color = Color(stroke_data["color"])
		new_stroke.line.width = stroke_data["width"]
		
		for point_array in stroke_data["points"]:
			var pos: Vector2 = Vector2(point_array[0], point_array[1])
			new_stroke.add_point(pos)

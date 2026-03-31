extends Node
class_name BrushTool

## Инструмент рисования кистью.
## Поддерживает ввод с мыши и touch-экранов.

const STROKE_SCENE: PackedScene = preload("res://BrushStroke/BrushStroke.tscn")
const MIN_DISTANCE_BETWEEN_POINTS := 1.0

var is_drawing: bool = false
var current_stroke: BrushStroke = null
var last_position: Vector2 = Vector2.ZERO

var current_brush_size: int = 5
var current_brush_color: Color = Color.WHITE

func _ready() -> void:
	EventBus.brush_size_changed.connect(_on_brush_size_changed)
	EventBus.color_changed.connect(_on_color_changed)

func _on_brush_size_changed(value: float) -> void:
	current_brush_size = int(value)

func _on_color_changed(color: Color) -> void:
	current_brush_color = color

func handle_input(event: InputEvent, strokes_node: Node, camera: Camera2D) -> void:
	if event is InputEventKey:
		return

	var world_pos: Vector2 = camera.get_canvas_transform().affine_inverse() * event.position
	var pressure: float = 1 #_get_pressure(event)

	if _is_start_input(event):
		_start_stroke(world_pos, strokes_node, pressure)
	elif _is_move_input(event) and is_drawing:
		_process_drawing(world_pos, pressure)
	elif _is_end_input(event):
		_end_stroke()

func _is_start_input(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
		   #(event is InputEventScreenTouch and event.pressed and event.pressure and event.pressure >0)

func _is_move_input(event: InputEvent) -> bool:
	return event is InputEventMouseMotion or event is InputEventScreenDrag

func _is_end_input(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or \
		   (event is InputEventScreenTouch and not event.pressed)

func _get_pressure(event: InputEvent) -> float:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		var p = event.pressure
		if p == 0: return 1.0
		return clamp(p, 0.0, 1.0)
		
	if event is InputEventMouseButton:
		return 1.0
	return 1.0
	#var last_pressure=current_stroke.pressures[-1]
	#var actual_pressure = pressure if pressure > 0 else 1.0
	#var mid_pressure: float = (actual_pressure + last_pressure) / 2.0
	#var mid_point: Vector2 = last_position.lerp(pos, 0.5)

func _start_stroke(pos: Vector2, strokes_node: Node, pressure: float) -> void:
	is_drawing = true
	last_position = pos
	current_stroke = STROKE_SCENE.instantiate()
	current_stroke.size = current_brush_size
	current_stroke.color = current_brush_color
	strokes_node.add_child(current_stroke)
	current_stroke.add_point(pos, pressure)

func _process_drawing(pos: Vector2, pressure: float) -> void:
	if not current_stroke:
		return
	
	if pos.distance_to(last_position) > MIN_DISTANCE_BETWEEN_POINTS:
		var last_pressure=current_stroke.pressures[-1]
		var actual_pressure = pressure if pressure > 0 else 1.0
		var mid_pressure: float = (actual_pressure + last_pressure) / 2.0
		var mid_point: Vector2 = last_position.lerp(pos, 0.5)
		
		current_stroke.add_point(mid_point, mid_pressure)
		current_stroke.add_point(pos, mid_pressure)
		last_position = pos

func _end_stroke() -> void:
	is_drawing = false
	if current_stroke:
		EventBus.stroke_ended.emit(current_stroke)
	current_stroke = null

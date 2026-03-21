extends Node
class_name BrushTool

const STROKE_SCENE: PackedScene = preload("res://BrushStroke/BrushStroke.tscn")
const DISTANCE_THRESHOLD = 1.0 

var is_drawing = false
var current_stroke: BrushStroke = null
var last_pos := Vector2.ZERO


var current_brush_size:int=5
var current_brush_color:Color=Color.WHITE



 
func _ready() -> void:
	EventBus.brush_size_changed.connect(func(v): current_brush_size = v)
	EventBus.color_changed.connect(func(c): current_brush_color = c)

func handle_input(event: InputEvent, strokes_node: Node, camera: Camera2D):
	if event is InputEventKey:
		return
	# Считаем мировую позицию один раз
	var world_pos = camera.get_canvas_transform().affine_inverse() * event.position
	
	# 1. Начало (Мышь или Тач)
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or \
	   (event is InputEventScreenTouch and event.pressed):
		_start_stroke(world_pos, strokes_node)

	# 2. Движение
	elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and is_drawing:
		_process_drawing(world_pos)

	# 3. Конец
	elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or \
		 (event is InputEventScreenTouch and not event.pressed):
		_end_stroke()

func _start_stroke(pos: Vector2, strokes_node: Node):
	is_drawing = true
	last_pos = pos
	current_stroke = STROKE_SCENE.instantiate()
	current_stroke.size=current_brush_size
	current_stroke.color=current_brush_color
	strokes_node.add_child(current_stroke)
	current_stroke.add_point(pos)#* Its a dot
	current_stroke.add_point(pos + Vector2(0.1, 0))

func _process_drawing(pos: Vector2):
	if not current_stroke: return
	
	if pos.distance_to(last_pos) > DISTANCE_THRESHOLD:
		# Сглаживание: берем среднее между прошлой точкой и текущей
		# Это уберет "острые" углы при написании букв
		var mid_point = last_pos.lerp(pos, 0.5)
		
		current_stroke.add_point(mid_point)
		current_stroke.add_point(pos)
		
		last_pos = pos

func _end_stroke():
	is_drawing = false
	current_stroke = null

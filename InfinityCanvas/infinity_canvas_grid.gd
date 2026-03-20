class_name InfinityCanvasGrid
extends Node2D



@export var camera_path: NodePath


var _pattern: int = Types.GridPattern.DOTS
var _camera: Camera2D
var _grid_size := 25
var _grid_color: Color



func _ready() -> void:
	_camera=get_node(camera_path)
	_camera.zoom_changed.connect(_on_zoom_changed)
	_camera.position_changed.connect(_on_position_changed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _on_zoom_changed(zoom: float) -> void: queue_redraw()
func _on_position_changed(pos: Vector2) -> void: queue_redraw()
func _on_viewport_size_changed() -> void: queue_redraw()


func enable(event:bool)->void:
	set_process(event)
	visible=event

func set_grid_size(size: int) -> void:
	_grid_size = size
	queue_redraw()


func set_grid_pattern(pattern: int) -> void:
	_pattern = pattern
	queue_redraw()


func set_canvas_color(c: Color) -> void:
	_grid_color = c * 1.25
	queue_redraw()


func _draw() -> void:
	var zoom := (Vector2.ONE / _camera.zoom).x
	var size := Vector2(get_viewport().size.x, get_viewport().size.y) * zoom
	var offset := _camera.offset
	var grid_size := int(ceil((_grid_size * pow(zoom, 0.75))))

	match _pattern:
		Types.GridPattern.DOTS:
			var dot_size := int(ceil(grid_size * 0.12))
			var x_start := int(offset.x / grid_size) - 1
			var x_end := int((size.x + offset.x) / grid_size) + 1
			var y_start := int(offset.y / grid_size) - 1
			var y_end := int((size.y + offset.y) / grid_size) + 1
			
			for x in range(x_start, x_end):
				for y in range(y_start, y_end):
					var pos := Vector2(x, y) * grid_size
					draw_rect(Rect2(pos.x, pos.y, dot_size, dot_size), _grid_color)
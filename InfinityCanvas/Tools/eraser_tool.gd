extends Node
class_name EraserTool

## Инструмент ластика для удаления штрихов.
## Поддерживает ввод с мыши и touch-экранов.

var is_erasing: bool = false
var eraser_radius: float = 20.0

func handle_input(event: InputEvent, camera: Camera2D, strokes_container: Node2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_erasing = event.pressed
		if is_erasing:
			_check_collision(event.position, camera, strokes_container)

	elif event is InputEventMouseMotion and is_erasing:
		_check_collision(event.position, camera, strokes_container)

	elif event is InputEventScreenTouch and event.pressed:
		is_erasing = true
		_check_collision(event.position, camera, strokes_container)

	elif event is InputEventScreenTouch and not event.pressed:
		is_erasing = false

	elif event is InputEventScreenDrag and is_erasing:
		_check_collision(event.position, camera, strokes_container)

func _check_collision(screen_pos: Vector2, camera: Camera2D, strokes_container: Node2D) -> void:
	var world_pos: Vector2 = camera.get_canvas_transform().affine_inverse() * screen_pos
	
	for stroke in strokes_container.get_children():
		if stroke is BrushStroke and _is_stroke_in_eraser_range(stroke, world_pos):
			stroke.queue_free()

func _is_stroke_in_eraser_range(stroke: BrushStroke, world_pos: Vector2) -> bool:
	if stroke.points.size() < 2:
		return false
	
	for i in range(stroke.points.size() - 1):
		var intersection: float = Geometry2D.segment_intersects_circle(
			stroke.points[i],
			stroke.points[i + 1],
			world_pos,
			eraser_radius
		)
		if intersection >= 0:
			return true
	
	return false

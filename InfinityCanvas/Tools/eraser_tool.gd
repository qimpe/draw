extends Node
class_name EraserTool

var is_erasing := false
var eraser_radius := 20.0

func handle_input(event: InputEvent, camera: Camera2D, strokes_container: Node2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_erasing = event.pressed
		if is_erasing:
			_check_collision(event.position, camera, strokes_container)

	if event is InputEventMouseMotion and is_erasing:
		_check_collision(event.position, camera, strokes_container)

func _check_collision(mouse_pos: Vector2, camera: Camera2D, strokes_container: Node2D) -> void:
	# Переводим мышь в мировые координаты
	var world_mouse_pos = camera.get_canvas_transform().affine_inverse() * mouse_pos
	
	# Проходим по всем нарисованным штрихам
	for stroke in strokes_container.get_children():
		if stroke is BrushStroke:
			if _is_mouse_over_stroke(stroke, world_mouse_pos):
				stroke.queue_free() # Удаляем штрих целиком

func _is_mouse_over_stroke(stroke: BrushStroke, mouse_world_pos: Vector2) -> bool:
	# Если у штриха меньше 2 точек, его нельзя проверить как сегмент
	if stroke.points.size() < 2:
		return false
	
	# Проверяем каждый сегмент линии (от точки А до точки Б)
	for i in range(stroke.points.size() - 1):
		var p1 = stroke.points[i]
		var p2 = stroke.points[i+1]
		
		# Главная математическая проверка:
		# Пересекает ли отрезок (p1, p2) круг ластика?
		# Возвращает -1, если не пересекает, или 0-1, если пересекает.
		var intersect = Geometry2D.segment_intersects_circle(p1, p2, mouse_world_pos, eraser_radius)
		
		if intersect >= 0:
			return true
	return false
extends Camera2D

## Камера для бесконечного холста.
## Поддерживает зум (колёсико мыши, pinch), панорамирование (перетаскивание) и touch-ввод.

signal zooming_toggled(value: bool)
signal zoom_changed(value: float)
signal panning_toggled(value: bool)
signal position_changed(value: Vector2)

const ZOOM_INCREMENT: float = 1.1
const MIN_ZOOM_LEVEL: float = 0.1
const MAX_ZOOM_LEVEL: float = 100.0
const KEYBOARD_PAN_CONSTANT: float = 20.0

var _current_zoom_level: float = 1.0
var _start_mouse_pos: Vector2 = Vector2.ZERO

var _touch_events: Dictionary = {}
var _touch_last_drag_distance: float = 0.0
var _touch_last_drag_median: Vector2 = Vector2.ZERO
var _multidrag_valid: bool = false

var _can_move: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_handle_touch_event(event)

func _handle_touch_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_events[event.index] = event
			_multidrag_valid = false
		else:
			_touch_events.erase(event.index)
		
		if _touch_events.size() > 1:
			get_viewport().set_input_as_handled()
		return

	if _touch_events.size() > 1:
		get_viewport().set_input_as_handled()

	if event is InputEventScreenDrag:
		_touch_events[event.index] = event
		_handle_drag_input()

func _handle_drag_input() -> void:
	if _touch_events.size() == 1:
		var drag_event: InputEventScreenDrag = _touch_events.values()[0]
		_move_camera(drag_event.relative)
	
	elif _touch_events.size() == 2:
		var events: Array = _touch_events.values()
		var median_point: Vector2 = _calculate_median_position(events)
		
		if _multidrag_valid:
			_move_camera(median_point - _touch_last_drag_median)
		
		_touch_last_drag_median = median_point
		
		var world_median: Vector2 = get_canvas_transform().affine_inverse() * median_point
		world_median = get_global_transform().affine_inverse() * world_median
		
		var drag_distance: float = events[0].position.distance_to(events[1].position)
		var delta: float = (drag_distance - _touch_last_drag_distance) * _current_zoom_level / 800.0
		
		if _multidrag_valid:
			_zoom_canvas(_current_zoom_level + delta, world_median)
		
		_touch_last_drag_distance = drag_distance
		_multidrag_valid = true
	
	get_viewport().set_input_as_handled()

func _calculate_median_position(events: Array) -> Vector2:
	var median: Vector2 = Vector2.ZERO
	for e in events:
		median += e.position
	return median / events.size()

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_do_zoom_scroll(-1)
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				_do_zoom_scroll(1)
		MOUSE_BUTTON_MIDDLE:
			_can_move = event.is_pressed()

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _can_move:
		_move_camera(event.relative)
		get_viewport().set_input_as_handled()

func _move_camera(pan: Vector2) -> void:
	offset -= pan * (1.0 / _current_zoom_level)
	position_changed.emit(offset)
	get_viewport().set_input_as_handled()

func _do_zoom_scroll(step: int) -> void:
	var new_zoom: float = _to_nearest_zoom_step(_current_zoom_level) * pow(ZOOM_INCREMENT, step)
	_zoom_canvas(new_zoom, get_local_mouse_position())

func _zoom_canvas(target_zoom: float, anchor: Vector2) -> void:
	target_zoom = clamp(target_zoom, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	
	if target_zoom == _current_zoom_level:
		return

	var zoom_center: Vector2 = anchor - offset
	var ratio: float = _current_zoom_level / target_zoom - 1.0
	offset -= zoom_center * ratio
	
	_current_zoom_level = target_zoom
	zoom = Vector2(_current_zoom_level, _current_zoom_level)
	zoom_changed.emit(_current_zoom_level)

func _to_nearest_zoom_step(zoom_level: float) -> float:
	zoom_level = clamp(zoom_level, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	zoom_level = round(log(zoom_level) / log(ZOOM_INCREMENT))
	return pow(ZOOM_INCREMENT, zoom_level)

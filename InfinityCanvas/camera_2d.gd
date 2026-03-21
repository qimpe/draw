extends Camera2D

# -------------------------------------------------------------------------------------------------
signal zooming_toggled(value: bool)
signal zoom_changed(value: float)
signal panning_toggled(value: bool)
signal position_changed(value: Vector2)

# -------------------------------------------------------------------------------------------------
const ZOOM_INCREMENT := 1.1
const MIN_ZOOM_LEVEL := 0.1
const MAX_ZOOM_LEVEL := 100
const KEYBOARD_PAN_CONSTANT := 20



var _current_zoom_level := 1.0
var _start_mouse_pos := Vector2(0.0, 0.0)
# -------------------------------------------------------------------------------------------------
var _touch_events = {}
var _touch_last_drag_distance := 0.0
var _touch_last_drag_median := Vector2.ZERO
var _multidrag_valid = false

var _can_zoom:=false
var _can_move:=false


	
func touch_event(event):
	"""Collect data of touching"""
	# Keep track of the fingers on the screen

	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_events[event.index] = event
			_multidrag_valid = false
		else:
			_touch_events.erase(event.index)
		get_viewport().set_input_as_handled()

	if _touch_events.size() > 1:
			get_viewport().set_input_as_handled()

	if event is InputEventScreenDrag:
		_touch_events[event.index] = event
		# At least one fing drag
		if _touch_events.size() == 1:
			_move_camera(event.relative)
		if _touch_events.size() == 2:
			var events = []
			for key in _touch_events.keys():
				events.append(_touch_events.get(key))

			var median_point = Vector2.ZERO
			for e in events:
				median_point += e.position
			median_point /= events.size()
			if _multidrag_valid:
				_move_camera(median_point - _touch_last_drag_median)
			_touch_last_drag_median = median_point
			median_point = get_canvas_transform().affine_inverse() * median_point
			median_point = get_global_transform().affine_inverse() * median_point

			var drag_distance = events[0].position.distance_to(events[1].position)
			var delta = (drag_distance - _touch_last_drag_distance) * _current_zoom_level / 800
			if _multidrag_valid:
				_zoom_canvas(_current_zoom_level + delta, median_point)
			_touch_last_drag_distance = drag_distance
			_multidrag_valid = true
		get_viewport().set_input_as_handled()



func _input(event):
	touch_event(event)


func handle_input(event:InputEvent):
	"""Handle the data of touch event"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_do_zoom_scroll(-1)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				_do_zoom_scroll(1)

		if event.button_index==MOUSE_BUTTON_MIDDLE:
			_can_move = event.is_pressed()

	if event is InputEventMouseMotion:
		if _can_move:
			_move_camera(event.relative)
			get_viewport().set_input_as_handled()


# -------------------------------------------------------------------------------------------------
func _move_camera(pan: Vector2) -> void:
	offset -= pan * (1.0 / _current_zoom_level)
	position_changed.emit(offset)
	get_viewport().set_input_as_handled()

# -------------------------------------------------------------------------------------------------
func _do_zoom_scroll(step: int) -> void:
	var new_zoom := _to_nearest_zoom_step(_current_zoom_level) * pow(ZOOM_INCREMENT, step)
	_zoom_canvas(new_zoom, get_local_mouse_position())

# -------------------------------------------------------------------------------------------------
func _do_zoom_drag(delta: float) -> void:
	delta *= _current_zoom_level / 100
	_zoom_canvas(_current_zoom_level - delta, _start_mouse_pos)

# -------------------------------------------------------------------------------------------------
func _zoom_canvas(target_zoom: float, anchor: Vector2) -> void:
	target_zoom = clamp(target_zoom, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	
	if target_zoom == _current_zoom_level:
		return

	# Pan canvas to keep content fixed under the cursor
	var zoom_center := anchor - offset
	var ratio := _current_zoom_level / target_zoom - 1.0
	offset -= zoom_center * ratio
	
	_current_zoom_level = target_zoom
	
	zoom = Vector2(_current_zoom_level, _current_zoom_level)
	zoom_changed.emit(_current_zoom_level)

# -------------------------------------------------------------------------------------------------
func _to_nearest_zoom_step(zoom_level: float) -> float:
	zoom_level = clamp(zoom_level, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	zoom_level = round(log(zoom_level) / log(ZOOM_INCREMENT))
	return pow(ZOOM_INCREMENT, zoom_level)

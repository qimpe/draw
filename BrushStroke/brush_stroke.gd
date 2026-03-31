extends Node2D
class_name BrushStroke

@onready var line: Line2D = $Line2D

var points: Array[Vector2] = []
var pressures: Array[float] = []
var size: float = 10.0
var color: Color = Color.BLACK
var width_curve: Curve

func _ready() -> void:
	width_curve = Curve.new()
	_configure_line_appearance()

func _configure_line_appearance() -> void:
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	line.round_precision = 32
	line.antialiased = true
	line.width = size
	line.texture = BrushStrokeTexture.texture
	line.clear_points()

func add_point(pos: Vector2, pressure: float = 1.0) -> void:
	points.append(pos)
	pressures.append(pressure)
	line.add_point(pos)
	_update_width_curve()

func _update_width_curve() -> void:
	width_curve.clear_points()
	for i in pressures.size():
		var t: float = float(i) / max(pressures.size() - 1, 1)
		width_curve.add_point(Vector2(t, pressures[i]))
	line.width_curve = width_curve
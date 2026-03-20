extends Node2D
class_name BrushStroke

@onready var line = $Line2D

var points: Array[Vector2] = []
var size: float = 10.0
var color: Color = Color.BLACK
var pressure_curve: Curve = Curve.new()

func _ready() -> void:
	line.default_color = color
	line.texture = BrushStrokeTexture.texture
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	line.width = size
	line.width_curve = pressure_curve
	line.clear_points()

func add_point(pos: Vector2, pressure: float = 1.0):
	points.append(pos)
	line.add_point(pos)
	var t = float(line.get_point_count()) / 100.0 # упрощенно
	pressure_curve.add_point(Vector2(t, pressure))

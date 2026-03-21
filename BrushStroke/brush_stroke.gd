extends Node2D
class_name BrushStroke

@onready var line = $Line2D

var points: Array[Vector2] = []
var pressures: Array[float] = []
var size: float = 10.0
var color: Color = Color.BLACK

# Настройка из примера: плавное изменение давления
const MAX_PRESSURE_DIFF := 0.1 

func _ready() -> void:
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.width = size
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	line.texture = BrushStrokeTexture.texture
	line.round_precision=16
	line.clear_points()


func add_point(pos: Vector2, pressure: float = 1.0):
	points.append(pos)
	line.add_point(pos)




extends Control

## Визуальная сетка бесконечного холста.
## Отображает фоновый узор сетки с учётом позиции и зума камеры.

@export var camera_path: NodePath
@onready var grid_visual: ColorRect = $CanvasLayer/GridVisual
var _camera: Camera2D

func _ready() -> void:
	_camera = get_node(camera_path)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid_visual.color = Color("#030719")
	grid_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	if not _camera:
		return
	
	var mat: ShaderMaterial = grid_visual.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("camera_offset", _camera.offset)
		mat.set_shader_parameter("zoom", _camera.zoom.x)
		mat.set_shader_parameter("dot_color", Color(1, 1, 1, 0.3))

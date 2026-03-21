extends Control # Убедись, что тип Control!

@export var camera_path: NodePath
@onready var grid_visual: ColorRect = $CanvasLayer/GridVisual # Ссылка на ColorRect с шейдером
var _camera: Camera2D

func _ready() -> void:
	_camera = get_node(camera_path)
	# Делаем сетку невидимой для мыши, чтобы не мешала рисовать
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	if not _camera: return
	
	# Вывод в консоль или на экран (Label)
	# Сравни эти числа с тем, что ты видишь при движении
	print("Camera Offset: ", _camera.offset, " | Global Pos: ", _camera.global_position)

	var mat = grid_visual.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("camera_offset", _camera.offset)
		mat.set_shader_parameter("zoom", _camera.zoom.x)

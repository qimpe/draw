extends Node

@onready var _project_card:Control=%ProjectCard
@onready var _project_name_label:LineEdit=%ProjectCard/Control/MarginContainer/LineEdit

@export var _draw_scene:PackedScene


func _ready() -> void:
	_project_card.visible=false

func create_project_modal()-> void:
	_project_card.visible=true

func close_create_project_model()-> void:
	_project_card.visible=false
	_project_name_label.clear()

func delete()-> void:
	pass


func load()-> void:
	pass


func save(path: String)-> void:
	var data: Dictionary = {"strokes": []}
	for stroke in strokes.get_children():
		if stroke is BrushStroke:
			var stroke_data: Dictionary = {
				"points": [],
				"color": stroke.line.default_color.to_html(),
				"width": stroke.line.width
			}
			for point in stroke.points:
				stroke_data["points"].append([point.x, point.y])
			data["strokes"].append(stroke_data)
	
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()



#* ui handlers

func _on_cancel_create_project_button_pressed() -> void:
	close_create_project_model()


func _on_open_create_project_button_pressed() -> void:
	create_project_modal()


func _on_create_button_pressed() -> void:
	ProjectManager.active_project=Project.new()
	ProjectManager.active_project.metadata["name"]=_project_name_label.text
	get_tree().change_scene_to_packed(_draw_scene)

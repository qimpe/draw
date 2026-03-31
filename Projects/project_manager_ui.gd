extends Node

@onready var _project_card:Control=%ProjectCard
@onready var _project_name_label:LineEdit=%ProjectCard/Control/MarginContainer/LineEdit

@export var _draw_scene:PackedScene


func _ready() -> void:
	_project_card.visible=false




#* ui handlers

func create_project_modal()-> void:
	_project_card.visible=true

func close_create_project_model()-> void:
	_project_card.visible=false
	_project_name_label.clear()

#* ui handlers signals
func _on_cancel_create_project_button_pressed() -> void:
	close_create_project_model()


func _on_open_create_project_button_pressed() -> void:
	create_project_modal()


func _on_create_button_pressed() -> void:
	ProjectManager.active_project=Project.new()
	ProjectManager.active_project.metadata["name"]=_project_name_label.text
	get_tree().change_scene_to_packed(_draw_scene)


func _on_open_project_button_pressed() -> void:
	ProjectManager.load_from_filesystem()

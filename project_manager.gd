extends Node

@onready var file_dialog:FileDialog=$FileDialog


@export var active_project:Project
@export var selected_path:String
@export var _draw_scene:PackedScene


enum Action{LOAD,SAVE}

var action

func _ready() -> void:
	#EventBus.save_project_button_pressed.connect(save_in_filesystem)
	file_dialog.file_selected.connect(_on_file_selected)
	

func save_in_filesystem()-> void:
	action=Action.SAVE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	file_dialog.add_filter("*.json", "JSON Canvas Data")
	if not ProjectManager.active_project.filepath:
		file_dialog.popup_centered()
	else:
		_execute_save(ProjectManager.active_project.filepath)

func _on_file_selected(path:String)->void:
	#ProjectManager.active_project.filepath=path
	selected_path=path
	if action==Action.SAVE:
		_execute_save(selected_path)
	else:
		print(selected_path)
		_execute_load()

func _execute_save(path:String):
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(ProjectManager.active_project.metadata["data"]))
		file.close()



func load_from_filesystem() -> void:
	action=Action.LOAD
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.json", "JSON Canvas Data")
	file_dialog.popup_centered()


func _execute_load()->void:
	if not FileAccess.file_exists(selected_path):
		print(2)
		return
	
	var file: FileAccess = FileAccess.open(selected_path, FileAccess.READ)
	if not file:
		print(1)
		return


	var project=Project.new()
	
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_string)
	project.metadata["data"]=data
	ProjectManager.active_project=project
	ProjectManager.active_project.filepath=selected_path
	if data == null:
		print(3)
		return
	print("Пытаюсь перейти на сцену: ", _draw_scene)
	get_tree().change_scene_to_packed(_draw_scene)

func delete()-> void:
	pass

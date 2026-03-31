extends Panel


@onready var project_label:Label= $MarginContainer/HBoxContainer/Label



func _ready() -> void:
	if ProjectManager.active_project: #!
		project_label.text=ProjectManager.active_project.metadata.get("name")

func _on_menu_button_pressed() -> void:
	EventBus.menu_button_pressed.emit()

func _on_color_picker_button_color_changed(color: Color) -> void:
	EventBus.color_changed.emit(color)


func _on_color_picker_button_pressed() -> void:
	pass # Replace with function body.

func _on_color_changed(color: Color) -> void:
	EventBus.color_changed.emit(color)

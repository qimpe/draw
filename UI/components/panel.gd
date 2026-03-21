extends Panel


func _on_eraser_button_pressed() -> void:
	EventBus.eraser_tool_active.emit()


func _on_brush_button_pressed() -> void:
	EventBus.brush_tool_active.emit()

func _on_menu_button_pressed()->void:
	EventBus.menu_button_pressed.emit()
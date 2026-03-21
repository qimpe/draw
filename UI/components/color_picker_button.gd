extends ColorPickerButton


func _on_color_changed(color: Color) -> void:
	EventBus.color_changed.emit(color)

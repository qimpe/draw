extends Panel

## Панель инструментов.
## Содержит кнопки выбора инструментов и управления историей действий.

func _on_eraser_button_pressed() -> void:
	EventBus.eraser_tool_active.emit()

func _on_brush_button_pressed() -> void:
	EventBus.brush_tool_active.emit()

func _on_redo_button_pressed() -> void:
	EventBus.redo.emit()

func _on_undo_button_pressed() -> void:
	EventBus.undo.emit()

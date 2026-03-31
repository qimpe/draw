extends Node

## Глобальная шина событий для коммуникации между компонентами приложения.
## Использует сигналы для оповещения об изменениях состояния UI и действиях пользователя.

signal brush_size_changed(value: float)
signal color_changed(color: Color)
signal eraser_tool_active
signal brush_tool_active
signal menu_button_pressed
signal open_file(path: String)
signal save_file(path: String)
signal save_project_button_pressed()
signal stroke_ended(stroke: BrushStroke)
signal redo()
signal undo()

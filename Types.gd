extends Node

## Глобальные типы и перечисления для приложения MyDraw.
## Используются как общие константы для типизации и настройки UI.

enum Tool {
	BRUSH,
	RECTANGLE,
	CIRCLE,
	LINE,
	ERASER,
	SELECT,
}

enum GridPattern {
	DOTS,
	LINES,
	NONE
}

static var UIThemeArray: Array[String] = ["dark", "light"]

enum UITheme {
	DARK,
	LIGHT
}

enum BrushRoundingType {
	FLAT = 0,
	ROUNDED = 1
}

enum UIScale {
	AUTO,
	CUSTOM
}

class CanvasInfo:
	var point_count: int
	var stroke_count: int
	var current_pressure: float
	var selected_lines: int
	var pen_inverted: bool

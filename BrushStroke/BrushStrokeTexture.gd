extends Node

## Генератор текстуры для сглаженных линий.
## 
## Адаптировано из: https://github.com/godot-extended-libraries/godot-antialiased-line2d
## MIT License
## 
## Генерирует текстуру с mipmap для Line2D, чтобы линии выглядели гладко
## при разных уровнях масштабирования. Генерация выполняется один раз при загрузке.

var texture: ImageTexture

func _ready() -> void:
	var data := PackedByteArray()
	for mipmap: int in [256, 128, 64, 32, 16, 8, 4, 2, 1]:
		for y: int in mipmap:
			for x: int in mipmap:
				data.push_back(255)
				
				if mipmap >= 4:
					data.push_back(0 if y == 0 or y == mipmap - 1 else 255)
				elif mipmap == 2:
					data.push_back(0 if y == 1 else 255)
				else:
					data.push_back(128)

	var image := Image.create_from_data(256, 256, true, Image.FORMAT_LA8, data)
	texture = ImageTexture.create_from_image(image)

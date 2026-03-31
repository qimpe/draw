extends VSlider

## Слайдер размера кисти.
## При изменении значения отправляет сигнал в EventBus.

func _value_changed(new_value: float) -> void:
	EventBus.brush_size_changed.emit(new_value)

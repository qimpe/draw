extends VSlider




func _value_changed(new_value: float) -> void:
    EventBus.brush_size_changed.emit(new_value)



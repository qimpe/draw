extends Control

# Используем Enum вместо словаря — это стандарт Godot для типизации
enum MenuID { OPEN_FILE = 0, SAVE_FILE = 1 }

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var file_dialog: FileDialog = $FileDialog

func _ready() -> void:
	_configure_file_dialog()
	# Подключаем сигналы
	EventBus.menu_button_pressed.connect(toggle_menu)
	popup_menu.id_pressed.connect(_on_menu_item_selected)
	file_dialog.file_selected.connect(_on_file_path_confirmed)

# Выносим настройки в отдельный метод, чтобы не забивать _ready
func _configure_file_dialog() -> void:
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true # Использует системное окно Windows/macOS/Android
	file_dialog.add_filter("*.json", "JSON Canvas Data")

# Публичные методы (интерфейс взаимодействия)
func toggle_menu() -> void:
	popup_menu.visible = !popup_menu.visible
	if popup_menu.visible:
		popup_menu.popup_centered()

# Обработка выбора в меню
func _on_menu_item_selected(id: int) -> void:
	match id:
		MenuID.OPEN_FILE:
			_setup_and_show_dialog(FileDialog.FILE_MODE_OPEN_FILE, "Открыть рисунок")
		MenuID.SAVE_FILE:
			_setup_and_show_dialog(FileDialog.FILE_MODE_SAVE_FILE, "Сохранить рисунок")

# Универсальный метод для настройки окна файла
func _setup_and_show_dialog(mode: FileDialog.FileMode, title: String) -> void:
	file_dialog.file_mode = mode
	file_dialog.title = title
	file_dialog.popup_centered_ratio(1) # Окно на 70% экрана — удобно для планшета

# Передача пути в систему
func _on_file_path_confirmed(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		EventBus.open_file.emit(path)
	else:
		EventBus.save_file.emit(path)
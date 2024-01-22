tool
extends PanelContainer

const MESSAGE_MIN_SIZE_EMPTY := Vector2(51, 54)			# Мин. размер пустого сообщения без пометки
const MESSAGE_MIN_SIZE_EDITED_EMPTY := Vector2(109, 54)	# Мин. размер пустого сообщения с пометкой
const TEXT_MAX_LENGTH := 600

export (String, MULTILINE) var text setget set_text		# Текст сообщения
export (String) var time = "00:00" setget set_time		# Время отправки
export (bool) var is_edited = false setget set_edited	# Пометка сообщения "изменено"
export (DynamicFont) var message_font = preload("res://fonts/arial.tres")


# Обновить текст/время сообщения, его размеры
# Менять нужно параметры нода "Message", а не "Panel"
func update_message() -> void:
	var time_formatted: String = time
	var time_tags_start := "[right][font=fonts/arial_time.tres]"
	var time_tags_end := "[/font][/right]"
	
	# Сбрасываем мин. размер сообщения при изменении поля is_edited
	# А также задаём приписку "изменено"
	if is_edited:
		rect_min_size = MESSAGE_MIN_SIZE_EDITED_EMPTY
		time_formatted += ", изменено"
	else:
		rect_min_size = MESSAGE_MIN_SIZE_EMPTY
	
	var lines_count: int = text.count('\n') + 1 # Число строк в сообщении
	print(text) 

	# Записываем текст и время в поле сообщения
	$Text.bbcode_text = text + time_tags_start + time_formatted + time_tags_end


func get_string_pixel_length(string: String) -> Vector2:
	return message_font.get_string_size(string).x


func set_text(value: String):
	text = value
	if Engine.is_editor_hint():
		update_message()


func set_time(value: String):
	time = value
	if Engine.is_editor_hint():
		update_message()


func set_edited(value: bool):
	is_edited = value
	if Engine.is_editor_hint():
		update_message()

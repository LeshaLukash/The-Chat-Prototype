tool
extends MarginContainer

# СООБЩЕНИЕ
# Облачко с текстом сообщения
 
const MIN_SIZE_EMPTY := Vector2(54, 58)			# Мин. размер пустого сообщения без пометки
const MIN_SIZE_EDITED_EMPTY := Vector2(122, 58)	# Мин. размер пустого сообщения с пометкой
const LINE_MAX_LENGTH := 400
const PANEL_ALIGN := 14 
const TIME_TAGS_START := "[right][font=fonts/arial_time.tres]"
const TIME_TAGS_END := "[/font][/right]"

export (DynamicFont) var message_font = preload("res://fonts/arial.tres")
export (DynamicFont) var message_time_font = preload("res://fonts/arial_time.tres")
export (String, MULTILINE) var message_text setget set_message_text		# Текст сообщения
export (String) var message_time = "00:00" setget set_message_time		# Время отправки
export (bool) var is_edited = false setget set_edited	# Пометка сообщения "изменено"


# Обновить текст/время сообщения, его размеры
func update_message() -> void:
	get_longest_text_line(message_text)
	
	# Подгоняем размеры сообщения под размеры текста (самой длинной строки)
	if message_text.empty():
		rect_size = rect_min_size
	else:
		rect_size.x = get_line_pixel_length(message_text) + PANEL_ALIGN # rect_size.y меняет сам RichTextLabel
		
	# Записываем текст и время в поле сообщения
	$Panel/Text.bbcode_text = message_text + TIME_TAGS_START + message_time + TIME_TAGS_END


# Проверка, есть ли в сообщении строки, которые превышают максимальную длину
func contains_long_lines(text: String) -> bool:
	return get_line_pixel_length(get_longest_text_line(text)) > LINE_MAX_LENGTH


# Получить длину строки в пикселях, относительно заданого шрифта
func get_line_pixel_length(string: String) -> float:
	return message_font.get_string_size(string).x


# Получить число строк в сообщении
func get_lines_count(text: String) -> int:
	return text.count('\n') + 1


# Получить самую длинную строку в сообщении
func get_longest_text_line(text: String) -> String:
	if get_lines_count(text) == 1:
		return text
	
	var text_lines: PoolStringArray = text.split('\n')
	var text_lines_sizes: Array = []
	
	# Заполняем массив значениями длин строк исходного текста
	for line in text_lines:
		text_lines_sizes.append(line.length())
	
	var text_line_long_idx: int = text_lines_sizes.find(text_lines_sizes.max()) # Индекс первой самой длинной строки
	
	var result: String = text_lines[text_line_long_idx]
	return result


func set_message_text(value: String):
	message_text = value
	update_message()


func set_message_time(value: String):
	if is_edited:
		value += ", изменено"
	
	message_time = value
	update_message()


func set_edited(value: bool):
	is_edited = value
	if is_edited:
		rect_min_size = MIN_SIZE_EDITED_EMPTY
	else:
		rect_min_size = MIN_SIZE_EMPTY
	update_message()

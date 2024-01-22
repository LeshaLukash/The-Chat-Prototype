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
	
	print(get_longest_text_line())

	# Записываем текст и время в поле сообщения
	$Text.bbcode_text = text + time_tags_start + time_formatted + time_tags_end


# Получить длину строки, в пикселях
func get_string_pixel_length(string: String) -> Vector2:
	return message_font.get_string_size(string).x


# Получить число строк в сообщении
func get_lines_count() -> int:
	return text.count('\n') + 1


# Получить самую длинную строку в сообщении
func get_longest_text_line() -> String:
	if get_lines_count() == 1:
		return text
	
	var longest_line := ""
	var prev_line_break_pos := 0	# Номер предыдущего переноса
	var next_line_break_pos := 0	# Номер следующего переноса
	var substr_length := 0 			# Длина подстроки
	var test_line: String			# Строка, которая проверяется
	
	for i in get_lines_count():
		next_line_break_pos = text.find('\n', prev_line_break_pos) # Находим следующий перенос строки, \n
		substr_length = next_line_break_pos - prev_line_break_pos  # Длина строки равна разнице между следующим и предыдущим переносами строки
		
		if substr_length < 0: # длина подстроки меньше нуля - строка последняя
			test_line = text.substr(prev_line_break_pos) # строка последняя, считываем до конца
		else:
			test_line = text.substr(prev_line_break_pos, substr_length) # Возвращается строка, не включающая последний символ номером substr_length!
		
		if longest_line.length() < test_line.length():
			longest_line = test_line
			
		prev_line_break_pos = next_line_break_pos + 1 	# на единицу больше, т.к. next_line_break_pos хотим искать мимо предыдущего prev_line_break_pos
														# иначе при поиске будет находить сноску под номером prev_line_break_pos
	return longest_line


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

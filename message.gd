tool
extends PanelContainer

# СООБЩЕНИЕ
# Облачко с текстом сообщения
 
const MESSAGE_MIN_SIZE_EMPTY := Vector2(54, 58)			# Мин. размер пустого сообщения без пометки
const MESSAGE_MIN_SIZE_EDITED_EMPTY := Vector2(122, 58)	# Мин. размер пустого сообщения с пометкой
const STRING_MAX_LENGTH := 400
const PANEL_ALIGN := 14 

export (DynamicFont) var message_font = preload("res://fonts/arial.tres")
export (DynamicFont) var message_time_font = preload("res://fonts/arial_time.tres")
export (String, MULTILINE) var message_text setget set_message_text		# Текст сообщения
export (String) var message_time = "00:00" setget set_message_time		# Время отправки
export (bool) var is_edited = false setget set_edited	# Пометка сообщения "изменено"

# Обновить текст/время сообщения, его размеры
func update_message() -> void:
	var time_formatted: String = message_time
	var time_tags_start := "[right][font=fonts/arial_time.tres]"
	var time_tags_end := "[/font][/right]"
	
	# Сбрасываем мин. размер сообщения при изменении поля is_edited
	# А также задаём приписку "изменено"
	if is_edited:
		rect_min_size = MESSAGE_MIN_SIZE_EDITED_EMPTY
		time_formatted += ", изменено"
	else:
		rect_min_size = MESSAGE_MIN_SIZE_EMPTY
		
	# Подгоняем размеры сообщения под размеры текста (самой длинной строки)
	if message_text.empty():
		rect_size = rect_min_size
	else:
		# rect_size.y не трогаем, т.к. его размеры меняет сам RichTextLabel
		rect_size.x = get_string_pixel_length(get_longest_text_line(message_text)) + PANEL_ALIGN
	# Записываем текст и время в поле сообщения
	$Text.bbcode_text = message_text + time_tags_start + time_formatted + time_tags_end


# Проверка, есть ли в сообщении строки, которые превышают максимальную длину
func is_containing_too_long_lines(text: String) -> bool:
	return get_string_pixel_length(get_longest_text_line(text)) > STRING_MAX_LENGTH


# Вычленяем из длинной строки подстроку, после которой нужно поставить перенос
func find_break_pos_substr(line: String) -> String:
	var result: String = ""
	var line_split = line.split(" ")
	var i := 0
	
	if get_string_pixel_length(line_split[i]) > STRING_MAX_LENGTH:
		result = line_split[i]
		while get_string_pixel_length(result) > STRING_MAX_LENGTH:
			result = result.substr(0, result.length() - 1)
	else:
		while get_string_pixel_length(result + line_split[i]) <= STRING_MAX_LENGTH:
			result += line_split[i] + " "
			i += 1

	return result
	

# Получить длину строки в пикселях, относительно заданого шрифта
func get_string_pixel_length(string: String) -> float:
	return message_font.get_string_size(string).x


# Получить число строк в сообщении
func get_lines_count(text: String) -> int:
	return text.count('\n') + 1


# Получить самую длинную строку в сообщении
func get_longest_text_line(text: String) -> String:
	var lines_amount: int = get_lines_count(text)
	if lines_amount == 1:
		return text
	
	# Ищем переносы в сообщении, выбираем между ними строки, сравниваем
	var longest_line := ""			# Самая длинная строка сообщения
	var prev_line_break_pos := 0	# Номер предыдущего переноса
	var next_line_break_pos := 0	# Номер следующего переноса
	var substr_length := 0 			# Длина подстроки
	var test_line: String			# Строка, которая проверяется
	
	# Перебираем строки
	for i in lines_amount:
		next_line_break_pos = text.find('\n', prev_line_break_pos) # Находим следующий перенос строки, \n
		substr_length = next_line_break_pos - prev_line_break_pos  # Длина строки равна разнице между следующим и предыдущим переносами строки
		
		if substr_length < 0: # длина подстроки меньше нуля - строка последняя
			test_line = text.substr(prev_line_break_pos) # строка последняя, считываем до конца
		else:
			test_line = text.substr(prev_line_break_pos, substr_length) # Возвращается строка, не включающая последний символ номером substr_length!
		
		if longest_line.length() <= test_line.length():
			longest_line = test_line
			
		prev_line_break_pos = next_line_break_pos + 1 	# на единицу больше, т.к. next_line_break_pos хотим искать мимо предыдущего prev_line_break_pos
														# иначе при поиске будет находить сноску под номером prev_line_break_pos
	print("longest line: " + longest_line)
	return longest_line


# Удалить по краям строк пробелы, возникшие после её переноса
func clean_start_spaces(text: String) -> String:
	var prev_line_break_pos := 0	# Номер предыдущего переноса
	var next_line_break_pos := 0	# Номер следующего переноса
	var substr_length := 0 			# Длина подстроки
	var test_line: String			# Тестовая строка
	var cleaned_line: String		# Тестовая строка без пробела в начале
	
	for i in get_lines_count(text):
		next_line_break_pos = text.find('\n', prev_line_break_pos) # Находим следующий перенос строки, \n
		substr_length = next_line_break_pos - prev_line_break_pos  # Длина строки равна разнице между следующим и предыдущим переносами строки
		
		if substr_length < 0: # длина подстроки меньше нуля - строка последняя
			test_line = text.substr(prev_line_break_pos) # строка последняя, считываем до конца
		else:
			test_line = text.substr(prev_line_break_pos, substr_length) # Возвращается строка, не включающая последний символ номером substr_length!
		
		prev_line_break_pos = next_line_break_pos + 1 	# на единицу больше, т.к. next_line_break_pos хотим искать мимо предыдущего prev_line_break_pos
														# иначе при поиске будет находить сноску под номером prev_line_break_pos
		
		# Удаляем по краям каждой строки пробелы, если они есть
		cleaned_line = test_line.trim_prefix(" ")
		cleaned_line = cleaned_line.trim_suffix(" ")
		text = text.replace(test_line, cleaned_line)
	return text


func set_message_text(value: String):
	# Расстановка переносов в строках, превышающих максимальную длину
	while is_containing_too_long_lines(value):
		var string_to_break: String = find_break_pos_substr(get_longest_text_line(value))
		# Позиция, куда ставить перенос = начало строки, где нужен перенос + её длина
		var pos_inser_break: int = value.find(string_to_break) + string_to_break.length()
		value = value.insert(pos_inser_break, '\n')
	
	message_text = clean_start_spaces(value)
	if Engine.is_editor_hint():
		update_message()


func set_message_time(value: String):
	message_time = value
	if Engine.is_editor_hint():
		update_message()


func set_edited(value: bool):
	is_edited = value
	if Engine.is_editor_hint():
		update_message()

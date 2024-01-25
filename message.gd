tool
extends MarginContainer

## СООБЩЕНИЕ
# Облачко с текстом сообщения
 
const MIN_SIZE_EMPTY := Vector2(54, 58)			# Мин. размер пустого сообщения без пометки
const MIN_SIZE_EDITED_EMPTY := Vector2(122, 58)	# Мин. размер пустого сообщения с пометкой
const LINE_MAX_LENGTH := 400					# Макс. длина строки сообщения (в пикселях!)
const WORD_MAX_LENGTH := 35 					# Макс. длина слова в русском языке (в символах!)

export (DynamicFont) var message_font = preload("res://fonts/arial.tres")			# Шрифт сообщения
export (DynamicFont) var message_time_font = preload("res://fonts/arial_time.tres")	# Шрифт времени отправки
export (String, MULTILINE) var message_text setget set_message_text					# Текст сообщения
export (String) var message_time = "00:00" setget set_message_time					# Время отправки
export (bool) var is_edited = false setget set_edited								# Пометка сообщения "изменено"


# Обновить текст/время сообщения, его размеры
func update_message() -> void:

	# Подгоняем размеры сообщения под размеры текста (самой длинной строки)
	if message_text.empty():
		rect_size = rect_min_size
	else:
		rect_size.x = get_line_pixel_length(message_text)
	
	# Записываем текст и время в поле сообщения
	var time_tags_start := "[right][font=fonts/arial_time.tres]"
	var time_tags_end := "[/font][/right]"
	$Panel/Text.bbcode_text = message_text + time_tags_start + message_time + time_tags_end


# Вписываем текст сообщения в облако сообщения
func format_msg_text(text: String) -> String:
	var result: String = ""
	var text_lines: PoolStringArray = text.split('\n')
	
	for i in text_lines.size():
		var line: String = text_lines[i]
		
		# Если текущая строка не слишком длинная
		if get_line_pixel_length(line) <= LINE_MAX_LENGTH:
			result += line
		else:
			var line_split: Array = format_line(line)
			for string in line_split:
				result += string # В конце всех строк, кроме последней, перенос будет стоять
		
		# Если строка не последняя - добавляем знак переноса
		if i != text_lines.size() - 1:
			result += '\n'
	return result


# Разбить большую строку на строки поменьше
func format_line(line: String) -> Array:
	if get_line_pixel_length(line) <= LINE_MAX_LENGTH:
		return [line]
	
	var result := []
	var line_words: PoolStringArray = line.split(' ')
	
	for i in line_words:
		var string := ""
		var word: String = line_words[i]
		
		# Разбиваем спам буквами на подслова
		if word.length() > WORD_MAX_LENGTH:
			for j in word.length():
				while get_line_pixel_length(string + word[j]) <= LINE_MAX_LENGTH:
					string += word[j]
				result.append(string)
				string = ""
	
	return result


# Проверка, есть ли в сообщении строки, которые превышают максимальную длину
func contains_long_lines(text: String) -> bool:
	return get_line_pixel_length(get_longest_text_line(text)) > LINE_MAX_LENGTH


# Получить длину строки сообщения в пикселях, относительно заданого шрифта
func get_line_pixel_length(string: String) -> float:
	return message_font.get_string_size(string).x


# Получить число строк в сообщении
func get_lines_count(text: String) -> int:
	return text.count('\n') + 1


# Получить самую длинную строку в сообщении
func get_longest_text_line(text: String) -> String:
	if get_lines_count(text) == 1:
		return text
	
	var text_lines: PoolStringArray = text.split('\n') # Разбиваем текст построчно, заносим в массив
	var text_lines_sizes: Array = [] 
	
	# Заполняем массив значениями длин строк (в пикселях!) исходного текста
	for line in text_lines:
		text_lines_sizes.append(get_line_pixel_length(line))
	
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

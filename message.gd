tool
class_name Message
extends MarginContainer

## СООБЩЕНИЕ
# Поле с текстом сообщения

const PANEL_MIN_SIZE_EMPTY := Vector2(54, 58)	# Мин. размер пустого сообщения, без пометки
const PANEL_MIN_SIZE_EDITED := Vector2(122, 58)	# Мин. размер пустого сообщения, с пометкой
const LINE_MAX_LENGTH := 400					# Макс. длина строки сообщения (в пикселях!)
const WORD_MAX_LENGTH := 35 					# Макс. длина слова в русском языке (в символах!)
const PANEL_ALIGN := 14							# Отступы $Panel по краям от текста (наверное) 
const SCROLL_LINE_WIDTH := 12					# Ширина (в пикселях) линии прокрутки сообщений

const TIME_TAGS_START := "[right][font=fonts/arial_time.tres]"
const TIME_TAGS_END := "[/font][/right]"
const NAME_TAGS_START := "[color=silver][font=fonts/arial_sender_name.tres]"
const NAME_TAGS_END := "[/font][/color]"

export (String) var message_sender = "Отправитель" setget set_message_sender					# Имя отправителя
export (DynamicFont) var message_sender_font = preload("res://fonts/arial_sender_name.tres")	# Шрифт имени отправителя
export (DynamicFont) var message_font = preload("res://fonts/arial.tres")						# Шрифт сообщения
export (DynamicFont) var message_time_font = preload("res://fonts/arial_time.tres")				# Шрифт времени отправки
export (String, MULTILINE) var message_text setget set_message_text								# Текст сообщения
export (String) var message_time = "00:00" setget set_message_time								# Время отправки
export (bool) var is_edited = false setget set_edited											# Пометка сообщения "изменено"
export (bool) var is_reply = false setget set_reply												# Является ли сообщение ответом

var longest_line_length := 0 # Длина самой длинной строки


func init_message(text: String, params: Array) -> void:
	message_time = params[1]
	is_edited = params[2]
	
	# Если сообщение от главного героя - его имя не выводится
	is_reply = params[3]
	if is_reply:
		message_sender = ""
	else:
		message_sender = params[0]

	message_text = text


# Обновить текст/время сообщения, его размеры
func update_message() -> void:
	
	# Рассчитываем параметры текста
	var text_formatted: String = format_message(message_text)
	var longest_line: String = get_longest_text_line(text_formatted)
	
	longest_line_length = get_line_pixel_length(longest_line)
	
	# Рассчитываем параметры приписки о времени
	var time_formatted: String
	if is_edited:
		time_formatted = TIME_TAGS_START + message_time + ", изменено" + TIME_TAGS_END
	else:
		time_formatted = TIME_TAGS_START + message_time + TIME_TAGS_END
	
	# Оформляем имя отправителя
	var sender_name_formatted := "" 
	if not message_sender.empty():
		sender_name_formatted = NAME_TAGS_START + message_sender + NAME_TAGS_END + "\n"
	
	# Задаём минимальный размер поля сообщения
	rect_min_size = update_rect_min_size(message_sender)
	if message_text.empty():
		rect_size = rect_min_size
	else:
		rect_size.x = longest_line_length + PANEL_ALIGN
	
	# Записываем текст и время в поле сообщения
	$Panel/Text.bbcode_text = sender_name_formatted + text_formatted + time_formatted


# Задаём минимальный размер собщения
func update_rect_min_size(sender_name: String) -> Vector2:
	var result: Vector2
	var sender_name_length: int = get_line_pixel_length(sender_name, message_sender_font)
	
	if is_edited:
		result = PANEL_MIN_SIZE_EDITED
	else:
		result = PANEL_MIN_SIZE_EMPTY
	
	if result.x < sender_name_length:
		result.x = sender_name_length
	
	result.x += PANEL_ALIGN
	return result


# Если сообщение добавлено в контейнер - изменяем его размер,
# управляя константами MarginContainer
func update_margins():
	var game_screen_width: float = get_viewport_rect().size.x
	
	var margin_border_min: int
	var margin_border_max: int
	# warning-ignore:narrowing_conversion
	var margin_border_current: int = game_screen_width - longest_line_length -\
			PANEL_ALIGN - SCROLL_LINE_WIDTH
		
	if is_edited:
		# warning-ignore:narrowing_conversion
		margin_border_min = PANEL_MIN_SIZE_EDITED.x + SCROLL_LINE_WIDTH
		# warning-ignore:narrowing_conversion
		margin_border_max = game_screen_width - PANEL_MIN_SIZE_EDITED.x - SCROLL_LINE_WIDTH
	else:
		# warning-ignore:narrowing_conversion
		margin_border_min = PANEL_MIN_SIZE_EMPTY.x
		# warning-ignore:narrowing_conversion
		margin_border_max = game_screen_width - PANEL_MIN_SIZE_EMPTY.x - SCROLL_LINE_WIDTH
	
	if is_reply:
		add_constant_override("margin_right", 0)
		# warning-ignore:narrowing_conversion
		add_constant_override("margin_left", clamp(margin_border_current,
				margin_border_min, margin_border_max))
	else:
		# warning-ignore:narrowing_conversion
		add_constant_override("margin_right", clamp(margin_border_current,
				margin_border_min, margin_border_max))
		remove_constant_override("margin_left")


# Вписываем текст сообщения в облако сообщения
func format_message(text: String) -> String:
	if text == "":
		return text
	
	var result := ""
	var text_lines: PoolStringArray = text.split('\n')
	
	for i in text_lines.size():
		var line: String = text_lines[i]
		
		# Если текущая строка не слишком длинная
		if get_line_pixel_length(line) <= LINE_MAX_LENGTH:
			result += line + '\n'
		# Если строка слишком длинная
		else:
			var line_split: Array = format_line(line)
			for string in line_split:
				result += string + '\n'
	return result


# Разбить большую строку на строки поменьше (без переносов!)
func format_line(line: String) -> Array:
	var result := []
	var line_words: PoolStringArray = line.split(' ')
	var last_word_idx: int = line_words.size() - 1 # Индекс последнего слова
	
	var string := "" # Хранит промежуточные этапы разбиения
	for i in line_words.size():
		var word: String = line_words[i]
		
		# Если текущее слово сликом длинное (вероятно, спам букв)
		if word.length() > WORD_MAX_LENGTH: 
			for j in word.length():
				var letter: String = word[j]
				
				if get_line_pixel_length(string + letter) <= LINE_MAX_LENGTH:
					string += letter
				else:
					result.append(string)
					string = letter
		# Пытаемся вместить слово с пробелом после него
		elif get_line_pixel_length(string + word + ' ') <= LINE_MAX_LENGTH:
			string += word + ' '
		# Пытаемся вместить слово без пробела после него
		# Слово последним будет в этой строке, поэтому после отдаём её
		elif get_line_pixel_length(string + word) <= LINE_MAX_LENGTH:
			string += word
			result.append(string)
			string = ""
		# Если даже и слово не влазит - оставляем его для новой строки
		else:
			result.append(string.trim_suffix(' '))
			string = word + ' '
		
		# Не забываем забрать незаконченые строки
		if i == last_word_idx:
			result.append(string.trim_suffix(' '))
	return result


# Проверка, есть ли в сообщении строки, которые превышают максимальную длину
func contains_long_lines(text: String) -> bool:
	return get_line_pixel_length(get_longest_text_line(text)) > LINE_MAX_LENGTH


# Получить длину строки сообщения в пикселях, относительно заданого шрифта
func get_line_pixel_length(string: String, font := message_font) -> int:
	return font.get_string_size(string).x


# Получить число строк в сообщении
func get_lines_count(text: String) -> int:
	return text.count('\n') + 1


# Получить самую длинную строку в сообщении
func get_longest_text_line(text: String) -> String:
	if get_lines_count(text) == 1:
		return text
	
	# Разбиваем текст построчно, заносим в массив
	var text_lines: PoolStringArray = text.split('\n') 
	
	var text_lines_sizes := [] 
	
	# Заполняем массив значениями длин (в пикселях!) строк исходного текста
	for line in text_lines:
		text_lines_sizes.append(get_line_pixel_length(line))
	
	# Индекс первой самой длинной строки
	var text_line_long_idx: int = text_lines_sizes.find(text_lines_sizes.max()) 
	
	var result: String = text_lines[text_line_long_idx]
	return result


## СЕТТЕРЫ/ГЕТТЕРЫ
func set_message_text(value: String):
	message_text = value
	update_message()


func set_message_time(value: String):
	message_time = value
	update_message()


func set_edited(value: bool):
	is_edited = value
	update_message()


func set_reply(value: bool):
	is_reply = value
	update_message()


func set_message_sender(value: String):
	message_sender = value
	update_message()

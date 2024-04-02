tool
extends Node
# Служебный скрипт для комплексной обработки текста

const WORD_MAX_LENGTH := 35		# Макс. длина слова в русском языке (в символах!)
const SENDER_MAX_LENGTH := 40	# Макс. длина имени (в символах!)


# Разбить большую строку на строки поменьше (без переносов!)
func format_line(line: String, line_max_length: int, line_font: DynamicFont) -> Array:
	var result := []
	var line_words: PoolStringArray = line.split(' ')
	var str_tmp := "" # Хранит промежуточные этапы разбиения
	
	for word in line_words:
		
		# Если текущее слово сликом длинное (вероятно, спам букв)
		if word.length() >= WORD_MAX_LENGTH:
			for ch in word:
				if get_line_pixel_length(str_tmp + ch, line_font) <= line_max_length:
					str_tmp += ch
				else:
					result.append(str_tmp)
					str_tmp = ch
		# Пытаемся вместить слово с пробелом после него
		elif get_line_pixel_length(str_tmp + word + ' ', line_font) <= line_max_length:
			str_tmp += word + ' '
		# Пытаемся вместить слово без пробела после него
		# Слово последним будет в этой строке, поэтому после отдаём её
		elif get_line_pixel_length(str_tmp + word, line_font) <= line_max_length:
			str_tmp += word
			result.append(str_tmp)
			str_tmp = ""
		# Если даже и слово не влазит - оставляем его для новой строки
		else:
			result.append(str_tmp.trim_suffix(' '))
			str_tmp = word + ' '
		
		# Не забываем забрать незаконченые строки
		if word == line_words[-1]:
			result.append(str_tmp.trim_suffix(' '))
	print("format_line: " + str(result))
	return result


# Вписать текст сообщения в облако сообщения
func format_text(text: String, line_max_length: int, text_font: DynamicFont) -> String:
	if text == "":
		return text
	
	var result := ""
	var text_lines: PoolStringArray = text.split('\n')

	for line in text_lines:
		# Если текущая строка не слишком длинная
		if get_line_pixel_length(line, text_font) <= line_max_length:
			result += line
		# Если строка слишком длинная
		else:
			var line_formatted: Array = format_line(line, line_max_length, text_font)
			for string in line_formatted:
				result += string
				if string != line_formatted[-1]:
					result += '\n'

	print("format_text: " + result.c_escape())
	return result


# Получить длину строки, в пикселях
func get_line_pixel_length(string: String, font: DynamicFont) -> int:
	return int(font.get_string_size(string).x)


# Получить самую длинную строку в сообщении
func get_longest_text_line(text: String, text_font: DynamicFont) -> String:
	if get_lines_count(text) == 1:
		return text
	
	# Разбиваем текст построчно, заносим в массив
	var text_lines: PoolStringArray = text.split('\n') 
	var text_lines_sizes := []
	
	# Заполняем массив значениями длин (в пикселях!) строк исходного текста
	for line in text_lines:
		text_lines_sizes.append(get_line_pixel_length(line, text_font))
	
	# Индекс первой самой длинной строки
	var text_line_long_idx: int = text_lines_sizes.find(text_lines_sizes.max()) 
	var result: String = text_lines[text_line_long_idx]
	return result


# Получить число строк в сообщении
func get_lines_count(text: String) -> int:
	return text.count('\n') + 1

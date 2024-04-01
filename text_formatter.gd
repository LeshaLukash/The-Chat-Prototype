tool
extends Node
# Служебный скрипт для комплексной обработки текста

const WORD_MAX_LENGTH := 35		# Макс. длина слова в русском языке (в символах!)
const SENDER_MAX_LENGTH := 40	# Макс. длина имени (в символах!)

# Разбить большую строку на строки поменьше (без переносов!)
func format_line(line: String, line_max_length: int, line_font: DynamicFont) -> Array:
	var result := []
	var line_words: PoolStringArray = line.split(' ')
	var last_word_idx: int = line_words.size() - 1 # Индекс последнего слова
	
	var string := "" # Хранит промежуточные этапы разбиения
	for i in line_words.size():
		var word: String = line_words[i]
		
		# Если текущее слово сликом длинное (вероятно, спам букв)
		if word.length() >= WORD_MAX_LENGTH:
			for j in word.length():
				var letter: String = word[j]
				
				if get_line_pixel_length(string + letter, line_font) <= line_max_length:
					string += letter
				else:
					result.append(string)
					string = letter
		# Пытаемся вместить слово с пробелом после него
		elif get_line_pixel_length(string + word + ' ', line_font) <= line_max_length:
			string += word + ' '
		# Пытаемся вместить слово без пробела после него
		# Слово последним будет в этой строке, поэтому после отдаём её
		elif get_line_pixel_length(string + word, line_font) <= line_max_length:
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


# Вписать текст сообщения в облако сообщения
func format_text(text: String, line_max_length: int, text_font: DynamicFont) -> String:
	if text == "":
		return text
	
	var result := ""
	var text_lines: PoolStringArray = text.split('\n')
	
	for i in text_lines.size():
		var line: String = text_lines[i]
		
		# Если текущая строка не слишком длинная
		if get_line_pixel_length(line, text_font) <= line_max_length:
			result += line + '\n'
		# Если строка слишком длинная
		else:
			var line_split: Array = format_line(line, line_max_length, text_font)
			for string in line_split:
				result += string + '\n'
	
	# Последняя строка идёт с лишним переносом в конце - удаляем его
	result = result.trim_suffix('\n')
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

tool
class_name Message
extends MarginContainer
## СООБЩЕНИЕ
# Поле с текстом сообщения

# Сигнал нажатия аватарки
signal avatar_pressed 

# Макс. длина строки сообщения, в пикселях
const LINE_MAX_LENGTH := 400

# Константы тегов, форматирующих имя отправителя и время в тексте сообщения
const TIME_TAGS_START := "[right][font=fonts/arial_time.tres]"
const TIME_TAGS_END := "[/font][/right]"
const SENDER_TAGS_START := "[color=silver][font=fonts/arial_sender_name.tres]"
const SENDER_TAGS_END := "[/font][/color]"

# Файлы шрифтов имени, сообщения и времени
export (DynamicFont) var sender_font = preload("res://fonts/arial_sender_name.tres")
export (DynamicFont) var text_font = preload("res://fonts/arial.tres")
export (DynamicFont) var time_font = preload("res://fonts/arial_time.tres")

# Строки имени, текста и времени
export (String) var sender = "Отправитель" setget set_sender
export (String, MULTILINE) var text setget set_text
export (String) var time = "00:00" setget set_time

# Маркер сообщения статусом "изменено"
export (bool) var is_edited = false setget set_edited
# Маркер, является ли сообщение ответом "игрока"
export (bool) var is_player_reply = false

# Текстура аватарки
var avatar_texture

# Обновить содержимое сообщения
func update_message() -> void:
	# Форматируем содержимое сообщения
	var sender_formatted: String = SENDER_TAGS_START + sender + SENDER_TAGS_END
	var text_formatted: String = $TextFormatter.format_text(text, LINE_MAX_LENGTH, text_font)
	var time_formatted: String = TIME_TAGS_START + get_time_status() + TIME_TAGS_END
	
	# Обновляем содержимое сообщения и подгоняем его под размеры
	get_node("%Text").bbcode_text = sender_formatted + '\n' + text_formatted + '\n' + time_formatted
	get_node("%Text").rect_min_size.x = calc_message_width(text_formatted)
	

# Вычислить ширину сообщения, в зависимости от размера содержимого
func calc_message_width(text_formatted: String) -> int:
	var sender_length: int = $TextFormatter.get_line_pixel_length(sender, sender_font)
	var text_longest_line: String = $TextFormatter.get_longest_text_line(text_formatted, text_font)
	var text_length: int = $TextFormatter.get_line_pixel_length(text_longest_line, text_font)
	var time_length: int = $TextFormatter.get_line_pixel_length(get_time_status(), time_font)
	
	var length_to_compare := [sender_length, text_length, time_length]
	var panel_width := int(clamp(length_to_compare.max(), 0, LINE_MAX_LENGTH))
	return panel_width


# Получаем строку со временем + подписью "изменено" (если нужно)
func get_time_status() -> String:
	var result: String = time
	if is_edited:
		result += ", изменено"
	return result


#################### СЕТТЕРЫ ####################
func set_sender(value: String):
	if get_node_or_null("TextFormatter") != null:
		# Задаём имя, не превышающее по длине лимит
		sender = value.substr(0, $TextFormatter.SENDER_MAX_LENGTH - 1)
		update_message()


func set_text(value: String):
	text = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


func set_edited(value: bool):
	is_edited = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


func set_time(value: String):
	if value.empty():
		time = "00:00"
	else:
		time = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


#################### СИГНАЛЫ ####################
func _on_Avatar_pressed():
	print("Аватарка отправителя была нажата")
	emit_signal("avatar_pressed")

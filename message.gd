tool
class_name Message
extends MarginContainer
## СООБЩЕНИЕ
# Поле с текстом сообщения

signal avatar_pressed # Сигнал нажатия аватарки

const LINE_MAX_LENGTH := 400	# Макс. длина строки сообщения (в пикселях!)
const LOST_LETTER_SIZE := 14	# Длина, которую нужно прибавлять к ширине панели

# Константы тегов, форматирующих имя отправителя и время в тексте сообщения
const TIME_TAGS_START := "[right][font=fonts/arial_time.tres]"
const TIME_TAGS_END := "[/font][/right]"
const SENDER_TAGS_START := "[color=silver][font=fonts/arial_sender_name.tres]"
const SENDER_TAGS_END := "[/font][/color]"

export (DynamicFont) var sender_font = preload("res://fonts/arial_sender_name.tres")	# Шрифт имени отправителя
export (DynamicFont) var text_font = preload("res://fonts/arial.tres")						# Шрифт сообщения
export (DynamicFont) var time_font = preload("res://fonts/arial_time.tres")				# Шрифт времени отправки

export (String) var sender = "Отправитель" setget set_sender 	# Имя отправителя
export (String, MULTILINE) var text setget set_text 			# Текст сообщения
export (String) var time = "00:00" setget set_time				# Время отправки

export (bool) var is_edited = false setget set_edited			# Флаг-пометка сообщения статусом "изменено"
export (bool) var is_player_reply = false	# Флаг, является ли сообщение ответом "игрока"

var avatar_texture # Текстура аватарки


# Обновить содержимое сообщения
func update_message() -> void:
	# Форматируем содержимое сообщений
	var sender_formatted: String = SENDER_TAGS_START + sender + SENDER_TAGS_END
	var text_formatted: String = $TextFormatter.format_text(text, LINE_MAX_LENGTH, text_font)
	var time_formatted: String = TIME_TAGS_START + get_time_status() + TIME_TAGS_END
	
	# Обновляем содержимое сообщения
	get_node("%Text").bbcode_text = sender_formatted + "\n" + text_formatted + "\n" + time_formatted
	get_node("%Panel").rect_min_size.x = calc_panel_width() + LOST_LETTER_SIZE


# Вычислить ширину панели, в зависимости от размера содержимого
func calc_panel_width() -> int:
	var sender_length: int = $TextFormatter.get_line_pixel_length(sender, sender_font)
	var text_longest_line: String = $TextFormatter.get_longest_text_line(text, text_font)
	var text_length: int = $TextFormatter.get_line_pixel_length(text_longest_line, text_font)
	var time_length: int = $TextFormatter.get_line_pixel_length(get_time_status(), time_font)
	
	var length_to_compare: Array = [sender_length, text_length, time_length]
	var panel_width: int = int(clamp(length_to_compare.max(),
			0, LINE_MAX_LENGTH))
	return panel_width


# Получаем строку со временем + подписью "изменено" (если нужно)
func get_time_status() -> String:
	if is_edited:
		return time + ", изменено"
	return time


func set_sender(value: String):
	sender = value.substr(0, $TextFormatter.SENDER_MAX_LENGTH - 1) # Задаём имя, не превышающее по длине лимит
	update_message()


func set_text(value: String):
	text = value
	update_message()


func set_edited(value: bool):
	is_edited = value
	update_message()


func set_time(value: String):
	if value.empty():
		time = "00:00"
	else:
		time = value
	update_message()


func _on_Avatar_pressed():
	emit_signal("avatar_pressed")

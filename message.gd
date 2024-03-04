tool
class_name Message
extends MarginContainer
## СООБЩЕНИЕ
# Поле с текстом сообщения

signal avatar_pressed # Сигнал нажатия аватарки

const LINE_MAX_LENGTH := 400 # Макс. длина строки сообщения (в пикселях!)

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


func update_message() -> void:
	var sender_formatted: String = SENDER_TAGS_START + sender + SENDER_TAGS_END
	
	var time_formatted: String = TIME_TAGS_START + time
	if is_edited:
		time_formatted += ", изменено"
	time_formatted += TIME_TAGS_END
	
	get_node("%Text").bbcode_text = sender_formatted + "\n" + text + "\n" + time_formatted


func set_panel_size() -> void:
	pass


func set_edited(value: bool):
	is_edited = value
	update_message()


func set_sender(value: String):
	if value.empty():
		sender = " "
	else:
		sender = value
	update_message()


func set_text(value: String):
	text = value
	update_message()


func set_time(value: String):
	if value.empty():
		time = "00:00"
	else:
		time = value
	update_message()


func _on_Avatar_pressed():
	emit_signal("avatar_pressed")

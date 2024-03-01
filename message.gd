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
const NAME_TAGS_START := "[color=silver][font=fonts/arial_sender_name.tres]"
const NAME_TAGS_END := "[/font][/color]"

export (DynamicFont) var message_sender_font = preload("res://fonts/arial_sender_name.tres")	# Шрифт имени отправителя
export (DynamicFont) var message_font = preload("res://fonts/arial.tres")						# Шрифт сообщения
export (DynamicFont) var message_time_font = preload("res://fonts/arial_time.tres")				# Шрифт времени отправки

export (String) var message_sender = "Отправитель"	# Имя отправителя
export (String, MULTILINE) var message_text 		# Текст сообщения
export (String) var message_time = "00:00"			# Время отправки

export (bool) var is_edited = false			# Флаг-пометка сообщения статусом "изменено"
export (bool) var is_player_reply = false	# Флаг, является ли сообщение ответом "игрока"

var avatar_texture # Текстура аватарки

func _on_Avatar_pressed():
	emit_signal("avatar_pressed")

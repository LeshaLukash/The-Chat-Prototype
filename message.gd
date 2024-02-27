tool
class_name Message
extends MarginContainer
## СООБЩЕНИЕ
# Поле с текстом сообщения

signal avatar_pressed	# Сигнал нажатия аватарки

const PANEL_MIN_SIZE_EMPTY := Vector2(108, 105)	# Мин. размер пустого сообщения, без пометки
const PANEL_MIN_SIZE_EDITED := Vector2(209, 105)# Мин. размер пустого сообщения, с пометкой
const LINE_MAX_LENGTH := 400					# Макс. длина строки сообщения (в пикселях!)
const PANEL_ALIGN := 18							# Отступы $Panel по краям от текста (наверное) 
const SCROLL_LINE_WIDTH := 12					# Ширина линии прокрутки сообщений (в пикселях)
const AVATAR_WIDTH := 40						# Ширина аватарки (в пикселях)
const HBOX_ALIGN := 4							# Расстояние между элементами HBox (в пикселях)
const TIME_TAGS_START := "[right][font=fonts/arial_time.tres]"
const TIME_TAGS_END := "[/font][/right]"
const NAME_TAGS_START := "[color=silver][font=fonts/arial_sender_name.tres]"
const NAME_TAGS_END := "[/font][/color]"


export (DynamicFont) var message_sender_font = preload("res://fonts/arial_sender_name.tres")	# Шрифт имени отправителя
export (DynamicFont) var message_font = preload("res://fonts/arial.tres")						# Шрифт сообщения
export (DynamicFont) var message_time_font = preload("res://fonts/arial_time.tres")				# Шрифт времени отправки

export (String) var message_sender = "Отправитель" setget set_message_sender					# Имя отправителя
export (String, MULTILINE) var message_text setget set_message_text								# Текст сообщения
export (String) var message_time = "00:00" setget set_message_time								# Время отправки

export (bool) var is_edited = false setget set_edited											# Флаг-пометка сообщения статусом "изменено"
export (bool) var is_player_reply = false setget set_player_reply								# Флаг, является ли сообщение ответом "игрока"

export (StreamTexture) var avatar_texture = AvatarsDB.get_avatar() setget set_avatar_texture # Текстура аватарки
export (bool) var is_avatar_visible = true setget set_avatar_visible


# Загрузка данных в сообщение
func init_message(text: String, params: Array) -> void:
	message_sender = params[0]
	message_time = params[1]
	is_edited = params[2]
	is_player_reply = params[3]
	
	avatar_texture = AvatarsDB.get_avatar(message_sender)
	message_text = text


# Обновить текст/время сообщения, его размеры
var longest_line_length := 0 # Длина самой длинной строки
func update_message() -> void:
	
	# Рассчитываем параметры текста
	var text_formatted: String = $TextFormatter.format_text(message_text, LINE_MAX_LENGTH, message_font)
	var longest_line: String = $TextFormatter.get_longest_text_line(text_formatted, message_font)
	longest_line_length = $TextFormatter.get_line_pixel_length(longest_line, message_font)
	
	# Оформляем время отправки
	var time_formatted: String = TIME_TAGS_START + message_time
	if is_edited:
		time_formatted += ", изменено"
	time_formatted += TIME_TAGS_END
	
	# Оформляем параметры, связанные с тем, от ГГ ли сообщение, или от его собеседников
	var sender_name_formatted := "" 
	if is_player_reply:
		sender_name_formatted = NAME_TAGS_START + "" + NAME_TAGS_END + "\n"
		is_avatar_visible = false
	else:
		sender_name_formatted = NAME_TAGS_START + message_sender + NAME_TAGS_END + "\n"

	get_node("%Avatar").texture_normal = avatar_texture
	if is_avatar_visible:
		get_node("%Avatar").show()
	else:
		get_node("%Avatar").hide()

	# Записываем текст и время в поле сообщения
	get_node("%Text").bbcode_text = sender_name_formatted + text_formatted + time_formatted


# Задаём минимальный размер собщения
func update_rect_min_size() -> Vector2:
	var result: Vector2
	
	if is_edited:
		result = PANEL_MIN_SIZE_EDITED
	else:
		result = PANEL_MIN_SIZE_EMPTY
	
	if not is_player_reply:
		var sender_name_length: int = $TextFormatter.get_line_pixel_length(message_sender, message_sender_font)
		if result.x < sender_name_length:
			result.x = sender_name_length
	
	#result.x += AVATAR_WIDTH + PANEL_ALIGN
	return result


# Если сообщение добавлено в контейнер - изменяем его размер, управляя константами MarginContainer
func update_margins() -> void:
	var game_screen_width: float = get_viewport_rect().size.x
	
	var margin_border_min: int
	var margin_border_max: int
	var margin_border_current: int = int(round(game_screen_width - longest_line_length -\
			PANEL_ALIGN - SCROLL_LINE_WIDTH))
		
	if is_edited:
		margin_border_min = int(round(PANEL_MIN_SIZE_EDITED.x + SCROLL_LINE_WIDTH))
		margin_border_max = int(round(game_screen_width - PANEL_MIN_SIZE_EDITED.x - SCROLL_LINE_WIDTH))
	else:
		margin_border_min = int(round(PANEL_MIN_SIZE_EMPTY.x))
		margin_border_max = int(round(game_screen_width - PANEL_MIN_SIZE_EMPTY.x - SCROLL_LINE_WIDTH))
	
	if is_player_reply:
		add_constant_override("margin_right", 0)
		add_constant_override("margin_left", int(clamp(margin_border_current,
				margin_border_min, margin_border_max)))
	else:
		margin_border_min += HBOX_ALIGN
		margin_border_max += HBOX_ALIGN
		margin_border_current -= HBOX_ALIGN
		
		if is_avatar_visible:
			margin_border_min += AVATAR_WIDTH
			margin_border_max += AVATAR_WIDTH
			margin_border_current -= AVATAR_WIDTH
		
		add_constant_override("margin_right", int(clamp(margin_border_current,
				margin_border_min, margin_border_max)))
		remove_constant_override("margin_left")


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


func set_player_reply(value: bool):
	is_player_reply = value
	update_message()


func set_message_sender(value: String):
	message_sender = value
	update_message()


func set_avatar_visible(value: bool):
	is_avatar_visible = value
	update_message()


func set_avatar_texture(value: StreamTexture):
	avatar_texture = value
	get_node("%Avatar").texture_normal = avatar_texture
	update_message()


func _on_Avatar_pressed():
	emit_signal("avatar_pressed")

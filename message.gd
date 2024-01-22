tool
extends Control

const MESSAGE_MIN_SIZE_EMPTY := Vector2(51, 54)			# Мин. размер пустого сообщения без пометки
const MESSAGE_MIN_SIZE_EDITED_EMPTY := Vector2(109, 54)	# Мин. размер пустого сообщения с пометкой

export (String, MULTILINE) var text setget set_text		# Текст сообщения
export (String) var time = "00:00" setget set_time		# Время отправки
export (bool) var is_edited = false setget set_edited	# Пометка сообщения "изменено"


func _process(_delta):
	# Вывод на экран числа строк в $Panel/Text
	$LinesCount.set_text("Число строк: " + String($Panel/Text.get_line_count()))


# Обновить текст/время сообщения, его размеры
# Менять нужно параметры нода "Message", а не "Panel"
func update_message() -> void:
	var time_formatted: String = time
	var time_tags_start := "[right][font=fonts/arial_time.tres]"
	var time_tags_end := "[/font][/right]"
	
	if is_edited:
		rect_min_size = MESSAGE_MIN_SIZE_EDITED_EMPTY
		time_formatted += ", изменено"
	else:
		rect_min_size = MESSAGE_MIN_SIZE_EMPTY
	
	if text.empty():
		rect_size = rect_min_size
		
	$Panel/Text.bbcode_text = text + time_tags_start + time_formatted + time_tags_end


func set_text(value: String):
	text = value
	update_message()


func set_time(value: String):
	time = value
	update_message()


func set_edited(value: bool):
	is_edited = value
	update_message()

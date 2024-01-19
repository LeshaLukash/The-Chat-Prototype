tool
extends Control

export(String, MULTILINE) var text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris sed malesuada orci. Vestibulum ex dolor, dignissim a feugiat id, vulputate sed mi. Praesent a venenatis urna. Maecenas faucibus diam quis risus fermentum mattis. Ut id luctus nunc, lobortis pharetra ligula. Maecenas posuere magna in mi semper, non luctus purus elementum. Nullam ac viverra libero, ut finibus lectus. Morbi nisi neque, tincidunt non fringilla nec, rhoncus id sapien. Ut aliquam turpis in luctus malesuada. Integer sit amet accumsan est. Vivamus vel risus sed odio elementum pulvinar vel quis enim. "
export(String) var time = "00:00"
export(bool) var is_reply = false
export(bool) var is_edited = false

var text_font: DynamicFont # Шрифт текста сообщений
var time_font: DynamicFont # Шрифт времени сообщения
var time_string: String
var message_size: Vector2


func _ready():
	init_message()


func _process(_delta):
	if Engine.editor_hint:
		init_message()
	else:
		set_process(false)

# Инициализация шрифтов
func _initialize_fonts() -> void:
	time_font = theme.get_font("font", "TimeLabel")
	text_font = theme.get_font("normal_font", "RichTextLabel")

# Задать строку времени сообщения
func _set_time_string() -> void:
	if is_edited:
		time_string = "[right][font=fonts/arial_time.tres]" + time + ", изменено[/font][/right]"
	else:
		time_string = "[right][font=fonts/arial_time.tres]" + time + "[/font][/right]"

# Получить размер строки времени сообщения
func _get_time_string_size() -> Vector2:
	if is_edited:
		return time_font.get_string_size(time + ", изменено")
	
	return time_font.get_string_size(time)


func _get_message_size() -> Vector2:
	var text_size: Vector2 = text_font.get_string_size(text)
	return text_size

# Подготовка и вывод сообщения
func init_message() -> void:
	_initialize_fonts()
	_set_time_string()
	
	if text.empty():
		$Panel.rect_size = $Panel.rect_min_size
		text = " "
	
	if is_edited:
		$Panel.rect_min_size = Vector2(107, 54)
	else:
		$Panel.rect_min_size = Vector2(51, 54)
	
	# Задаём размер сообщения
	var string_offset: int = _get_message_size().x - $Panel/Text.rect_size.x
	if string_offset != 0:
		$Panel.rect_size.x += string_offset
	 
	
	# Задаём текст сообщения
	$Panel/Text.bbcode_text = text + time_string
	
	# Минимальная высота сообщения (текст + время) - 40px!
	# С каждой строкой высота увеличивается на 20px
	
	# Перенос строки происходит при увелчении её размеров на 40px
	# (40, 80, 120, 160, etc. - при таких величинах строка переносится)


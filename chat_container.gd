tool
extends ScrollContainer
# Окно чата
# Это вертикальный список с прокруткой всех добавленых сообщений

const GROUP_MESSAGES_NAME := "messages"
const PARAMS_COUNT := 4

export (String, FILE, "*.txt") var chat_text_file = "res://chats/chat_example.txt" setget set_chat

onready var message_scene := preload("res://message.tscn")
onready var info_label_scene := preload("res://info_label.tscn")


func _ready():
	load_chat(chat_text_file)


# Прокрутить список сообщений на pos-пикселей
func scroll_messages(pos: float) -> void:
	scroll_vertical -= int(floor(pos)) 


# Загрузить чат из текстового файла, расположенного по пути chat_text_file
func load_chat(file_path: String = chat_text_file) -> void:
	clear_chat()
	
	# Извлекаем данные из файла
	var f = File.new()
	if not f.file_exists(file_path):
		printerr("Файл %s отсутствует!" %file_path)
		return
	f.open(file_path, File.READ)
	while f.get_position() < f.get_len():
		var line = f.get_line()
		
		if line.begins_with('<') and line.ends_with('>'):
			add_info_panel(line)
		else:
			# Считываем строку с параметрами сообщения
			var msg_params: Array = extract_params(line)
			# Если параметры не загрузились, или после них нет строки с текстом
			if msg_params.empty() or f.eof_reached():
				clear_chat()
				printerr("Критическая ошибка при чтении %s, чат не загружен!" %file_path)
				return
		
			var msg_line: String = f.get_line().c_unescape()
			var is_last_msg: bool = f.eof_reached()
			add_message(msg_line, msg_params, is_last_msg)
	f.close()


# Добавить в чат инфопанель
func add_info_panel(line: String) -> void:
	var info_label = info_label_scene.instance()
	var info_label_text: String = line.trim_prefix('<')
	info_label_text = info_label_text.trim_suffix('>')
	info_label.set_text(info_label_text)
	$MessagesContainer.add_child(info_label)


# Добавить в чат сообщение
var current_sender: String	# Имя отправителя текущего сообщения
var previous_sender: String	# Имя отправителя предыдущего сообщения
var msg: Message
var previous_msg: Message
var previous_msg_edited := false

func add_message(text: String, params: Array, is_last_msg := false) -> void:
	msg = message_scene.instance()
	msg.add_to_group(GROUP_MESSAGES_NAME)
	
	# Проверка, является ли автор прошлого сообщения автором текущего сообщения
	# Если так, то в последующих его сообщениях скрываем имя и аватарку
	current_sender = params[0]
	if previous_sender == current_sender:
		previous_msg.avatar_texture = Message.EMPTY_AVATAR
		params[0] = ""
		previous_msg_edited = true
	elif previous_msg_edited:
		previous_msg.message_sender = ""
		previous_msg.update_message()
		previous_msg.avatar_texture = AvatarsDB.get_avatar(previous_sender)
		previous_msg_edited = false
	previous_sender = current_sender
	previous_msg = msg

	msg.init_message(text, params)
	msg.update_message()
	
	# Если человек последним отправил несколько сообщений подряд - на его последнее сообщение
	# возвращаем его родную аватарку (без этого будет дефолтной)
	if is_last_msg:
		msg.avatar_texture = AvatarsDB.get_avatar(previous_sender)
	
	$MessagesContainer.add_child(msg)
	msg.update_margins()
	


# Удалить все сообщения из чата
func clear_chat() -> void:
	# Если группа пустая или отсутствует - завершаем функцию
	if get_tree().get_nodes_in_group(GROUP_MESSAGES_NAME).empty():
		return
	
	for message in get_tree().get_nodes_in_group(GROUP_MESSAGES_NAME):
		message.queue_free()


# Извлечь из строки параметры
func extract_params(string: String) -> Array:
	var result := []
	
	var params := string.split(',')
	# Если строка с параметрами имеет не 4 параметра - сбрасыываем чат
	if params.size() != PARAMS_COUNT:
		printerr("Ошибка при чтении строки с параметрами!")
		return result
	
	var msg_sender: String = params[0]	#msg_sender - имя отправителя
	var msg_time: String = params[1] # msg_time - время отправки
	var is_edited := bool(int(params[2])) # is_edited - метка редактирования сообщения
	var is_player_reply := bool(int(params[3]))  # is_reply - метка того, кто отправитель
	
	result.append(msg_sender)
	result.append(msg_time)
	result.append(is_edited)
	result.append(is_player_reply)
	
	return result
	
	
func set_chat(value: String) -> void:
	if value != chat_text_file:
		load_chat(value)
	
	chat_text_file = value

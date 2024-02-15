tool
extends ScrollContainer

# Окно чата
# Это вертикальный список с прокруткой всех добавленых сообщений

const GROUP_MESSAGES := "messages"
const PARAMS_COUNT := 4

export (String, FILE, "*.txt") var chat_text_file = "res://chats/chat_example.txt" setget set_chat

onready var m := preload("res://message.tscn")


func _ready():
	load_chat(chat_text_file)


# Прокрутить список сообщений на pos-пикселей
func scroll_messages(pos: float) -> void:
	scroll_vertical -= floor(pos) 


# Загрузить чат из текстового файла, расположенного по пути chat_text_file
# Первой строкой идёт текст сообщения
# Второй - параметры сообщения
func load_chat(file_path: String = chat_text_file) -> void:
	clear_chat()
	var f = File.new()
	
	if not f.file_exists(file_path):
		printerr("Файл %s отсутствует!" %file_path)
		return

	# Извлекаем данные из файла
	f.open(file_path, File.READ)
	var current_sender: String	# Имя отправителя текущего сообщения
	var previous_sender: String	# Имя отправителя предыдущего сообщения
	var msg: Message
	var previous_msg: Message
	var previous_msg_edited := false
	while f.get_position() < f.get_len():
		# Считываем строку с параметрами сообщения
		var params_line: String = f.get_line()
		var msg_params: Array = get_params(params_line)
		
		# Если строка с параметрами имеет не три параметра - сбрасыываем чат
		if msg_params.size() != PARAMS_COUNT:
			clear_chat()
			printerr("Ошибка при чтении файла %s - вероятно, он не полон!" %file_path)
			return
		
		# Если не хватает строки с текстом сообщения - сбрасываем чат
		if f.eof_reached():
			clear_chat()
			printerr("Ошибка при чтении файла %s - вероятно, он не полон!" %file_path)
			return
		# Считываем строку сообщения с учётом escape sequence's
		var msg_line: String = f.get_line().c_unescape()

		# Добавляем сообщение
		msg = m.instance()
		msg.add_to_group(GROUP_MESSAGES)
		
		# Проверка, является ли автор прошлого сообщения автором текущего сообщения
		# Если так, то в последующих его сообщениях скрываем имя и аватарку
		current_sender = msg_params[0]
		if not previous_sender.empty(): # Код начнёт работу после первого сообщения
			if previous_sender == current_sender:
				previous_msg.avatar_texture = Message.EMPTY_AVATAR
				msg_params[0] = ""
				previous_msg_edited = true
			elif previous_msg_edited:
				previous_msg.message_sender = ""
				previous_msg.update_message()
				previous_msg.update_margins()
				previous_msg_edited = false
		previous_sender = current_sender
		previous_msg = msg
		
		msg.init_message(msg_line, msg_params)
		msg.update_message()
		$MessagesContainer.add_child(msg)
		msg.update_margins()


# Удалить все сообщения из чата
func clear_chat() -> void:
	# Если группа пустая или отсутствует - завершаем функцию
	if get_tree().get_nodes_in_group(GROUP_MESSAGES).empty():
		return
	
	for msg in get_tree().get_nodes_in_group(GROUP_MESSAGES):
		msg.queue_free()


# Извлечь из строки параметры
func get_params(string: String) -> Array:
	var params := string.split(',')

	var msg_sender: String = params[0]	#msg_sender - имя отправителя
	var msg_time: String = params[1] # msg_time - время отправки
	var is_edited := bool(int(params[2])) # is_edited - метка редактирования сообщения
	var is_player_reply := bool(int(params[3]))  # is_reply - метка того, кто отправитель
	
	var result := []
	result.append(msg_sender)
	result.append(msg_time)
	result.append(is_edited)
	result.append(is_player_reply)
	return result
	
	
func set_chat(value: String) -> void:
	if value != chat_text_file:
		load_chat(value)
	
	chat_text_file = value

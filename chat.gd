extends ScrollContainer
tool

# Окно чата
# Это вертикальный список с прокруткой всех добавленых сообщений

const GROUP_MESSAGES := "messages"
const PARAMS_COUNT := 3

export (String, FILE, "*.txt") var chat_text_file = "res://chats/chat_example.txt" setget set_chat

onready var m := preload("res://message.tscn")


func _ready():
	load_chat(chat_text_file)


func load_chat(file_path: String = chat_text_file) -> void:
	clear_chat()
	var f = File.new()
	
	if not f.file_exists(file_path):
		print("Файл %s отсутствует!" %file_path)
		return
	
	f.open(file_path, File.READ)
	
	
	# Извлекаем данные из файла
	while f.get_position() < f.get_len():
		var msg_line: String = f.get_line()
		
		# Если не хватает строки с параметрами - сбрасываем чат
		if f.eof_reached():
			clear_chat()
			print("Ошибка при чтении файла %s - вероятно, он не полон!" %file_path)
			return
		
		var params_line: String = f.get_line()
		var msg_params: Array = get_params(params_line)
		
		# Если строка с параметрами имеет не три параметра - сбрасыываем чат
		if msg_params.size() != PARAMS_COUNT:
			clear_chat()
			print("Ошибка при чтении файла %s - вероятно, он не полон!" %file_path)
			return
		
		var msg = m.instance()
		msg.add_to_group(GROUP_MESSAGES)
		msg.init_message(msg_line, msg_params)
		$MessagesContainer.add_child(msg)
		msg.update_message()
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
	var msg_time: String = params[0] # msg_time - время отправки
	var is_edited := bool(int(params[1])) # is_edited - метка редактирования сообщения
	var is_reply := bool(int(params[2]))  # is_reply - метка того, кто отправитель
	
	var result := []
	result.append(msg_time)
	result.append(is_edited)
	result.append(is_reply)
	return result
	
	
func set_chat(value: String) -> void:
	if value != chat_text_file:
		load_chat(value)
	
	chat_text_file = value

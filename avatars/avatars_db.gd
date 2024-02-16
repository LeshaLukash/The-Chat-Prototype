extends Node

const AVATARS_LIST := "res://avatars/list.txt"

var avatars_db: Dictionary

func _ready():
	var f = File.new()
	
	f.open(AVATARS_LIST, File.READ)
	var avatars_string = f.get_as_text()
	
	avatars_db = parse_json(avatars_string)
	for key in avatars_db.keys():
		print(avatars_db[key])

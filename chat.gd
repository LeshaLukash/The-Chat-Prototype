extends Control



# Сперва проверяем,
func _input(event):
	if event is InputEventScreenDrag:
		if is_dragged_vectical(event.relative):
			print("Экран тянут по горизонтали")
		else:
			pass


func is_dragged_vectical(dir: Vector2) -> bool:
	return dir.normalized() == Vector2.LEFT or Vector2.RIGHT

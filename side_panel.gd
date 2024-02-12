extends Control

const PANEL_HIDED := -160
const PANEL_SHOWED := 0


signal chat_pressed
signal option_pressed
signal about_pressed
signal side_panel_dragged(weight)


# Задать положение панели
func set_panel_pos(x: float) -> void:
	rect_position.x += x
	rect_position.x = clamp(rect_position.x, -160, 0)


# Проиграть анимацию скрывания/выдвижения панели
func animate_panel(animation: int) -> void:
	var tween: SceneTreeTween = get_tree().create_tween()
	# warning-ignore:return_value_discarded
	tween.set_trans(Tween.TRANS_BOUNCE)
	
	match animation:
		0: # спрятать панель
			# warning-ignore:return_value_discarded
			tween.tween_property(self, "rect_position:x", PANEL_HIDED, 0.2)
		1: # выдвинуть панель
			# warning-ignore:return_value_discarded
			tween.tween_property(self, "rect_position:x", PANEL_SHOWED, 0.2)



func _on_ChatButton_pressed():
	emit_signal("chat_pressed")


func _on_OptionsButton_pressed():
	emit_signal("option_pressed")


func _on_AboutButton_pressed():
	emit_signal("about_pressed")


func _on_SidePanel_item_rect_changed():
	var weight: float = 1 - (rect_position.x / PANEL_HIDED)
	emit_signal("side_panel_dragged", weight)

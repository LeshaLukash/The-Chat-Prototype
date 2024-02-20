extends Control

# Окно чата

const FADE_MAX := 150 				# Макс. затенение экрана сообщений
const DRAG_LENGTH := 10				# Макс. длина свайпа, после чего проверяется его назначение
const INERTIA_SCROLL_SPEED := 0.5	# Скорость прокрутки сообщений после того, как игрок отпустил палец
const INERTIA_HIDDEN_SCROLL_SPEED := 1

var drag_vector := Vector2.ZERO		# Вектор перемещения пальцем по экрану
var is_drag_started := false		# Флаг, начал ли игрок протягивать пальцем по экрану
var is_side_panel_visible := false	# Флаг, видна ли боковая панель
var scroll_speed := 0.0				# Скорость прокрутки сообщений


func _process(delta):
	if round(scroll_speed) != 0:
		if is_drag_started:
			scroll_speed -= INERTIA_HIDDEN_SCROLL_SPEED * sign(scroll_speed)
		else:
			scroll_speed -= INERTIA_SCROLL_SPEED * sign(scroll_speed)
			$ChatContainer.scroll_messages(scroll_speed)
	else:
		scroll_speed = 0


# Отслеживаем свайпы по экрану
func _input(event):
	# Что должно произойти, когда игрок отпустил палец
	if event is InputEventScreenTouch:
		if event.pressed:
			scroll_speed = 0
		else:
			var is_drag_checked := drag_vector.length() >= DRAG_LENGTH
			var is_drag_horizontal := abs(drag_vector.x) > abs(drag_vector.y)
			
			is_drag_started = false
			drag_vector = Vector2.ZERO
			
			# Если проверка свайпа проводилась по горизонтали
			# т.е. нужно скрыть боковую панель
			if is_drag_checked and is_drag_horizontal or is_side_panel_visible:
				if $SidePanel.rect_position.x / $SidePanel.rect_size.x < -0.5:
					$SidePanel.animate_panel(0)
					is_side_panel_visible = false
				else:
					$SidePanel.animate_panel(1)
					is_side_panel_visible = true

	elif event is InputEventScreenDrag:
		is_drag_started = true
		scroll_speed = 0.0
		
		# Игрок пальцем намечает вектор направления
		if drag_vector.length() < DRAG_LENGTH:
			drag_vector += event.relative
		else:
			# Когда он достигает определённой длины - проверяем, он вертикальный, или горизонтальный
			if abs(drag_vector.x) < abs(drag_vector.y) and not is_side_panel_visible:
				$ChatContainer.scroll_messages(event.relative.y)
				is_side_panel_visible = false
				scroll_speed = round(event.speed.y * get_process_delta_time())
			else:
				$SidePanel.set_panel_pos(event.relative.x)
				is_side_panel_visible = true


# Затеняем сообщения
func fade_messages(weight: float) -> void:
	$FadeRect.color.a8 = lerp(0, FADE_MAX, weight)
	
	# Если сообщения хотя бы немного затенены - не давать их нажимать
	if $FadeRect.color.a8 == 0:
		$FadeRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		$FadeRect.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_SidePanel_side_panel_dragged(weight: float):
	fade_messages(weight)

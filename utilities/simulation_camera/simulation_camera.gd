class_name SimulationCamera extends Camera2D

const tile_outline_color = Color(0, 1, 0, 0.4)
const tile_outline_width = 1.5
const ZOOM_STEP: float = 0.05

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('camera_zoom_out'):
		zoom_out()
	elif event.is_action_pressed('camera_zoom_in'):
		zoom_in()

func zoom_in() -> void:
	zoom += zoom * 0.1

func zoom_out() -> void:
	zoom -= zoom * 0.1

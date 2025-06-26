class_name UITools extends Control

@export var camera: SimulationCamera

@onready var hslider_speed: HSlider = $VBoxContainer/MarginContainer/HBoxContainer/hslider_speed
@onready var texturebutton_arrow: TextureButton = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/texturebutton_arrow
@onready var texturebutton_backward: TextureButton = $VBoxContainer/MarginContainer/HBoxContainer/texturebutton_backward
@onready var texturebutton_beginning: TextureButton = $VBoxContainer/MarginContainer/HBoxContainer/texturebutton_beginning
@onready var texturebutton_clear: TextureButton = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/texturebutton_clear
@onready var texturebutton_eraser: TextureButton = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/texturebutton_eraser
@onready var texturebutton_forward: TextureButton = $VBoxContainer/MarginContainer/HBoxContainer/texturebutton_forward
@onready var texturebutton_pen: TextureButton = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/texturebutton_pen
@onready var texturebutton_play: TextureButton = $VBoxContainer/MarginContainer/HBoxContainer/texturebutton_play
@onready var texturebutton_trash: TextureButton = $VBoxContainer/MarginContainer/HBoxContainer/texturebutton_trash
@onready var vslider_zoom: VSlider = $VBoxContainer/HBoxContainer/MarginContainer2/vslider_zoom

func _ready() -> void:
	hslider_speed.value_changed.connect(on_speed_changed)
	texturebutton_arrow.toggled.connect(on_arrow_toggled)
	texturebutton_backward.pressed.connect(on_backward_pressed)
	texturebutton_beginning.pressed.connect(on_beginning_pressed)
	texturebutton_clear.pressed.connect(on_clear_pressed)
	texturebutton_eraser.toggled.connect(on_eraser_toggled)
	texturebutton_forward.pressed.connect(on_forward_pressed)
	texturebutton_pen.toggled.connect(on_pen_toggled)
	texturebutton_play.toggled.connect(on_play_toggled)
	texturebutton_trash.pressed.connect(on_trash_pressed)
	vslider_zoom.value_changed.connect(on_zoom_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('camera_zoom_out'):
		if camera == null:
			return
		var value: float = camera.zoom.x - (camera.zoom.x * camera.ZOOM_STEP)
		on_zoom_changed(value)
		vslider_zoom.value = value
	elif event.is_action_pressed('camera_zoom_in'):
		if camera == null:
			return
		var value: float = camera.zoom.x + (camera.zoom.x * camera.ZOOM_STEP)
		on_zoom_changed(value)
		vslider_zoom.value = value
	if event.is_action_pressed('clear'):
		on_trash_pressed()
	elif event.is_action_pressed('clear_step'):
		on_beginning_pressed()
	if event.is_action_pressed('hexagon'):
		SM.hexagon = !SM.hexagon
	if event.is_action_pressed('mode_draw'):
		MM.mode = MM.Mode.DRAW
		on_pen_toggled(true)
	if event.is_action_pressed('mode_erase'):
		MM.mode = MM.Mode.ERASE
		on_eraser_toggled(true)
	if event.is_action_pressed('mode_default'):
		MM.mode = MM.Mode.DEFAULT
		on_arrow_toggled(true)
	if event.is_action_pressed('play'):
		on_play_toggled(true)
	if event.is_action_pressed('reset'):
		on_beginning_pressed()
	if event.is_action_pressed('step_backward'):
		on_backward_pressed()
	if event.is_action_pressed('step_forward'):
		on_forward_pressed()
	if event.is_action_pressed('stop'):
		on_play_toggled(false)
	for number in range(1, 10):
		if event.is_action_pressed('simulation_steps_' + str(number)):
			var value: float = float(number) * number
			on_speed_changed(value)
			hslider_speed.value = value

func on_arrow_toggled(_toggled_on: bool) -> void:
	texturebutton_arrow.set_pressed_no_signal(true)
	texturebutton_eraser.set_pressed_no_signal(false)
	texturebutton_pen.set_pressed_no_signal(false)
	MM.mode = MM.Mode.DEFAULT

func on_backward_pressed() -> void:
	SM.step_backward()

func on_beginning_pressed() -> void:
	SM.simulation_reset()

func on_clear_pressed() -> void:
	SM.step_clear()

func on_trash_pressed() -> void:
	SM.simulation_clear()

func on_eraser_toggled(_toggled_on: bool) -> void:
	texturebutton_eraser.set_pressed_no_signal(true)
	texturebutton_arrow.set_pressed_no_signal(false)
	texturebutton_pen.set_pressed_no_signal(false)
	MM.mode = MM.Mode.ERASE

func on_forward_pressed() -> void:
	SM.step_forward()

func on_mode_changed(mode: MM.Mode) -> void:
	match mode:
		MM.Mode.DRAW:
			on_pen_toggled(true)
		MM.Mode.ERASE:
			on_eraser_toggled(true)
		_:
			on_arrow_toggled(true)

func on_pen_toggled(_toggled_on: bool) -> void:
	texturebutton_pen.set_pressed_no_signal(true)
	texturebutton_arrow.set_pressed_no_signal(false)
	texturebutton_eraser.set_pressed_no_signal(false)
	MM.mode = MM.Mode.DRAW

func on_play_toggled(toggled_on: bool) -> void:
	SM.is_playing = toggled_on
	texturebutton_play.set_pressed_no_signal(toggled_on)

func on_speed_changed(value: float) -> void:
	SM.steps_per_second = value

func on_zoom_changed(value: float) -> void:
	if camera == null:
		return
	camera.zoom = Vector2(value, value)

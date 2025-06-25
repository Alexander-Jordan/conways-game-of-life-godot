class_name ModeManager extends Node

enum Mode {
	SELECT,
	DRAW,
	ERASE,
}

var cursor_arrow: Texture2D = preload('res://ui/cursors/cursor_arrow.png')
var cursor_eraser: Texture2D = preload('res://ui/cursors/cursor_eraser.png')
var cursor_pen: Texture2D = preload('res://ui/cursors/cursor_pen.png')

var mode: Mode = Mode.SELECT:
	set(m):
		if !Mode.values().has(m) or m == mode:
			return
		mode = m
		if m == Mode.DRAW:
			Input.set_custom_mouse_cursor(cursor_pen, Input.CURSOR_ARROW, Vector2(0, 16))
		elif m == Mode.ERASE:
			Input.set_custom_mouse_cursor(cursor_eraser, Input.CURSOR_ARROW, Vector2(0, 16))
		else:
			Input.set_custom_mouse_cursor(cursor_arrow)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('mode_draw'):
		mode = Mode.DRAW
	if event.is_action_pressed('mode_erase'):
		mode = Mode.ERASE
	if event.is_action_pressed('mode_select'):
		mode = Mode.SELECT

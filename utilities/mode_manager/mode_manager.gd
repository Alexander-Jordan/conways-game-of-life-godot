## The global script for handling different user modes.
class_name ModeManager extends Node

#region ENUMS
## Modes to choose from.
enum Mode {
	DEFAULT,
	DRAW,
	ERASE,
}
#endregion

#region VARIABLES
## The image of the custom arrow cursor.
var cursor_arrow: Texture2D = preload('res://ui/cursors/cursor_arrow.png')
## The image of the custom eraser cursor.
var cursor_eraser: Texture2D = preload('res://ui/cursors/cursor_eraser.png')
## The image of the custom pen cursor.
var cursor_pen: Texture2D = preload('res://ui/cursors/cursor_pen.png')
## The current mode.
var mode: Mode = Mode.DEFAULT:
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
#endregion

#region FUNCTIONS
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('mode_draw'):
		mode = Mode.DRAW
	if event.is_action_pressed('mode_erase'):
		mode = Mode.ERASE
	if event.is_action_pressed('mode_default'):
		mode = Mode.DEFAULT
#endregion

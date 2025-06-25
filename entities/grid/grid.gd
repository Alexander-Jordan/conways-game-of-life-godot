class_name Grid extends TileMapLayer

var cell: Vector2i = Vector2i.ZERO:
	set(c):
		if c == cell:
			return
		cell = c
var mouse_pressed: bool = false

func _process(_delta: float) -> void:
	draw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('clear'):
		clear()
		var next_step: SimulationStep = SM.step_delete()
		set_cells(next_step.cells)
	if event.is_action_pressed('step_backward'):
		SM.steps[SM.current_step_index].cells = get_used_cells()
		clear()
		var next_step: SimulationStep = SM.step_backward()
		set_cells(next_step.cells)
	if event.is_action_pressed('step_forward'):
		SM.steps[SM.current_step_index].cells = get_used_cells()
		clear()
		var next_step: SimulationStep = SM.step_forward()
		set_cells(next_step.cells)
	if event is InputEventMouseButton:
		mouse_pressed = event.pressed

func draw() -> void:
	if mouse_pressed:
		cell = local_to_map(get_global_mouse_position())
		match MM.mode:
			MM.Mode.DRAW:
				if get_cell_source_id(cell) != -1:
					return
				set_cells([cell])
			MM.Mode.ERASE:
				if get_cell_source_id(cell) == -1:
					return
				erase_cell(cell)

func set_cells(cells: Array[Vector2i]) -> void:
	for c in cells:
		set_cell(c, 0, Vector2i(0, 0))

@tool
class_name Grid extends TileMapLayer

@export var hexagon: bool = false:
	set(h):
		if tile_set:
			tile_set.tile_shape = TileSet.TileShape.TILE_SHAPE_HEXAGON if h else TileSet.TileShape.TILE_SHAPE_SQUARE
		hexagon = h
		SM.simulation_clear()
		clear()

var cell: Vector2i = Vector2i.ZERO:
	set(c):
		if c == cell:
			return
		cell = c
var mouse_pressed: bool = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	draw()
	if SM.is_playing:
		SM.time_passed_since_last_step += delta
		if SM.time_passed_since_last_step == 0.0:
			step_forward()

func _ready() -> void:
	SM.reset.connect(func():
		clear()
		cells_add(SM.steps[SM.current_step_index].cells)
	)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if event.is_action_pressed('clear'):
		SM.simulation_clear()
		clear()
	elif event.is_action_pressed('clear_step'):
		clear()
		var next_step: SimulationStep = SM.step_delete()
		cells_add(next_step.cells)
	if event.is_action_pressed('hexagon'):
		hexagon = !hexagon
	if event.is_action_pressed('step_backward'):
		SM.steps[SM.current_step_index].cells = get_used_cells()
		clear()
		var next_step: SimulationStep = SM.step_backward()
		cells_add(next_step.cells)
	if event.is_action_pressed('step_forward'):
		step_forward()
	if event is InputEventMouseButton:
		mouse_pressed = event.pressed

func cells_add(cells: Array[Vector2i]) -> void:
	for c in cells:
		set_cell(c, 0, Vector2i(0, 1 if hexagon else 0))

func cells_erase(cells: Array[Vector2i]) -> void:
	for c in cells:
		erase_cell(cell)

func draw() -> void:
	if mouse_pressed:
		cell = local_to_map(get_global_mouse_position())
		match MM.mode:
			MM.Mode.DRAW:
				if get_cell_source_id(cell) != -1:
					return
				cells_add([cell])
			MM.Mode.ERASE:
				if get_cell_source_id(cell) == -1:
					return
				cells_erase([cell])

func get_all_surrounding_cells(c: Vector2i) -> Array[Vector2i]:
	var surrounding_cells: Array[Vector2i] = get_surrounding_cells(c)
	if !hexagon:
		surrounding_cells.append_array(get_diagonal_cells(c))
	return surrounding_cells

func get_diagonal_cells(c: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER))
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER))
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER))
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER))
	return cells

func get_cells_after_simulation(cells_before: Array[Vector2i]) -> Array[Vector2i]:
	var cells_after: Array[Vector2i] = []
	
	for c in cells_before:
		var surrounding_cells: Array[Vector2i] = get_all_surrounding_cells(c)
		var surrounding_cells_alive: int = 0
		
		for sc in surrounding_cells:
			if cells_before.has(sc):
				surrounding_cells_alive += 1
				continue
			if cells_after.has(sc):
				continue
			
			var sc_surrounding_cells_alive: Array[Vector2i] = get_all_surrounding_cells(sc).filter(
				func(scsc): return cells_before.has(scsc)
			)
			if sc_surrounding_cells_alive.size() == 3:
				cells_after.append(sc)
		
		if [2, 3].has(surrounding_cells_alive):
			cells_after.append(c)
	
	return cells_after

func step_forward() -> void:
	var cells_before: Array[Vector2i] = get_used_cells()
	SM.steps[SM.current_step_index].cells = cells_before
	var cells_after: Array[Vector2i] = get_cells_after_simulation(cells_before)
	SM.step_forward(cells_after)
	clear()
	cells_add(cells_after)

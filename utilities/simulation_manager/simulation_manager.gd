## The global script responsible for the simulation.
class_name SimulationManager extends TileMapLayer

#region CONSTANTS
## The TileSet of this TileMapLayer.
const TILE_SET: TileSet = preload("res://utilities/simulation_manager/tile_set.tres")
#endregion

#region VARIABLES
## The marked cell by the user, for adding or erasing.
var cell: Vector2i = Vector2i.ZERO:
	set(c):
		if c == cell:
			return
		cell = c
## The index of the current simulation step.
var current_step_index: int = 0
## Sets the shape of the tiles to hexagon if set to true.
var hexagon: bool = false:
	set(h):
		if tile_set:
			tile_set.tile_shape = TileSet.TileShape.TILE_SHAPE_HEXAGON if h else TileSet.TileShape.TILE_SHAPE_SQUARE
		hexagon = h
		simulation_clear()
		clear()
## Plays the simulation at steps_per_seconds if set to true.
## Stops the simulation if set to false.
var is_playing: bool = false:
	set(p):
		if p == is_playing:
			return
		is_playing = p
		time_passed_since_last_step = 0.0
## Is the user pressing down the mouse?
var mouse_pressed: bool = false
## All simulation steps.
var steps: Array[SimulationStep] = [SimulationStep.new()]
## How many simulation steps should be calculated per second?
var steps_per_second: float = 2.0
## How much time has passed since last simulation step?
## Only incrementing while the simulation is playing.
var time_passed_since_last_step: float = 0.0:
	set(tp):
		time_passed_since_last_step = 0.0 if tp < 0 or (tp >= 1.0 / steps_per_second) else tp
#endregion

#region FUNCTIONS
#region BUILT-IN
func _init() -> void:
	tile_set = TILE_SET

func _process(delta: float) -> void:
	draw()
	if is_playing:
		time_passed_since_last_step += delta
		if time_passed_since_last_step == 0.0:
			step_forward()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		mouse_pressed = event.pressed
#endregion

#region CELLS
## Adds the cells to the TileMapLayer.
func cells_add(cells: Array[Vector2i]) -> void:
	for c in cells:
		set_cell(c, 0, Vector2i(0, 1 if hexagon else 0))

## Erases the cells to the TileMapLayer.
func cells_erase(cells: Array[Vector2i]) -> void:
	for c in cells:
		erase_cell(cell)

## Returns all surrounding cells, not only the ones touching edges.
## For rectangle tiles, this will result in 8 cells.
func cells_surrounding_all(c: Vector2i) -> Array[Vector2i]:
	var surrounding_cells: Array[Vector2i] = get_surrounding_cells(c)
	if !hexagon:
		surrounding_cells.append_array(cells_surrounding_diagonal(c))
	return surrounding_cells

## Returns all surrounding cells in all diagonal directions.
func cells_surrounding_diagonal(c: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER))
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER))
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER))
	cells.append(get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER))
	return cells

## Simulates and returns alive cells after comparing previous alive cells with simulation rules.[br]
## The rules are:[br]
## 1. Any live cell with fewer than two live neighbors dies.[br]
## 2. Any live cell with two or three neighbors lives on in the next generation.[br]
## 3. Any live cell with more than three live neighbors dies.[br]
## 4. Any dead cell with exactly three live neighbors becomes alive in the next generation.[br]
func cells_simulation(cells_before: Array[Vector2i]) -> Array[Vector2i]:
	var cells_after: Array[Vector2i] = []
	
	for c in cells_before:
		var surrounding_cells: Array[Vector2i] = cells_surrounding_all(c)
		var surrounding_cells_alive: int = 0
		
		for sc in surrounding_cells:
			if cells_before.has(sc):
				surrounding_cells_alive += 1
				continue
			if cells_after.has(sc):
				continue
			
			var sc_surrounding_cells_alive: Array[Vector2i] = cells_surrounding_all(sc).filter(
				func(scsc): return cells_before.has(scsc)
			)
			if sc_surrounding_cells_alive.size() == 3:
				cells_after.append(sc)
		
		if [2, 3].has(surrounding_cells_alive):
			cells_after.append(c)
	
	return cells_after
#endregion

## Responsible for drawing or erasing cells.
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

#region SIMULATION
## This clears the whole simulation, leaving 1 clear simulation step.
func simulation_clear() -> void:
	clear()
	steps.clear()
	steps = [SimulationStep.new()]
	current_step_index = 0

## This resets the playhead of the simulation to the first simulation step.
func simulation_reset() -> void:
	current_step_index = 0
	time_passed_since_last_step = 0.0
	clear()
	cells_add(steps[current_step_index].cells)
#endregion

#region STEP
## This moves the playhead of the simulation 1 step backward.
func step_backward() -> void:
	steps[current_step_index].cells = get_used_cells()
	clear()
	
	var can_create_new_step: bool = !steps[current_step_index].cells.is_empty()
	current_step_index -= 1
	if current_step_index < 0:
		if can_create_new_step:
			steps.push_front(SimulationStep.new())
			current_step_index = 0
		else:
			current_step_index += 1
	
	cells_add(steps[current_step_index].cells)

## This clears the current simulation step from any alive cells.
func step_clear() -> void:
	clear()
	var next_step: SimulationStep = step_delete()
	cells_add(next_step.cells)

## This deletes the current simulation step.
func step_delete() -> SimulationStep:
	if current_step_index == 0:
		if steps.size() == 1:
			steps[current_step_index].cells.clear()
			return steps[current_step_index]
		steps.remove_at(current_step_index)
		return steps[current_step_index]
	
	steps.remove_at(current_step_index)
	current_step_index -= 1
	return steps[current_step_index]

## This moves the playhead of the simulation 1 step forward.
func step_forward() -> void:
	var cells_before: Array[Vector2i] = get_used_cells()
	steps[current_step_index].cells = cells_before
	var cells_after: Array[Vector2i] = cells_simulation(cells_before)
	
	var previous_step: SimulationStep = steps[current_step_index]
	if cells_after == previous_step.cells:
		steps.resize(current_step_index + 1)
		return
	
	current_step_index += 1
	if current_step_index > steps.size() - 1:
		if previous_step.cells.is_empty():
			current_step_index -= 1
		else:
			steps.append(SimulationStep.new())
	steps[current_step_index].cells = cells_after
	
	clear()
	cells_add(cells_after)
#endregion
#endregion

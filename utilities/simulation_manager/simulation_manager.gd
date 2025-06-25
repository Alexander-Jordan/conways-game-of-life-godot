class_name SimulationManager extends Node

var current_step_index: int = 0
var is_playing: bool = false:
	set(p):
		if p == is_playing:
			return
		is_playing = p
		time_passed_since_last_step = 0.0
var steps: Array[SimulationStep] = [SimulationStep.new()]
var steps_per_second: float = 2.0
var time_passed_since_last_step: float = 0.0:
	set(tp):
		time_passed_since_last_step = 0.0 if tp < 0 or (tp >= 1.0 / steps_per_second) else tp

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('reset'):
		pass
	if event.is_action_pressed('play'):
		is_playing = true
	if event.is_action_pressed('stop'):
		is_playing = false

func simulation_clear() -> void:
	steps.clear()
	steps = [SimulationStep.new()]
	current_step_index = 0

func step_backward() -> SimulationStep:
	var can_create_new_step: bool = !steps[current_step_index].cells.is_empty()
	current_step_index -= 1
	if current_step_index < 0:
		if can_create_new_step:
			steps.push_front(SimulationStep.new())
			current_step_index = 0
		else:
			current_step_index += 1
	return steps[current_step_index]

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

func step_forward(cells: Array[Vector2i]) -> void:
	var previous: SimulationStep = steps[current_step_index]
	if cells == previous.cells:
		steps.resize(current_step_index + 1)
		return
	
	current_step_index += 1
	if current_step_index > steps.size() - 1:
		if previous.cells.is_empty():
			current_step_index -= 1
		else:
			steps.append(SimulationStep.new())
	steps[current_step_index].cells = cells

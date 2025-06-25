class_name SimulationManager extends Node

var current_step_index: int = 0
var steps: Array[SimulationStep] = [SimulationStep.new()]

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

func step_forward() -> SimulationStep:
	var can_create_new_step: bool = !steps[current_step_index].cells.is_empty()
	current_step_index += 1
	if current_step_index > steps.size() - 1:
		if can_create_new_step:
			steps.append(SimulationStep.new())
		else:
			current_step_index -= 1
	return steps[current_step_index]

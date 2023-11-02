class_name SudokuCell extends Button

signal CellPressed

@export var current_value: int = 0:
	get: return current_value
	set(v):
		if !immutable:
			_react_to_cell_value(current_value, v)
			current_value = v
@export var immutable: bool = false:
	get: return immutable
	set(v):
		if v:
			_set_immutable()
		else:
			push_warning("Unsetting immutable not implemented")
		immutable = v

func _set_immutable() -> void:
	#add_theme_font_override("weight", 700)
	add_theme_constant_override("weight", 700)
	disabled = true

func mark_cell_invalid() -> void:
	pass

func is_cell_valid() -> bool:
	return current_value >= 0 && current_value <= 9

func is_cell_solved() -> bool:
	return current_value >= 1 && current_value <= 9

func _react_to_cell_value(old_val: int, new_val: int) -> void:
	if new_val == 0:
		text = " "
	else:
		text = str(new_val)

func _on_pressed() -> void:
	if !immutable:
		emit_signal("CellPressed")

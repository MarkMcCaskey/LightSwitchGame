class_name SudokuGrid extends GridContainer

@export var grid_id: int

@onready var cell_0_0: SudokuCell = $Cell_0_0
@onready var cell_0_1: SudokuCell = $Cell_0_1
@onready var cell_0_2: SudokuCell = $Cell_0_2
@onready var cell_1_0: SudokuCell = $Cell_1_0
@onready var cell_1_1: SudokuCell = $Cell_1_1
@onready var cell_1_2: SudokuCell = $Cell_1_2
@onready var cell_2_0: SudokuCell = $Cell_2_0
@onready var cell_2_1: SudokuCell = $Cell_2_1
@onready var cell_2_2: SudokuCell = $Cell_2_2

@onready var cells: Array[SudokuCell] = [cell_0_0, cell_0_1, cell_0_2, cell_1_0, cell_1_1, cell_1_2, cell_2_0, cell_2_1, cell_2_2]

signal CellPressedInGrid(grid_id: int, idx: int)

func grid_is_valid() -> bool:
	for cell in cells:
		if !cell.is_cell_valid():
			return false
	var n_set := {}
	for cell in cells:
		if cell.current_value == 0:
			continue
		var prev_len: int = len(n_set)
		n_set[cell] = null
		var new_len: int = len(n_set)
		if prev_len == new_len:
			return false
	return true

func grid_is_solved() -> bool:
	for cell in cells:
		if !cell.is_cell_solved():
			return false
	var n_set := {}
	for cell in cells:
		var prev_len: int = len(n_set)
		n_set[cell] = null
		var new_len: int = len(n_set)
		if prev_len == new_len:
			return false
	return true

func _on_cell_pressed(idx: int) -> void:
	emit_signal("CellPressedInGrid", grid_id, idx)

func set_value_at(i: int, j: int, v: int, immutable: bool) -> void:
	var idx = (i * 3) + j
	cells[idx].current_value = v
	if v != 0 && immutable:
		cells[idx].immutable = true

func set_value_at_direct(idx: int, v: int) -> void:
	cells[idx].current_value = v

func get_row_0() -> Array[int]:
	return [cell_0_0.current_value, cell_0_1.current_value, cell_0_2.current_value]

func get_row_1() -> Array[int]:
	return [cell_1_0.current_value, cell_1_1.current_value, cell_1_2.current_value]

func get_row_2() -> Array[int]:
	return [cell_2_0.current_value, cell_2_1.current_value, cell_2_2.current_value]

func get_col_0() -> Array[int]:
	return [cell_0_0.current_value, cell_1_0.current_value, cell_2_0.current_value]

func get_col_1() -> Array[int]:
	return [cell_0_1.current_value, cell_1_1.current_value, cell_2_1.current_value]

func get_col_2() -> Array[int]:
	return [cell_0_2.current_value, cell_1_2.current_value, cell_2_2.current_value]


func _on_cell_0_0_cell_pressed() -> void:
	_on_cell_pressed(0)
func _on_cell_0_1_cell_pressed() -> void:
	_on_cell_pressed(1)
func _on_cell_0_2_cell_pressed() -> void:
	_on_cell_pressed(2)
func _on_cell_1_0_cell_pressed() -> void:
	_on_cell_pressed(3)
func _on_cell_1_1_cell_pressed() -> void:
	_on_cell_pressed(4)
func _on_cell_1_2_cell_pressed() -> void:
	_on_cell_pressed(5)
func _on_cell_2_0_cell_pressed() -> void:
	_on_cell_pressed(6)
func _on_cell_2_1_cell_pressed() -> void:
	_on_cell_pressed(7)
func _on_cell_2_2_cell_pressed() -> void:
	_on_cell_pressed(8)

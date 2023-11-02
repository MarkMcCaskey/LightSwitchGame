class_name Sudoku extends Control

signal SudokuComplete
signal SudokuQuit

@onready var grid_0_0: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_0_0
@onready var grid_0_1: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_0_1
@onready var grid_0_2: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_0_2
@onready var grid_1_0: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_1_0
@onready var grid_1_1: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_1_1
@onready var grid_1_2: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_1_2
@onready var grid_2_0: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_2_0
@onready var grid_2_1: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_2_1
@onready var grid_2_2: SudokuGrid = $CenterContainer/TextureRect/GridContainer/SudokuGrid_2_2

# Array[Array[SudokuGrid]]
@onready var row_order = [
	[grid_0_0, grid_0_1, grid_0_2],
	[grid_1_0, grid_1_1, grid_1_2],
	[grid_2_0, grid_2_1, grid_2_2]
]

@onready var col_order = [
	[grid_0_0, grid_1_0, grid_2_0],
	[grid_0_1, grid_1_1, grid_2_1],
	[grid_0_2, grid_1_2, grid_2_2]
]
var selected_grid: int = -1
var selected_idx: int = -1

func _ready() -> void:
	var i = 0
	for row in row_order:
		for grid in row:
			grid.grid_id = i
			i += 1
			grid.connect("CellPressedInGrid", _on_cell_pressed)
	load_sudoku()

func is_solved() -> bool:
	return are_grids_solved() && are_rows_solved() && are_cols_solved()

func are_grids_solved() -> bool:
	for row in row_order:
		for grid in row:
			if !grid.grid_is_solved():
				return false
	return true

func are_rows_solved() -> bool:
	return _inner_check(row_order, [Callable(SudokuGrid, "get_row_0"), Callable(SudokuGrid, "get_row_1"), Callable(SudokuGrid, "get_row_2")])
#	for i in range(3):
#		var set_0 := {}
#		var set_1 := {}
#		var set_2 := {}
#		for grid in row_order[i]:
#			for n in grid.get_row_0():
#				if n == 0: return false
#				var prev_len: int = len(set_0)
#				set_0[n] = null
#				var new_len: int = len(set_0)
#				if prev_len == new_len:
#					return false
#			for n in grid.get_row_1():
#				if n == 0: return false
#				var prev_len: int = len(set_1)
#				set_1[n] = null
#				var new_len: int = len(set_1)
#				if prev_len == new_len:
#					return false
#			for n in grid.get_row_2():
#				if n == 0: return false
#				var prev_len: int = len(set_2)
#				set_2[n] = null
#				var new_len: int = len(set_2)
#				if prev_len == new_len:
#					return false
#	return true

func are_cols_solved() -> bool:
	return _inner_check(col_order, [Callable(SudokuGrid, "get_col_0"), Callable(SudokuGrid, "get_col_1"), Callable(SudokuGrid, "get_col_2")])

func _inner_check(order, methods: Array[Callable]) -> bool:
	for i in len(order):
		for method in methods:
			var n_set := {}
			for grid in order[i]:
				for n in method.call(grid):
					if n == 0: return false
					var prev_len: int = len(n_set)
					n_set[n] = null
					var new_len: int = len(n_set)
					if prev_len == new_len:
						return false
	return true

func load_sudoku() -> void:
	var json: JSON = load("res://Puzzles/sudoku1.json")
	init_sudoku(json.data)

func init_sudoku(vals) -> void:
	for i in range(9):
		for j in range(9):
			var grid = row_order[i % 3][j % 3]
			var i_idx: int = i / 3
			var j_idx: int = j / 3
			grid.set_value_at(i_idx, j_idx, vals[i][j], true)

func _on_cell_pressed(grid_id: int, idx: int) -> void:
	print("(" + str(grid_id) + ", " + str(idx) + ")")
	selected_grid = grid_id
	selected_idx = idx

func _set_value_at_selected(val: int) -> void:
	row_order[selected_grid / 3][selected_grid % 3].set_value_at_direct(selected_idx, val)
	if val != 0:
		if is_solved():
			emit_signal("SudokuComplete")

func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if selected_grid == -1 || selected_idx == -1:
		return
	_set_value_at_selected(index + 1)

func _unhandled_input(event: InputEvent) -> void:
	var num_input: int = -1
	if event.is_action_pressed("1"): num_input = 1
	elif event.is_action_pressed("2"): num_input = 2
	elif event.is_action_pressed("3"): num_input = 3
	elif event.is_action_pressed("4"): num_input = 4
	elif event.is_action_pressed("5"): num_input = 5
	elif event.is_action_pressed("6"): num_input = 6
	elif event.is_action_pressed("7"): num_input = 7
	elif event.is_action_pressed("8"): num_input = 8
	elif event.is_action_pressed("9"): num_input = 9
	elif event.is_action("ui_cancel"): emit_signal("SudokuQuit")
	
	if num_input != -1:
		_set_value_at_selected(num_input)
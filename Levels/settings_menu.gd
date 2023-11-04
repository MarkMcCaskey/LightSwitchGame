class_name SettingsMenu extends Control

signal SettingsClosed

@onready var puzzle_seed: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/PuzzleSeed/PSSpinBox
@onready var rng_enabled: CheckButton = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/Randomness/CheckButton 
@onready var difficulty: OptionButton = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/Difficulty/OptionButton
@onready var monster_level: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/MonsterAggression/MASpinBox

func _ready() -> void:
	puzzle_seed.value = Settings.sudoku_rng_seed
	rng_enabled.button_pressed = Settings.sudoku_rng_enabled
	var idx = 0
	match Settings.sudoku_difficulty:
		Sudoku.PuzzleDifficulty.Easy: idx = 0
		Sudoku.PuzzleDifficulty.Medium: idx = 1
		Sudoku.PuzzleDifficulty.Hard: idx = 2
	difficulty.selected = idx
	monster_level.value = Settings.monster_agression
	if Settings.sudoku_rng_enabled:
		_rng_enable()
	else:
		_rng_disable()

func _get_difficulty() -> Sudoku.PuzzleDifficulty:
	match difficulty.selected:
		2: return Sudoku.PuzzleDifficulty.Hard
		1: return Sudoku.PuzzleDifficulty.Medium
		_: return Sudoku.PuzzleDifficulty.Easy

func _flush_game_settings() -> void:
	Settings.sudoku_rng_seed = puzzle_seed.value
	Settings.sudoku_rng_enabled = rng_enabled.button_pressed
	Settings.sudoku_difficulty = _get_difficulty()
	Settings.monster_agression = monster_level.value

func _rng_disable() -> void:
	puzzle_seed.editable = true

func _rng_enable() -> void:
	puzzle_seed.value = 0
	puzzle_seed.editable = false

func _on_check_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_rng_enable()
	else:
		_rng_disable()
	_flush_game_settings()

func _on_option_button_item_selected(index: int) -> void:
	print(str(index) + " " + str(difficulty.selected))
	_flush_game_settings()

func _on_ps_spin_box_value_changed(value: float) -> void:
	var v: int = int(value)
	if v < 0 || v > 400:
		return
	_flush_game_settings()

func _on_ma_spin_box_value_changed(value: float) -> void:
	var v: int = int(value)
	if v < 1 || v > 20:
		return
	_flush_game_settings()


func _on_check_box_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): emit_signal("SettingsClosed")

func _on_back_button_pressed() -> void:
	emit_signal("SettingsClosed")

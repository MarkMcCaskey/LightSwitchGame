class_name SettingsMenu extends Control

signal SettingsClosed

@onready var puzzle_seed: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/PuzzleSeed/PSSpinBox
@onready var rng_enabled: CheckButton = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/Randomness/CheckButton 
@onready var difficulty: OptionButton = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/Difficulty/OptionButton
@onready var monster_level: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/MonsterAggression/MASpinBox
@onready var monster_xp_mult: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/MonsterXpMultiplier/MXPSpinBox
@onready var monster_vxp: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/MonsterVisionXp/MVXPSpinBox
@onready var monster_ad: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/MonsterAggressionDenom/MADSpinBox
@onready var monster_dxp: SpinBox = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/MonsterDistractionXp/MDXPSpinBox
@onready var light_xp: CheckButton = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/LightsGiveXp/LightXpCheckButton
@onready var guarantee_dist: CheckButton = $TabContainer/Game/ScrollContainer/CenterContainer/VBoxContainer/GuaranteeDistraction/GuaranteeDistractionCheckButton

func _ready() -> void:
	puzzle_seed.value = Settings.sudoku_rng_seed
	rng_enabled.button_pressed = Settings.sudoku_rng_enabled
	light_xp.button_pressed = Settings.monster_lights_give_xp
	guarantee_dist.button_pressed = Settings.guarantee_distraction_spawn
	var idx = 0
	match Settings.sudoku_difficulty:
		Sudoku.PuzzleDifficulty.Easy: idx = 0
		Sudoku.PuzzleDifficulty.Medium: idx = 1
		Sudoku.PuzzleDifficulty.Hard: idx = 2
	difficulty.selected = idx
	monster_level.value = Settings.monster_move_chance
	monster_xp_mult.value = Settings.monster_xp_multiplier
	monster_vxp.value = Settings.monster_vision_xp
	monster_ad.value = Settings.monster_move_chance_denom
	monster_dxp.value = Settings.monster_distraction_xp_amount
	puzzle_seed.apply()
	monster_level.apply()
	monster_xp_mult.apply()
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
	Settings.monster_move_chance = monster_level.value
	Settings.monster_xp_multiplier = monster_xp_mult.value
	Settings.monster_vision_xp = monster_vxp.value
	Settings.monster_move_chance_denom = floori(monster_ad.value)
	Settings.monster_distraction_xp_amount = monster_dxp.value
	Settings.monster_lights_give_xp = light_xp.button_pressed
	Settings.guarantee_distraction_spawn = guarantee_dist.button_pressed

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

#var monster_agression: float = 1.5
#var monster_move_chance: int = 2#25
#var monster_lights_give_xp: bool = true
#var monster_distraction_xp_amount: float = 3.0
#var monster_xp_multiplier: float = 1.0
#var monster_vision_xp: float = 1.3
## 1 = every level, 2 = every other, 3 = every third
#var monster_move_chance_denom: int = 2
#
#var guarantee_distraction_spawn: bool = true


func _on_mxp_spin_box_value_changed(_value: float) -> void:
	_flush_game_settings()

func _on_mvxp_spin_box_value_changed(_value: float) -> void:
	_flush_game_settings()

func _on_mad_spin_box_value_changed(_value: float) -> void:
	_flush_game_settings()

func _on_mdxp_spin_box_value_changed(_value: float) -> void:
	_flush_game_settings()

func _on_light_xp_check_button_toggled(_button_pressed: bool) -> void:
	_flush_game_settings()

func _on_guarantee_distraction_check_button_toggled(_button_pressed: bool) -> void:
	_flush_game_settings()

extends Node

var sudoku_difficulty: Sudoku.PuzzleDifficulty = Sudoku.PuzzleDifficulty.Easy
var sudoku_rng_enabled: bool = true
var sudoku_rng_seed: int = 0

var monster_agression: float = 1.5
var monster_move_chance: int = 2#25
var monster_lights_give_xp: bool = true
var monster_distraction_xp_amount: float = 3.0
var monster_xp_multiplier: float = 1.0
var monster_vision_xp: float = 1.3
# 1 = every level, 2 = every other, 3 = every third
var monster_move_chance_denom: int = 2

var guarantee_distraction_spawn: bool = true

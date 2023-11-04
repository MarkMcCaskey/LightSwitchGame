extends Node3D

@onready var bgm_player1: AudioStreamPlayer = $BGMPlayer1
@onready var bgm_player2: AudioStreamPlayer = $BGMPlayer2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var monster: ScaryDude = $ScaryDude
@onready var monster_powerup_timer: Timer = $MonsterPowerUpTimer

const safety4 := preload("res://Assets/Audio/atmoseerie04.ogg")
const safety3 := preload("res://Assets/Audio/atmoseerie01.ogg")
const safety2 := preload("res://Assets/Audio/atmoseerie02.ogg")
const safety1 := preload("res://Assets/Audio/atmoseerie03.ogg")
enum Bgm { Crickets }

var track1_active: bool = true

func _ready() -> void:
	bgm_player1.play()

func crossfade_bgm(audio_stream: AudioStream) -> void:
	if bgm_player1.playing && bgm_player2.playing:
		return
	
	if bgm_player2.playing:
		bgm_player1.stream = audio_stream
		bgm_player1.play()
		animation_player.play("FadeToTrack1")
	else:
		bgm_player2.stream = audio_stream
		bgm_player2.play()
		animation_player.play("FadeToTrack2")

func _select_new_bgm(level: int):
	if level >= 4: return safety4
	if level >= 3: return safety3
	if level >= 2: return safety2
	else: return safety1
	
func _on_scary_dude_scary_dude_safety_level_changed(_old: int, new: int) -> void:
	crossfade_bgm(_select_new_bgm(new))

#var monster_agression: float = 5
#var monster_lights_give_xp: bool = true
#var monster_distraction_xp_amount: float = 3
#var monster_xp_multiplier: float = 1.0
func _on_monster_power_up_timer_timeout() -> void:
	var xp: float = 1.5
	if Settings.monster_lights_give_xp:
		var light_count: int = 0
		for node in get_tree().get_nodes_in_group("lights"):
			if node.is_on:
				light_count += 1
		xp += float(light_count)
	monster.add_xp(xp)
	monster_powerup_timer.start(randf_range(2.0, 70.0))

extends Node3D

@onready var bgm_player1: AudioStreamPlayer = $BGMPlayer1
@onready var bgm_player2: AudioStreamPlayer = $BGMPlayer2
@onready var bgm_low_constant: AudioStreamPlayer = $BGMLowConstant
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $Player
@onready var monster: ScaryDude = $ScaryDude
@onready var house: Node3D = $House
@onready var monster_powerup_timer: Timer = $MonsterPowerUpTimer
@onready var good_win_scene_location: Node3D = $GoodWinSceneLocation
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var distraction_manager: DistractionManager = $DistractionManager
@onready var distraction_timer: Timer = $DistractionManager/DistractionTimer

const win_scene: PackedScene = preload("res://Entities/WinScene.tscn")
const safety4 := preload("res://Assets/Audio/atmoseerie04.ogg")
const safety3 := preload("res://Assets/Audio/atmoseerie01.ogg")
const safety2 := preload("res://Assets/Audio/atmoseerie02.ogg")
const safety1 := preload("res://Assets/Audio/atmoseerie03.ogg")
enum Bgm { Crickets }

var track1_active: bool = true

func _ready() -> void:
	bgm_low_constant.volume_db = -30
	bgm_low_constant.play()

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

func _on_player_dying() -> void:
	animation_player.play("FadeBothOut")
	monster.stop_monster_sounds()
	monster.hide()

func _play_win_scene() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	if player:
		player.has_control = false
	world_environment.environment.ambient_light_energy = 10
	world_environment.environment.fog_enabled = false
	var win = win_scene.instantiate()
	good_win_scene_location.add_child(win)

func _on_house_house_complete() -> void:
	animation_player.play("FadeBothOut")
	monster.stop_monster_sounds()
	monster.hide()
	player.hide_everything()
	player.hide()
	_play_win_scene()

func _on_distraction_timer_timeout() -> void:
	distraction_manager.generate_distraction(1)
	distraction_timer.start(randf_range(19.3, 79.3) / monster.monster_aggression)

# The player shouldn't be able to see anything anymore
func _on_player_seeing_static() -> void:
	house.hide()

func _on_player_house_status_changed(is_in_house) -> void:
	var tween := get_tree().create_tween()
	var target: float = -33.
	if is_in_house: target = -33.
	else: target = -20.
	
	tween.tween_property(bgm_low_constant, "volume_db", target, 0.7).set_ease(Tween.EASE_IN)

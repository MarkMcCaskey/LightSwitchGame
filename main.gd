extends Node3D

@onready var bgm_player1: AudioStreamPlayer = $BGMPlayer1
@onready var bgm_player2: AudioStreamPlayer = $BGMPlayer2
@onready var bgm_low_constant: AudioStreamPlayer = $BGMLowConstant
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $Player
var monster: ScaryDude
@onready var house: Node3D = $House
@onready var monster_powerup_timer: Timer = $MonsterPowerUpTimer
@onready var good_win_scene_location: Node3D = $GoodWinSceneLocation
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var distraction_manager: DistractionManager = $DistractionManager
@onready var distraction_timer: Timer = $DistractionManager/DistractionTimer
@onready var monster_spawn_timer: Timer = $MonsterSpawnTimer

@onready var tv_triggered: bool = false
@onready var player_entered_house_at_least_once: bool = false

const win_scene: PackedScene = preload("res://Entities/WinScene.tscn")
const safety4 := preload("res://Assets/Audio/atmoseerie04.ogg")
const safety3 := preload("res://Assets/Audio/atmoseerie01.ogg")
const safety2 := preload("res://Assets/Audio/atmoseerie02.ogg")
const safety1 := preload("res://Assets/Audio/atmoseerie03.ogg")
enum Bgm { Crickets }

const monster_scene = preload("res://Entities/scary_dude.tscn")

var track1_active: bool = true

func _ready() -> void:
	bgm_low_constant.volume_db = -20.
	bgm_low_constant.play()
	# If the player doesn't enter the house, spawn the monster after 2 minutes
	monster_spawn_timer.start(117.3)

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
	if monster:
		monster.add_xp(xp)
	monster_powerup_timer.start(randf_range(2.0, 49.0))

func _on_player_dying() -> void:
	animation_player.play("FadeBothOut")
	if monster:
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
	if monster:
		monster.stop_monster_sounds()
		monster.hide()
	player.hide_everything()
	player.hide()
	_play_win_scene()

func _on_distraction_timer_timeout() -> void:
	var found: bool = distraction_manager.generate_distraction(1)
	if Settings.guarantee_distraction_spawn:
		while !found:
			found = distraction_manager.generate_distraction(1)
	_start_distraction_timer()

func _start_distraction_timer() -> void:
	var divisior: float = Settings.monster_agression
	if monster:
		divisior = monster.monster_aggression
	var bonus: float = 1.0
	if Settings.guarantee_distraction_spawn:
		# just to make it less annoying
		bonus = 2.23
	distraction_timer.start((randf_range(24.3, 105.3) * bonus) / divisior)

# The player shouldn't be able to see anything anymore
func _on_player_seeing_static() -> void:
	house.hide()

func _player_entered_house_for_the_first_time() -> void:
	_start_distraction_timer()
	monster_spawn_timer.start(randf_range(1.0, 15.0))

func _on_player_house_status_changed(is_in_house) -> void:
	var tween := get_tree().create_tween()
	var vol_target: float = -40.
	var light_target: float = 1.0
	var fog_target: float = 0.05
	if is_in_house:
		vol_target = -40.
		light_target = 1.0
		fog_target = 0.07
		if monster:
			monster.notify_player_inside()
		if !player_entered_house_at_least_once:
			player_entered_house_at_least_once = true
			_player_entered_house_for_the_first_time()
	else:
		vol_target = -20.
		light_target = 5.0
		fog_target = 0.04
		if monster:
			monster.notify_player_outside()
	
	tween.tween_property(bgm_low_constant, "volume_db", vol_target, 0.7).set_ease(Tween.EASE_IN)
	var environment := world_environment.environment
	tween.tween_property(environment, "ambient_light_energy", light_target, 1.0).set_ease(Tween.EASE_IN)
	tween.tween_property(environment, "fog_density", fog_target, 1.0).set_ease(Tween.EASE_IN)

func _on_monster_spawn_timer_timeout() -> void:
	# when we do this, we'll need to make sure the other code can handle no monster existing
	print("SPAWN MONSTER!")
	monster = monster_scene.instantiate()
	add_child(monster)
	monster.connect("ScaryDudeSafetyLevelChanged", _on_scary_dude_scary_dude_safety_level_changed)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		if !player_entered_house_at_least_once && !tv_triggered:
			tv_triggered = true
			house.turn_on_living_room_tv()

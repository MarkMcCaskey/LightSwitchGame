extends Node2D

const section_time := 2.0
const line_time := 0.7
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color.BLUE_VIOLET

var scroll_speed := base_speed
var speed_up := false

@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"Enigma of the Eldritch Elk",
		"Submitted to the Let's Make Something 2023 Game Jam"
	],[
		"Programming and Design",
		"Mark",
	],[
		"Additional Programming and Design",
		"Branden",
	],[
		"Art",
		"House model + textures:", "https://elbolilloduro.itch.io/house - CC0",
		"Mixamo Animations",
		"Halloween assets + textures:", "https://elbolilloduro.itch.io/halloween - CC0",
		"Empty sudoku board:", "https://commons.wikimedia.org/wiki/File:9x9_Empty_Sudoku_Grid.svg - CC0",
		"Splash Screen Logo:", "ChatGPT 4 + Dalle 3"
	],[
		"Godot / Code References",
		"Simple First Person Controller Template:", "https://github.com/rbarongr/GodotFirstPersonController - CC0",
		"TV static shader:", "https://godotshaders.com/shader/tv-noise-effect/ - CC0",
		"Glass Material Reference:", "https://gitlab.com/zolno/godot-experiments/-/tree/glass - MIT",
		"Credits System:", "https://github.com/benbishopnz/godot-credits/tree/master - MIT"
	],[
		"Data",
		"Rated sudoku puzzle data:", "https://github.com/grantm/sudoku-exchange-puzzle-bank - Public Domain"
	],[
		"Sound",
		"Ghost breath:", "https://opengameart.org/content/ghost-breath - CC0",
		"Wind woosh loop:", "https://opengameart.org/content/wind-whoosh-loop - CC0",
		"Ghost noises:", "https://opengameart.org/content/ghost-monster-voice-moaning-growling - CC0",
		"TV static:", "https://freesound.org/people/qubodup/sounds/188798/ - CC0",
		"Dark Ambiences:", "https://opengameart.org/content/dark-ambiences - CC0",
		"Title music (upsidedown grin):", "https://opengameart.org/content/upside-down-grin-freaky-ambient - CC0",
		"Atmospheric ambient loops:", "https://opengameart.org/content/4-atmospheric-ghostly-loops - CC0",
		"Crickets ambient:", "https://opengameart.org/content/crickets-ambient-noise-loopable - CC0",
		"UI sounds - atmospheric interaction pack:", "https://opengameart.org/content/atmospheric-interaction-sound-pack - CC0",
		"GUI sound effects:", "https://opengameart.org/content/gui-sound-effects - CC0",
		"Arr!:", "https://opengameart.org/content/arr - CC0",
		"They're coming:", "https://opengameart.org/content/their-coming-generic-horn-sound - CC0",
		"Monster or beast sounds:", "https://opengameart.org/content/monster-or-beast-sounds - CC0",
		"Excited horror sound:", "https://opengameart.org/content/excited-horror-sound - CC0",
		"Evil creature ambient:", "https://opengameart.org/content/evil-creature - CC0",
		"Big Scary troll noises:", "https://opengameart.org/content/big-scary-troll-sounds - CC0",
		"click sound:", "https://opengameart.org/content/click-sounds6 - CC0",
		"Knocking sound:", "https://freesound.org/people/iamadam19/sounds/362633/ - CC0",
		"Knocking on window:", "https://pixabay.com/sound-effects/knocking-on-window-99754/ - royalty free / \"for free use\"",
		"Misc SFX:", "https://opengameart.org/content/sound-effects-pack - CC0",
	],[
		"Testers",
		"lol",
		"lmao even"
	],[
		"Tools used",
		"Godot",
		"Blender",
		"Audacity"
	],[
		"Thanks for playing!"
	]
]


func _process(delta: float):
	var scroll_speed := base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.position.y -= scroll_speed
			if l.position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		# NOTE: This is called when the credits finish
		# - Hook up your code to return to the relevant scene here, eg...
		var main_menu = load("res://Levels/title_screen_background.tscn")
		get_tree().change_scene_to_packed(main_menu)


func add_line():
	var new_line: Label = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		new_line.add_theme_color_override("font_color", title_color)
	else:
		new_line.add_theme_color_override("font_color", Color.BLACK)
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false

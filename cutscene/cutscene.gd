extends Control

# Resources for the full story sequence
var _story: Dictionary  
var _characters: Dictionary  # Map of character name to map of character emotions to images.
var _backgrounds: Dictionary
var ambiance: Dictionary

@export var non_speaking_color: Color = Color(0.8, 0.8, 0.8, 0.8)
@export var period_pause_time_scale: float = 10  # When we hit a period, we wait for time_between_characters * this.

@export var time_between_characters: float = 0.01
var time_to_next_character: float = 0.0
var text_advancement_paused_on_input: bool = false
var terminal_events_fired: bool = false  # Something of a trigger hack.  This is set to true when the finish condition fires because we aren't properly blocking on the minigame stuff.

# Silly input tracking because we have no real concept of mouse released:
var mouse_released: bool = false
var mouse_just_released: bool = false  # Trigger advances on mouse-up.

# Resources for the current dialog:
var _loaded: bool = false
var _raw_data: Dictionary   # Holds the raw JSON data before we've assigned it to speakers and buttons.
var actor_name_to_texture_rect: Dictionary = {}
var character_index_to_actor_switch: Dictionary = {}  # Maps an integer to an actor or actor:emote combo.
var next_scene: String = ""  # If we auto-advance
var game_data: Variant = null

# These will all be reinitialized in their respective _load_x functions because .load(...) might be called before ready.
@onready var bg: TextureRect = %Background
@onready var speaker_images: HBoxContainer = %Speakers
@onready var dialog_out: RichTextLabel = %DialogOutput
@onready var prompt_and_choices: Control = %PromptAndChoices
@onready var choices: GridContainer = %Choices
@onready var prompt: RichTextLabel = %Prompt

@onready var type_noise: AudioStreamPlayer = %TickNoise

@onready var speaker_template: TextureRect = %SpeakerTemplate
@onready var button_template: Button = %ButtonTemplate


func _ready():
	self.speaker_images.remove_child(self.speaker_template)
	self.button_template.get_parent().remove_child(self.button_template)
	
	# DEBUG!
	#self.init_scene()
	#self.start_scene()


func init_scene(data: Variant):
	var fin = FileAccess.open(data["sequence"], FileAccess.READ)
	self.load_story_from_json(fin.get_as_text())


func start_scene():
	# Expect {"sequence_name": "res://cutscene/...json", "start_dialog": "some_dialog"}
	self.load_dialog(self._story["start"])


func _process(delta):
	self._maybe_advance_dialog(delta)
	
	# Special handling for triggering on mouse release.
	self.mouse_just_released = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		self.mouse_released = false
	else:
		if not self.mouse_released:
			self.mouse_just_released = true
		self.mouse_released = true


func get_background(bg_name: String) -> ImageTexture:
	return self._backgrounds[bg_name.to_lower()]


func get_character(character_name: String, emotion: String = "") -> ImageTexture:
	if emotion == "" or emotion == "null":
		emotion = "default"
	return self._characters[character_name.to_lower()][emotion.to_lower()]


func load_story_from_json(json_string: String):
	var all_data = JSON.parse_string(json_string)
	
	self._story = all_data["story"]
	var assets = all_data["assets"]
	var chars = assets["characters"]
	var bgs = assets["backgrounds"]
	var sfx = assets["sounds"]
	var afx = assets["ambiance"]  # Music, etc.
	
	# Convert images.
	self._characters = {}
	for character_name in chars.keys():
		var emotions = chars[character_name]
		self._characters[character_name.to_lower()] = {}
		for emote in emotions.keys():
			var image_data: String = chars[character_name][emote]
			self._characters[character_name.to_lower()][emote.to_lower()] = self.load_image_from_story_asset(image_data)
	
	for background_name in bgs.keys():
		self._backgrounds[background_name.to_lower()] = self.load_image_from_story_asset(bgs[background_name])
	
	printerr("TODO: Load ambiance")


func load_image_from_story_asset(image_data: String) -> ImageTexture:
	# Base64 -> bytes -> Image -> ImageTexture -> Texture2D
	#var image = Image.load_from_file("res://icon.svg")
	#var texture = ImageTexture.create_from_image(image)
	#$Sprite2D.texture = texture
	var image: Image = Image.new()
	var img_tex: ImageTexture
	if image_data.begins_with("png:"):
		print("Load b64")
		image.load_png_from_buffer(Marshalls.base64_to_raw(image_data.substr("png:".length())))
		img_tex = ImageTexture.create_from_image(image)
	elif image_data.begins_with("file:"):
		print("Load file ", image_data.substr("file:".length()))
		image = Image.load_from_file("user://" + image_data.substr("file:".length()))
		img_tex = ImageTexture.create_from_image(image)
	elif image_data.begins_with("res:"):
		image = load(image_data) as Image
		img_tex = ImageTexture.create_from_image(image)
	elif image_data.begins_with("svg:"):
		var e: Error = image.load_svg_from_string(image_data.substr("svg:".length()))
		if not e:
			img_tex = ImageTexture.create_from_image(image)
		else:
			printerr("ERROR LOADING SVG RESOURCE: ", e)
	else:
		printerr("Failed to load image asset with type: ", image_data.substr(0, 10))
	return img_tex


func save_default_story():
	if FileAccess.file_exists("user://default_story.json"):
		return
	# Creates the default story in the user data folder if it does not exist.
	print("Creating default story.")
	var fout = FileAccess.open("user://default_story.json", FileAccess.WRITE)
	var fin = FileAccess.open("res://default_story.json", FileAccess.READ)
	fout.store_string(fin.get_as_text())


func load_dialog(data: Dictionary):
	self._loaded = false
	# See the reference scene.
	# Named load_dialog instead of load to avoid name conflict.
	for required_field in ["background", "actors", "text", "prompt", "options", "next", "on_enter", "minigame", "next"]:
		if not data.has(required_field):
			printerr("Scene missing required field: ", required_field)
	self._raw_data = data
	self._finish_loading.call_deferred()


func _finish_loading():
	self._load_bg(self._raw_data)
	self._load_actors(self._raw_data)
	self._load_choices(self._raw_data)
	self._load_text(self._raw_data)
	self._load_play_data(self._raw_data)
	self.next_scene = self._raw_data["next"]
	var on_enter_command:String = self._raw_data["on_enter"]
	# Reset init values.
	self.dialog_out.visible = true
	self.prompt_and_choices.visible = false
	self.terminal_events_fired = false  
	self._loaded = true
	
	if not on_enter_command.is_empty():
		self.call(on_enter_command)


func _load_bg(data: Dictionary):
	# Set the background
	var bg_name = data["background"]
	if bg_name:
		bg.texture = self.get_background(bg_name)
		bg.visible = true
	else:
		bg.visible = false


func _load_actors(data: Dictionary):
	# Load actors into places.
	self.actor_name_to_texture_rect.clear()
	for c in self.speaker_images.get_children():
		self.speaker_images.remove_child(c)
		c.queue_free()
	for a_name in data["actors"]:
		var r: TextureRect = self.speaker_template.duplicate()
		self.actor_name_to_texture_rect[a_name.to_lower()] = r
		r.texture = self.get_character(a_name)
		self.speaker_images.add_child(r)


func _load_choices(data: Dictionary):
	# Preload prompt+option text.
	self.prompt.text = data["prompt"]
	for old_choice in self.choices.get_children():
		if old_choice == self.prompt:
			# HACK!
			# Don't free the prompt!
			continue
		self.choices.remove_child(old_choice)
		old_choice.queue_free()
	for opt_text in data["options"].keys():
		var choice: Button = button_template.duplicate()
		choice.text = opt_text
		var opt_next_scene = data["options"][opt_text]
		choice.pressed.connect(self.load_dialog.bind(self._story[opt_next_scene]))
		self.choices.add_child(choice)
	if len(data["options"]) > 0 and self.prompt.text.is_empty():
		printerr("WARNING: Got 'prompt' with no options!  Make sure the text shows options!")


func _load_text(data: Dictionary):
	# Parse the text and extract characters swaps and key events.
	self.character_index_to_actor_switch.clear()
	# This is a stupid/gross finite-state machine for parsing.
	#var previous_character: String = ''  # Don't bother with escape characters yet.
	var text_buffer: String = ""
	var name_buffer: String = ""
	for c in data["text"]:
		if not name_buffer.is_empty():
			# We are filling the name buffer.
			if c == ']':
				# We finished filling the name buffer.
				self.character_index_to_actor_switch[text_buffer.length()] = name_buffer.strip_edges()  # Have to trim the ' ' prefix.
				name_buffer = ""
			else:
				name_buffer += c
		elif c == '[':  # We were parsing text and came across a left paren.
			name_buffer += " "
		else:
			text_buffer += c
	self.dialog_out.visible_characters = 0
	self.dialog_out.text = text_buffer
	self.set_speaker("")
	#var tr: TextureRect = $MarginContainer/VBoxContainer/Speakers/Speaker1
	#tr.texture = Texture2D.new()
	#tr.texture.get_image().load_png_from_buffer()


func _load_play_data(data: Dictionary):
	# If "play_data" is not empty, we immediately transition to a new scene and pass the data to that scene.
	if not data['minigame'].is_empty():
		SceneManager.swap_scenes("res://game/game.tscn", data['minigame'])


func _maybe_advance_dialog(delta):
	if self.text_advancement_paused_on_input:
		# This one feels a little better:
		#if Input.is_anything_pressed() or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.is_action_just_released("ui_accept") or self.mouse_just_released:
			self.text_advancement_paused_on_input = false
		else:
			return
	
	self.time_to_next_character -= delta
	
	# Advance the caret, unless we're going past the end.
	var caret: int = self.dialog_out.visible_characters
	var character_just_shown = ''
	var just_finished: bool = false
	if self.time_to_next_character <= 0.0 and caret < self.dialog_out.text.length():
		self.time_to_next_character = self.time_between_characters
		self.dialog_out.visible_characters += 1
		self.type_noise.play()
		if caret+1 < self.dialog_out.text.length():
			character_just_shown = self.dialog_out.text[caret+1]
		
		# If the player is holding down a button or the mouse, advance at full speed.
		#if Input.is_action_pressed("ui_accept"):
		#	self.time_to_next_character = 0.0
		
		# Check if we need to pause because the next character will trigger a swap.
		if character_just_shown == '.':
			self.time_to_next_character *= self.period_pause_time_scale
		if character_just_shown == "\n":
			self.text_advancement_paused_on_input = true
		
		# We are changing speakers:
		# TODO: This triggers at the same time as the delay.
		# TODO: This does not trigger expression changes if they happen at character zero, so we have to hack it and add a space or a newline.
		if self.character_index_to_actor_switch.has(caret):
			var new_visible_character: String = self.character_index_to_actor_switch[caret]
			var new_speaker: String = ""
			var new_emotion: String = ""
			if ":" in new_visible_character:
				var arr = new_visible_character.split(":")
				new_speaker = arr[0]
				new_emotion = arr[1]
			else:
				new_speaker = new_visible_character
			self.set_speaker(new_speaker, new_emotion)
		
		if self.dialog_out.visible_ratio >= 1.0:
			just_finished = true
				
	# Finishing the dialog:
	if (just_finished or self.dialog_out.text.length() == 0) and not self.terminal_events_fired:
		self.terminal_events_fired = true
		# Done!
		# We will automatically display options and move forward so that we can 'hack' stuff by making many scenes which automatically connect.
		# If a player wants to pause before prompts, they can add '\n'.
		if not self.prompt.text.is_empty():
			self.dialog_out.visible = false
			self.prompt_and_choices.visible = true
			print("Debug: Showing prompt and choices.")
		elif self.game_data:
			SceneManager.swap_scenes("res://game/game.tscn", self.game_data)
		elif not self.next_scene.is_empty():
			#StoryManager.switch_scene(self.next_scene)
			self.load_dialog(self._story[self.next_scene])
		else:
			# We have no dialog active, no new scene, no prompts, and no minigame.
			# Self destruct.
			self.queue_free()


func set_speaker(name: String, emotion: String = ""):
	# First, darken all non-speakers.
	for c in self.speaker_images.get_children():
		c.self_modulate = self.non_speaking_color
	if name != "" and self.actor_name_to_texture_rect.has(name):
		self.actor_name_to_texture_rect[name].self_modulate = Color.WHITE
		# TODO: It feels wasteful to always be re-setting the emotion.
		self.actor_name_to_texture_rect[name].texture = self.get_character(name, emotion)

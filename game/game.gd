class_name MainGame extends Control

## Emitted when we do one loop of pick, place, pick, place.
signal single_cycle_finished
signal game_over(player_idx: int, row_idx: int, col_idx: int, diagonal_idx: int, creature_trait: int)  # Player IDX == -1 for draw!
signal player_start(player_idx: int, creature_to_place: Creature)

@onready var picker: Picker = %Picker
@onready var placer: Placer = %Placer
@onready var action_display: RichTextLabel = %ActionLabel

@export var creatures_packed: Array[PackedScene]

var unplaced_creatures: PackedInt64Array = []
var board_state: BoardState
var ai_controllers: Array[AIController] = [null, null]
var player_names: PackedStringArray = ["", ""]
var current_player: int = 0
var next_story_scene: String  # If set, switch to this sequence.  Pass {"sequence": this}.

func _ready() -> void:
	if len(self.creatures_packed) == 0:
		self.creatures_packed = [
			#load("res://game/creatures/birb_biggo_cuddly_bogbirb.tscn"),
			#load("res://game/creatures/birb_snek_zoomy_angy_ketsaquatle.tscn"),
			load("res://game/creatures/cat_birb_biggo_eepy_purr.tscn"),
			load("res://game/creatures/cat_birb_biggo_zoomy_chungus.tscn"),
			load("res://game/creatures/cat_birb_smol_eepy_nugget.tscn"),
			load("res://game/creatures/cat_birb_smol_zoomy_aaronspacemuseum.tscn"),
			#load("res://game/creatures/cat_dog_zoomy_leggy_neil.tscn"),
			#load("res://game/creatures/cat_eepy_chonk_chuggz.tscn"),
			load("res://game/creatures/cat_snek_biggo_eepy_floop.tscn"),
			load("res://game/creatures/cat_snek_biggo_zoomy_fleep.tscn"),
			load("res://game/creatures/cat_snek_smol_eepy_fluffo.tscn"),
			load("res://game/creatures/cat_snek_smol_zoomy_teef.tscn"),
			#load("res://game/creatures/cat_zoomy_smol_potat_angy_mphatecraft.tscn"),
			load("res://game/creatures/dog_birb_biggo_eepy_drbobert.tscn"),
			load("res://game/creatures/dog_birb_biggo_zoomy_keith.tscn"),
			load("res://game/creatures/dog_birb_smol_eepy_doof.tscn"),
			load("res://game/creatures/dog_birb_smol_zoomy_princetriphazard.tscn"),
			load("res://game/creatures/dog_snek_biggo_eepy_doop.tscn"),
			load("res://game/creatures/dog_snek_biggo_zoomy_siremixatad.tscn"),
			load("res://game/creatures/dog_snek_smol_eepy_toop.tscn"),
			load("res://game/creatures/dog_snek_smol_zoomy_fleef.tscn"),
		]

func init_scene(data: Variant):
	if data != null:
		if "ai_difficulty_1" in data:
			self.ai_controllers[0] = AIController.new()
			self.ai_controllers[0].max_search_depth = data["ai_difficulty_1"]
		if "ai_difficulty_2" in data:
			self.ai_controllers[1] = AIController.new()
			self.ai_controllers[1].max_search_depth = data["ai_difficulty_2"]
	# It seems like sometimes this signal just doesn't get triggered?
	self.single_cycle_finished.connect(self.run_game_loop)
	self.game_over.connect(self._advance_scene)

func start_scene():
	self.board_state = BoardState.new(4, 4)
	self.placer.initialize_board(4, 4)
	var random_creatures = Math.shuffle(self.creatures_packed)
	var creatures: Array[Creature] = []
	for i in range(16):
		creatures.append(random_creatures[i].instantiate())
	self.picker.initialize_creatures(creatures)
	self.run_game_loop()

## Checks if the game is over, raises the game_lost signal, and returns true. (Or false if not over)
func check_game_finished() -> bool:
	var loss: Variant = self.board_state.check_loss()
	if loss != null:
		self.game_over.emit(self.current_player, loss[0], loss[1], loss[2], loss[3])
		return true
	elif self.picker.get_remaining_creature_count() == 0:
		# player_idx: int, row_idx: int, col_idx: int, diagonal_idx: int, creature_trait: int
		self.game_over.emit(-1, -1, -1, -1, -1)  # Draw!
		return true
	return false

func run_game_loop():
	var creature: Creature
	var placement_x_y: PackedInt64Array
	
	# Pick
	self.action_display.clear()
	self.action_display.append_text("Player %d: Choose a creature to give to Player %d" % [self.current_player+1, ((self.current_player+1)%2)+1])
	self.picker.request_pick()
	if self.ai_controllers[self.current_player] != null:
		var remaining_creatures = self.picker.get_remaining_creatures()
		var creature_idx = await self.ai_controllers[self.current_player].compute_pick(self.current_player, self.board_state, remaining_creatures)
		creature = remaining_creatures[creature_idx]
		self.picker.pick_creature(remaining_creatures[creature_idx])
	else:
		creature = await self.picker.picked
	
	# Switch players:
	self.current_player = (self.current_player+1) % 2
	self.player_start.emit(self.current_player, creature)
	
	# Place
	self.action_display.clear()
	self.action_display.append_text("Player %d: Find a place for %s\n Traits: %s" % [self.current_player+1, creature.display_name, creature.get_trait_bbtext()])
	self.placer.request_place(creature)
	if self.ai_controllers[self.current_player] != null:
		var place_pos = await self.ai_controllers[self.current_player].compute_place(self.current_player, self.board_state, self.picker.get_remaining_creatures(), creature)
		placement_x_y = [place_pos.x, place_pos.y, creature.traits]
		self.placer.place(place_pos.x, place_pos.y)
	else:
		placement_x_y = await self.placer.placed
	self.board_state.set_traits_xy(placement_x_y[0], placement_x_y[1], placement_x_y[2])
	
	# Maybe finish.
	if self.check_game_finished():  # Breaks out of loop.  Use logic on signal instead of calling method here.
		return

	# This also triggers the next round of async pick and place, so don't remove it.
	# We can't just call self.run because we'd hit the stack limit.
	self.single_cycle_finished.emit()

func _advance_scene(player_idx: int, row_idx: int, col_idx: int, diagonal_idx: int, creature_trait: int) -> void:
	var t = get_tree().create_timer(2.0)
	if self.next_story_scene:
		t.timeout.connect(SceneManager.swap_scenes.bind("res://cutscene/cutscene.tscn", {"sequence": self.next_story_scene}))
	else:
		t.timeout.connect(SceneManager.swap_scenes.bind("res://menus/title/title.tscn"))

func _process(delta: float) -> void:
	#self.debug_count = (self.debug_count+1)%1000
	pass

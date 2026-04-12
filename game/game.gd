class_name MainGame extends Control

## Emitted when we do one loop of pick, place, pick, place.
signal single_cycle_finished
signal game_lost(player_idx: int, row_idx: int, col_idx: int)
signal player_start(player_idx)

@onready var picker: Picker = %Picker
@onready var placer: Placer = %Placer

var unplaced_creatures: PackedInt64Array = []
var board_state: BoardState
var ai_controllers: Array[AIController] = [null, null]
var player_names: PackedStringArray = ["", ""]
var current_player: int = 0

func _ready() -> void:
	pass

func init_scene(data: Variant):
	if data == null:
		pass
	# It seems like sometimes this signal just doesn't get triggered, so we should run it in the process method.
	self.single_cycle_finished.connect(self.run_game_loop)

func start_scene():
	self.board_state = BoardState.new(4, 4)
	self.run_game_loop()

func _switch_player():
	self.current_player = (self.current_player+1) % 2
	self.player_start.emit(self.current_player)

## Checks if the game is over, raises the game_lost signal, and returns true. (Or false if not over)
func check_game_finished() -> bool:
	var col: int = self.board_state.check_col_wins()
	var row: int = self.board_state.check_row_wins()
	if col != -1 or row != -1:
		print("Game over: col %d, row %d" % [col, row])
		self.game_lost.emit(self.current_player, row, col)
		return true
	return false

func run_game_loop():
	var creature: Creature
	var placement_x_y: PackedInt64Array
	
	# Pick
	self.picker.request_pick()
	if self.ai_controllers[self.current_player] != null:
		creature = await self.ai_controllers[self.current_player].compute_pick(self.board_state, self.picker.get_remaining_creatures())
	else:
		creature = await self.picker.picked
	print("Got pick")
	self._switch_player()
	
	# Place
	self.placer.request_place(creature)
	if self.ai_controllers[self.current_player] != null:
		var place_pos = await self.ai_controllers[self.current_player].compute_place(self.board_state, self.picker.get_remaining_creatures(), creature)
		placement_x_y = [place_pos.x, place_pos.y, creature.traits]
	else:
		placement_x_y = await self.placer.placed
	print("Got place")
	self.board_state.set_traits_xy(placement_x_y[0], placement_x_y[1], placement_x_y[2])
	
	# Maybe finish.
	if self.check_game_finished():  # Breaks out of loop.  Use logic on signal instead of calling method here.
		return

	# This also triggers the next round of async pick and place, so don't remove it.
	# We can't just call self.run because we'd hit the stack limit.
	self.single_cycle_finished.emit()

func _process(delta: float) -> void:
	#self.debug_count = (self.debug_count+1)%1000
	pass

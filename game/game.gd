extends Control

## Emitted when we do one loop of pick, place, pick, place.
signal single_cycle_finished
signal game_lost(player_idx: int, row_idx: int, col_idx: int)

@onready var picker: Picker = %Picker
@onready var placer: Placer = %Placer

var debug_count: int = 0
var board_state: BoardState
var player_names: PackedStringArray = []
var current_player: int = 0

func _ready() -> void:
	pass

func init_scene(data: Variant):
	if data == null:
		pass
	self.single_cycle_finished.connect(self.run_game_loop)

func start_scene():
	self.board_state = BoardState.new(4, 4)
	self.run_game_loop()

func switch_player():
	self.current_player = (self.current_player+1) % 2

func game_finished() -> bool:
	var col: int = self.board_state.check_col_wins()
	var row: int = self.board_state.check_row_wins()
	if col != -1 or row != -1:
		self.game_lost.emit(self.current_player, row, col)
		return true
	return false

func run_game_loop():
	self.picker.request_pick()
	var creature = await self.picker.picked
	self.switch_player()

	self.placer.request_place(creature)
	var placement_x_y = await self.placer.placed

	self.board_state.set_traits_xy(placement_x_y[0], placement_x_y[1], placement_x_y[2])
	if self.game_finished():
		return
	self.picker.request_pick()
	creature = await self.picker.picked
	self.switch_player()

	self.placer.request_place(creature)
	placement_x_y = await self.placer.placed
	self.board_state.set_traits_xy(placement_x_y[0], placement_x_y[1], placement_x_y[2])
	if self.game_finished():
		return
	self.single_cycle_finished.emit()

func _process(delta: float) -> void:
	self.debug_count += 1
	if self.debug_count % 100 == 0:
		print(self.debug_count)
	

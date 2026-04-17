class_name BoardState extends Node2D

# We could use a Vec2i, but we don't really need the extra alloc.
var board_width: int
var board_height: int
var board_state: PackedInt64Array = []

func _init(width: int, height: int, from_state: PackedInt64Array = []):
	self.board_width = width
	self.board_height = height
	if from_state.is_empty():
		for i in range(0, width*height):
			self.board_state.append(0)
	else:
		assert(from_state.size() == width*height)
		self.board_state = from_state.duplicate()

func clone() -> BoardState:
	return BoardState.new(self.board_width, self.board_height, self.board_state)

func to_array() -> PackedInt64Array:
	var state: PackedInt64Array = []
	state.append(self.board_width)
	state.append(self.board_height)
	state.append_array(self.board_state)
	return state

func from_array(state: PackedInt64Array):
	self.board_width = state[0]
	self.board_height = state[1]
	self.board_state = state.slice(2)

func set_traits_xy(x: int, y: int, p: int):
	self.board_state[x + y*self.board_width] = p

func get_traits_xy(x: int, y: int) -> int:
	return self.board_state[x + y*self.board_width]

func check_loss():
	"""Returns (row, col, diag, traits) or null if there's no loss."""
	var col = self.check_col_parade()
	var row = self.check_row_parade()
	var diagonals = self.check_diagonals()
	if col != null:
		return [-1, col[0], -1, col[1]]
	elif row != null:
		return [row[0], -1, -1, row[1]]
	elif diagonals != null:
		return [-1, -1, diagonals[0], diagonals[1]]
	return null

func check_row_parade():
	"""Returns null if there's no winner, otherwise returns [row, traits]."""
	for y in range(0, self.board_height):
		var accumulator: int = 0
		# Build up all the bits in the row/col:
		for x in range(0, self.board_width):
			var t: int = self.board_state[x+y*self.board_width]
			accumulator |= t
		# Gradually remove them.  If any doesn't overlap, it means it was removed already.
		for x in range(0, self.board_width):
			var t: int = self.board_state[x+y*self.board_width]
			accumulator &= t
		if bool(accumulator):
			return [y, accumulator]
	return null

func check_col_parade():
	"""Returns null if there's no winner, otherwise returns [col, traits]."""
	for x in range(0, self.board_width):
		var accumulator: int = 0
		for y in range(0, self.board_height):
			var t: int = self.board_state[x+y*self.board_width]
			accumulator |= t
		for y in range(0, self.board_height):
			var t: int = self.board_state[x+y*self.board_width]
			accumulator &= t
		if bool(accumulator):
			return [x, accumulator]
	return null

func check_diagonals():
	"""Returns null if there's no winner, otherwise returns [1 (for top left to bottom right) or 2 (for top right to bottom left), traits]."""
	if self.board_height != self.board_width:
		return false
	var accumulator_tlbr: int = 0
	var accumulator_bltr: int = 0
	for i in range(0, self.board_width):
		var t: int = self.board_state[i+i*self.board_width]
		accumulator_tlbr |= t
		t = self.board_state[i+(self.board_width-1-i)*self.board_width]
		accumulator_bltr |= t
	for i in range(0, self.board_width):
		var t: int = self.board_state[i+i*self.board_width]
		accumulator_tlbr &= t
		t = self.board_state[i+(self.board_width-1-i)*self.board_width]
		accumulator_bltr &= t
	if bool(accumulator_bltr):
		return [2, accumulator_bltr]
	elif bool(accumulator_tlbr):
		return [1, accumulator_bltr]
	return null  # Rather than return [0,0], avoid an allocation.

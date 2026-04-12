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
		for i in range(0, width*width):
			self.board_state.append(from_state[i])

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
	# Debugs:
	"""
	var binout = ""
	var temp = p
	for _idx in range(0, 32):
		if bool(temp & 0x1):
			binout = "1" + binout
		else:
			binout = "0" + binout
		temp >>= 1
	print("%4d, %4d, %32s" % [x, y, binout])
	"""
	self.board_state[x + y*self.board_width] = p

func get_traits_xy(x: int, y: int) -> int:
	return self.board_state[x + y*self.board_width]

func check_row_wins() -> int:
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
			return y
	return -1

func check_col_wins() -> int:
	for x in range(0, self.board_width):
		var accumulator: int = 0
		for y in range(0, self.board_height):
			var t: int = self.board_state[x+y*self.board_width]
			if bool(t & accumulator):
				return x
			accumulator |= t
		for y in range(0, self.board_height):
			var t: int = self.board_state[x+y*self.board_width]
			accumulator &= t
		if bool(accumulator):
			return x
	return -1

func check_diagonal_tldr() -> bool:
	if self.board_height != self.board_width:
		return false
	var accumulator: int = 0
	for i in range(0, self.board_width):
		var t: int = self.board_state[i+i*self.board_width]
		if bool(t & accumulator):
			return true
	return false

func check_diagonal_bltr() -> bool:
	if self.board_height != self.board_width:
		return false
	var accumulator: int = 0
	for i in range(0, self.board_width):
		var t: int = self.board_state[i+(self.board_width-1-i)*self.board_width]
		if bool(accumulator & t):
			return true
		accumulator |= t
	return false

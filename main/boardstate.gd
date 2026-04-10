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
	self.board_state[x + y*self.board_width] = p

func get_traits_xy(x: int, y: int) -> int:
	return self.board_state[x + y*self.board_width]

func _count_bits(v:int) -> int:
	var count = 0
	while v > 0:
		if bool(v&0x1):
			count += 1
		v = v >> 1
	return count

func check_row_wins() -> int:
	for y in range(0, self.board_height):
		var accumulator: int = 0
		var occupied_spaces: int = 0
		for x in range(0, self.board_width):
			var t: int = self.board_state[x+y*self.board_width]
			if t:
				occupied_spaces += 1
			accumulator |= t
		if self._count_bits(accumulator) < occupied_spaces:
			return y
	return -1

func check_col_wins() -> int:
	for x in range(0, self.board_width):
		var accumulator: int = 0
		var occupied_spaces: int = 0
		for y in range(0, self.board_height):
			var t: int = self.board_state[x+y*self.board_width]
			if t:
				occupied_spaces += 1
			accumulator |= t
		if self._count_bits(accumulator) < occupied_spaces:
			return x
	return -1

func check_diagonal_tldr() -> bool:
	if self.board_height != self.board_width:
		return false
	var accumulator: int = 0
	var occupied_spaces: int = 0
	for i in range(0, self.board_width):
		var t: int = self.board_state[i+i*self.board_width]
		if t:
			occupied_spaces += 1
		accumulator |= t
	if self._count_bits(accumulator) < occupied_spaces:
		return true
	return false

func check_diagonal_bltr() -> bool:
	if self.board_height != self.board_width:
		return false
	var accumulator: int = 0
	var occupied_spaces: int = 0
	for i in range(0, self.board_width):
		var t: int = self.board_state[i+(self.board_width-1-i)*self.board_width]
		if t:
			occupied_spaces += 1
		accumulator |= t
	if self._count_bits(accumulator) < occupied_spaces:
		return true
	return false

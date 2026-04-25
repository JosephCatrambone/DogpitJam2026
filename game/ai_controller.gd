class_name AIController extends Node

var max_search_depth: int = 8

## Given the board state, current player, and available creatures, picks the creature to give to the opponent.
## Returns the INDEX of the creature in available.  Does not mutate board_state.
func compute_pick(current: int, board_state: BoardState, available: Array[Creature]) -> int:
	# This method should not mutate the board state.  Make a clone and manipulate internally.
	var b = board_state.clone()
	var traits = []
	for t in available:
		traits.append(t.traits)
	var best_index_score = self._compute_pick(current, b, traits, self.max_search_depth)
	return best_index_score[0]

## Given the board state, current player, available creatures, and creature, picks the best place to put this creature as X,Y.
## Does not mutate board state.
func compute_place(current: int, board_state: BoardState, available: Array[Creature], to_place: Creature) -> Vector2i:
	var b = board_state.clone()
	var traits = []
	for t in available:
		traits.append(t.traits)
	var best_x_y_score = self._compute_place(current, to_place.traits, b, traits, self.max_search_depth)
	return Vector2i(best_x_y_score[0], best_x_y_score[1])

func _compute_pick(current_player: int, board_state: BoardState, available: PackedInt64Array, max_depth: int):
	# Returns the index of the creature in available and the score, given the current_player is picking.  +1 means a win for current. -1 means a loss for current.
	var best_index = 0
	var best_score = 1.0  # A win for us.
	for i in range(len(available)):
		var t = available[i]
		available.remove_at(i)
		var x_y_score = self._compute_place((current_player+1)%2, t, board_state, available, max_depth-1)
		available.insert(i, t)  # Return it to the position.
		if x_y_score[2] < best_score:  # Our opponent is playing, so minimize. If they lose, that's the best one.
			best_index = i
			best_score = x_y_score[2]
			if best_score == -1.0:
				return [i, 1.0]
	return [best_index, -best_score]

func _compute_place(current_player: int, trait_to_place: int, board_state: BoardState, available: PackedInt64Array, max_depth: int):
	# Returns the x,y,score of the best place to put the provided 'to_place'. +1 score means a win for current_player. -1 means loss.
	# Try placing in each open square.
	var open_positions: Array[Vector2i] = []
	var not_losing_positions: Array[Vector2i] = []
	for y in range(board_state.board_height):
		for x in range(board_state.board_width):
			if board_state.get_traits_xy(x, y) == 0:
				open_positions.append(Vector2i(x,y))
				board_state.set_traits_xy(x, y, trait_to_place)
				if board_state.check_loss() == null:
					not_losing_positions.append(Vector2i(x,y))
				board_state.set_traits_xy(x, y, 0)
	if len(open_positions) == 0:
		return [0, 0, 0.0]  # Draw!
	if len(not_losing_positions) == 0:
		var p = Math.choice(open_positions)
		return [p.x, p.y, -1.0]
	if len(not_losing_positions) == 1:
		return [not_losing_positions[0].x, not_losing_positions[0].y, 1.0]
	
	# If we're out of steps we can take, apply a heuristic.
	if max_depth <= 0:
		# Compute the number of losing positions.
		# TODO: To minimize wins for the opponent and maximize for self, picking not_losing mod 2?
		var score = len(not_losing_positions) / float(board_state.board_width*board_state.board_height)
		var p = Math.choice(not_losing_positions)
		return [p.x, p.y, score]
	
	# Recurse and do some heavy computation:
	# For each state, try placing the current item, then look one layer deeper.
	var best_score: float = -1.0
	var best_pos: Vector2i = open_positions[0]
	for p in not_losing_positions:
		# Place the item and get the best pick.
		board_state.set_traits_xy(p.x, p.y, trait_to_place)
		var pick_and_score = self._compute_pick(current_player, board_state, available, max_depth-1)
		board_state.set_traits_xy(p.x, p.y, 0)  # CLEAR THE PLACEMENT!
		if pick_and_score[1] > best_score:
			best_score = pick_and_score[1]
			best_pos = p
	return [best_pos.x, best_pos.y, best_score]

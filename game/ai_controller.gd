class_name AIController extends Node

## Given the board state and available creatures, picks the creature to give to the opponent.
func compute_pick(board_state: BoardState, available: Array[Creature]) -> Creature:
	"""This method should not mutate the board state.  Make a clone and manipulate internally."""
	return null

## Given the board state, available creatures, and creature, picks the best place to put this creature as X,Y.
func compute_place(board_state: BoardState, available: Array[Creature], to_place: Creature) -> Vector2i:
	return Vector2i()

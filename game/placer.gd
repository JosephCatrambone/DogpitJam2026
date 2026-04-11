class_name Placer extends Node2D

var creature_to_place: Creature
@onready var btn: Button = $Control/Button

func _ready() -> void:
	self.btn.pressed.connect(self._debug_place)

func _debug_place():
	self.btn.disabled = true
	self.placed.emit(0, 0, self.creature_to_place.traits)
	self.creature_to_place = null

# We need to track empty squares.
func set_board_size(width: int, height: int):
	pass

## Raised when the placement is finished.
signal placed(x: int, y: int, traits: int)

## Call with a creature to place and this will begin the process, emitting 'placed' when finished.
func request_place(creature: Creature):
	self.creature_to_place = creature
	self.btn.disabled = false

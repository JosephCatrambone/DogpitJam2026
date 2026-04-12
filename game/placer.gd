class_name Placer extends Node2D

## Call with a creature to place and this will begin the process, emitting 'placed' when finished.
func request_place(creature: Creature):
	self.creature_to_place = creature
	self._enable_buttons()

## Raised when the placement is finished.
signal placed(x: int, y: int, traits: int)


#
# Internals:
#

var width: int
var height: int
var creature_to_place: Creature
var creatures: Array = []
var buttons: Array[Button] = []
@onready var creature_layer: Node2D = $CreatureLayer
@onready var control_panel: Control = $Control

func _ready() -> void:
	self._initialize_board(4, 4)
	self._disable_buttons()

## Initialize the board.
func _initialize_board(width: int, height: int):
	self.creatures = []
	for y in range(0, height):
		for x in range(0, width):
			self.creatures.append(null)
			var b: Button = self.control_panel.get_node("PlaceButton" + str((x+y*width)+1))
			b.pressed.connect(self._handle_place.bind(b, x, y))
			self.buttons.append(b)
	self.width = width
	self.height = height

# Go over all the buttons and enable the ones where we can place things.
func _enable_buttons():
	for y in range(0, self.height):
		for x in range(0, self.width):
			var i = x+y*self.width
			if self.creatures[i] != null:  # Spot filled!
				self.buttons[i].disabled = true
				#self.buttons[i].visible = false  # This might throw off layout...
				self.buttons[i].text = ""
			else:  # Spot open
				self.buttons[i].disabled = false
				#self.buttons[i].visible = true

func _disable_buttons():
	for i in range(0, self.width*self.height):
		self.buttons[i].disabled = true

func _handle_place(btn: Button, x: int, y: int):
	# IF the given XY position is unoccupied, mark it as filled, place the creature there, and emit a signal.
	
	# In theory, since we don't enable buttons when they're filled, we shouldn't need to check this.
	assert(self.creatures[x+y*self.width] == null)
	#btn.disabled = true  # This will get disabled after the frame anyway.
	btn.text = ""
	self.creatures[x+y*width] = self.creature_to_place
	self.creature_layer.add_child(self.creature_to_place)
	# TODO: This placement thing is probably wrong:
	self.creature_to_place.global_position = btn.get_screen_position()  # This probably doesn't take scaling into effect.
	print("Emit placed!")
	self.placed.emit(x, y, self.creature_to_place.traits)
	self.creature_to_place = null
	self._disable_buttons()

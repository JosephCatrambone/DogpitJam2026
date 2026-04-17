class_name Placer extends Control

## Call with a creature to place and this will begin the process, emitting 'placed' when finished.
func request_place(creature: Creature):
	self.creature_to_place = creature
	self._enable_buttons()

## Raised when the placement is finished.
signal placed(x: int, y: int, traits: int)

#
# Interaction handles for AI picking.
#

func place(x: int, y: int):
	self._handle_place(self.buttons[x+y*self.width], x, y)

#
# Internals:
#

@export var button_theme: Theme
var width: int
var height: int
var creature_to_place: Creature
var creatures: Array = []
var creature_display_areas: Array[Control] = []  # The creature_display is a grid, but this holds refs to the center containers where we want to add the images.
var buttons: Array[Button] = []
@onready var control_panel: GridContainer = %ButtonPanel
@onready var creature_display: GridContainer = %CreatureIcons

func _ready() -> void:
	pass

## Initialize the board.
func initialize_board(width: int, height: int):
	self.control_panel.columns = width
	self.creature_display.columns = width
	self.creatures = []
	for y in range(0, height):
		for x in range(0, width):
			self.creatures.append(null)
			# Set up the button:
			var b: Button = Button.new()
			b.theme = self.button_theme
			b.text = "Open"
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.size_flags_vertical = Control.SIZE_EXPAND_FILL
			b.pressed.connect(self._handle_place.bind(b, x, y))
			self.buttons.append(b)
			self.control_panel.add_child(b)
			b.disabled = true  # Buttons start disabled.
			# Set up the display area:
			var a: Control = Control.new()
			a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			a.size_flags_vertical = Control.SIZE_EXPAND_FILL
			self.creature_display.add_child(a)
			self.creature_display_areas.append(a)
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
	var idx = x+y*self.width
	# In theory, since we don't enable buttons when they're filled, we shouldn't need to check this.
	assert(self.creatures[idx] == null)
	#btn.disabled = true  # This will get disabled after the frame anyway.
	btn.text = ""
	self.creatures[idx] = self.creature_to_place
	self.creature_display_areas[idx].add_child(self.creature_to_place)
	self.placed.emit(x, y, self.creature_to_place.traits)
	self.creature_to_place = null
	self._disable_buttons()

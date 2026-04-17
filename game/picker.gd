class_name Picker extends Control

signal picked(creature: Creature)

func initialize_creatures(creatures: Array[Creature]):
	for c in creatures:
		self.add_creature(c)

func request_pick():
	picking_active = true
	for b in self.button_area.get_children():
		b.disabled = false

func get_remaining_creatures() -> Array[Creature]:
	var res: Array[Creature] = []
	for k in self.creature_to_button.keys():
		res.append(k)
	return res

func get_remaining_creature_count() -> int:
	return len(self.creature_to_button)

#
# Exposed for AI:
#

## Clears the button and removes the child, as though the provided creature 'c' was picked.
## Does not emit any signals or return any values. Exposed so that we can circumvent human inputs.
func pick_creature(c: Creature):
	var b = self.creature_to_button[c]
	self.creature_to_button.erase(c)
	self.button_to_creature.erase(b)
	self.button_area.remove_child(b)
	self.picking_active = false
	for other_button in self.button_area.get_children():
		other_button.disabled = true
	b.queue_free()

#
# Internals:
#

var picker_button_theme = preload("res://gfx_shared/picker_button.tres")
var picking_active: bool = false
@onready var button_area: Container = %ButtonContainer
var creature_to_button: Dictionary = {}
var button_to_creature: Dictionary = {}

func _ready() -> void:
	pass

func add_creature(c: Creature):
	var b: Button = Button.new()
	b.theme = self.picker_button_theme
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.text = ""
	for t in c.get_trait_names():
		b.text += "[" + t + "] "
	b.text += c.display_name.capitalize()
	self.creature_to_button[c] = b
	self.button_to_creature[b] = c
	b.pressed.connect(self._finish_pick.bind(c))
	self.button_area.add_child(b)

func _finish_pick(c: Creature):
	self.pick_creature(c)
	print("Emitting pick!")
	self.picked.emit(c)

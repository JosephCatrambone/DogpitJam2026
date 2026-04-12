class_name Picker extends Control

signal picked(creature: Creature)

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

func pick_creature(c: Creature):
	self._finish_pick(c)

#
# Internals:
#

var picker_button_theme = preload("res://gfx_shared/picker_button.tres")
var picking_active: bool = false
@onready var button_area: Container = %ButtonContainer
var creature_to_button: Dictionary = {}
var button_to_creature: Dictionary = {}

func _ready() -> void:
	self._init_creatures(16)

func _init_creatures(count: int):
	for i in range(count):
		var c: Creature = Creature.new()
		c.display_name = Math.choice(["Sp", "D", "Fl", "Dr. Boop"]) + Math.choice(["oof", "oop", "ee", "u"]) + Math.choice(["", "", "ie", "sy", " The Great", " The 3rd", "est Maximus", " Jr.", ": Destroyer of Worlds"])
		# Ensure at least one trait is set.  Some of these are mutually exclusive, but this is all placeholder.
		c.set_trait(Math.choice([
			Creature.CreatureTrait.CAT, Creature.CreatureTrait.DOG, Creature.CreatureTrait.BIRB, Creature.CreatureTrait.SNEK, 
		]), true)
		for _i in range(0, Math.range_inclusive(1, 3)):
			var t = Math.choice(Creature.CreatureTrait.keys())
			c.set_trait(Creature.CreatureTrait[t], true)
		self._add_creatue(c)

func _add_creatue(c: Creature):
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
	var b = self.creature_to_button[c]
	self.creature_to_button.erase(c)
	self.button_to_creature.erase(b)
	self.button_area.remove_child(b)
	self.picked.emit(c)
	self.picking_active = false
	for other_button in self.button_area.get_children():
		other_button.disabled = true
	b.queue_free()

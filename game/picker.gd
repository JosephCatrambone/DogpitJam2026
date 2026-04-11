class_name Picker extends Control

signal picked(creature: Creature)

@onready var btn: Button = $VBoxContainer/Button
var picking_active: bool = false

func _ready() -> void:
	self.btn.pressed.connect(self._debug_emit)

func _debug_emit():
	var p: Creature = Creature.new()
	p.set_trait(Creature.SpeciesTrait.SMOL, true)
	p.set_trait(Creature.SpeciesTrait.DOG, true)
	self.picked.emit(p)
	self.picking_active = false
	btn.disabled = true

func request_pick():
	picking_active = true
	btn.disabled = false

func get_remaining_creatures() -> Array[Creature]:
	return []

func get_remaining_creature_count() -> int:
	return 0

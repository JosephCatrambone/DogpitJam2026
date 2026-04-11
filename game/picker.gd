class_name Picker extends Control

signal picked(creature: Piece)

@onready var btn: Button = $VBoxContainer/Button
var picking_active: bool = false

func _ready() -> void:
	self.btn.pressed.connect(self._debug_emit)

func _debug_emit():
	var p: Piece = Piece.new()
	p.set_trait(Piece.SpeciesTrait.SMOL, true)
	p.set_trait(Piece.SpeciesTrait.DOG, true)
	self.picked.emit(p)
	self.picking_active = false
	btn.disabled = true

func request_pick():
	picking_active = true
	btn.disabled = false

func get_remaining_creatures() -> Array[Piece]:
	return []

func get_remaining_creature_count() -> int:
	return 0

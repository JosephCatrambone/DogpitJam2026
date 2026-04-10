class_name Piece extends Node2D

enum Speed { EEPY, ZOOMY }
enum Size { SMOL, CHONK }
enum Species { CAT, DOG, BIRB, SNEK }

var animal_data: int

func new(t: int):
	self.animal_type = t

func _get_flag(idx: int) -> int:
	assert(idx <= 3)
	return (self.animal_type >> idx) & 0x1

func get_speed() -> Speed:
	return self._get_flag(0)

func get_size() -> Size:
	return self._get_flag(1)

func get_species_a() -> Species:
	return self._get_flag(2)

func get_species_b() -> Species:
	return self._get_flag(4)

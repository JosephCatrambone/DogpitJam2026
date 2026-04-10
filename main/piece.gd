class_name Piece extends Node2D

enum SpeciesTrait {
	VOID = 1 << 0,
	CAT = 1 << 1,
	DOG = 1 << 2, 
	BIRB = 1 << 3, 
	SNEK = 1 << 4,
	EEPY = 1 << 5,
	ZOOMY = 1 << 6,
	SMOK = 1 << 7,
	POTAT = 1 << 8,
	LEGGY = 1 << 9,
	CHONK = 1 << 10,
	BIGGO = 1 << 11,
	ANGY = 1 << 12,
	DERPY = 1 << 13,
	CUDDLY = 1 << 14,
}

var traits: int

func set_trait(t: SpeciesTrait, value: bool):
	var setter = int(t)
	if value:
		self.traits = (self.traits | setter)
	else:
		self.traits = (self.traits & ~setter)

func get_trait(t: SpeciesTrait):
	return bool(self.traits & int(t))

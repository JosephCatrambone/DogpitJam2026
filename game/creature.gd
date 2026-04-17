class_name Creature extends Node

enum CreatureTrait {
	#VOID = 1 << 0,
	CAT = 1 << 0,
	DOG = 1 << 1,
	BIRB = 1 << 2,
	SNEK = 1 << 3,
	EEPY = 1 << 4,
	ZOOMY = 1 << 5,
	SMOL = 1 << 6,
	POTAT = 1 << 7,
	LEGGY = 1 << 8,
	CHONK = 1 << 9,
	BIGGO = 1 << 10,
	ANGY = 1 << 11,
	CUDDLY = 1 << 12,
}
const NUM_TRAITS = 13

# Can also do combos like "CatDog:3"
@export_flags("Cat:1", "Dog:2", "Birb:4", "Snek:8", "Eepy:16", "Zoomy:32", "Smol:64", "Potat:128", "Leggy:256", "Chonk:512", "Biggo:1024", "Angy:2048", "Cuddly:4096")
var traits: int

@export var display_name: String
@export var description: String
@export var icon: Image

@onready var display_img: TextureRect = %TextureRect
@onready var name_label: Label = %NameTag
@onready var trait_display: RichTextLabel = %TraitDisplay

func _ready():
	if self.trait_display.text == "":
		self.trait_display.append_text(self.get_trait_bbtext())
	if self.name_label.text == "":
		if self.display_name != "":
			self.name_label.text = self.display_name

func set_trait(t: CreatureTrait, value: bool):
	var setter = int(t)
	if value:
		self.traits = (self.traits | setter)
	else:
		self.traits = (self.traits & ~setter)

## Return true if the creature has the specified trait.  If 'packed_traits' is specified, will return true if the given bit is set in that integer instead, making this something of a staticmethod.
func get_trait(t: CreatureTrait, packed_traits: int = 0) -> bool:
	if packed_traits == 0:
		packed_traits = self.traits
	return bool(packed_traits & int(t))

## Expands the compact integer representation of traits into an array of Enums.
func get_trait_array() -> Array[CreatureTrait]:
	var res = []
	for t in CreatureTrait.keys():
		if self.get_trait(t):
			res.append(t)
	return res

## Expands the compact integer representation of traits into an array of string names.
func get_trait_names() -> PackedStringArray:
	var res: PackedStringArray = []
	var trait_names = CreatureTrait.keys()
	for i in range(len(trait_names)):
		var bit = 1<<i
		if bool(bit & self.traits):
			res.append(trait_names[i])
	return res

func get_trait_bbtext(separator: String = " ") -> String:
	# TODO: Make sure these happen in a sensible order.
	var tags: String = ""
	for t in CreatureTrait.values():
		if self.get_trait(t):
			tags += {
				CreatureTrait.CAT: "CAT",
				CreatureTrait.DOG: "DOGGO",
				CreatureTrait.SNEK: "SNEK",
				CreatureTrait.BIRB: "BIRB",
				CreatureTrait.EEPY: "[fade start=4 length=14]EEPY[/fade]",
				CreatureTrait.ZOOMY: "[shake rate=20.0 level=5 connected=1]ZOOMY[/shake]",
				CreatureTrait.SMOL: "[font_size=8]smol[/font_size]",
				CreatureTrait.POTAT: "POTAT",
				CreatureTrait.LEGGY: "LEGGY",
				CreatureTrait.CHONK: "[b]CHONK[/b]",
				CreatureTrait.BIGGO: "[font_size=18]BIGGO[/font_size]",
				CreatureTrait.ANGY: "[bgcolor=#882222][color=#ffdddd]ANGY[/color][/bgcolor]",
				CreatureTrait.CUDDLY: "CUDDLY",
			}[t]
			tags += separator
	
	return tags

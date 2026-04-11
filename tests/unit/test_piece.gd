extends GutTest

func test_set():
	var p: Creature = Creature.new()
	p.set_trait(Creature.SpeciesTrait.CAT, true)
	assert_true(p.get_trait(Creature.SpeciesTrait.CAT))

func test_multiset():
	var p: Creature = Creature.new()
	p.set_trait(Creature.SpeciesTrait.CAT, true)
	p.set_trait(Creature.SpeciesTrait.DOG, true)
	assert_true(p.get_trait(Creature.SpeciesTrait.CAT))
	assert_true(p.get_trait(Creature.SpeciesTrait.DOG))
	assert_false(p.get_trait(Creature.SpeciesTrait.SNEK))
	p.queue_free()

func test_clear():
	var p: Creature = Creature.new()
	p.set_trait(Creature.SpeciesTrait.CAT, true)
	p.set_trait(Creature.SpeciesTrait.CAT, false)
	assert_false(p.get_trait(Creature.SpeciesTrait.CAT))
	p.queue_free()

func test_name_set():
	var p: Creature = Creature.new()
	p.set_trait(Creature.SpeciesTrait.SNEK, true)
	p.set_trait(Creature.SpeciesTrait.ZOOMY, true)
	var names = p.get_trait_names()
	assert_eq(names, PackedStringArray(["SNEK", "ZOOMY"]))

func test_default():
	var p: Creature = Creature.new()
	assert_false(p.get_trait(Creature.SpeciesTrait.CAT))
	p.queue_free()

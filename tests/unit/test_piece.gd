extends GutTest

func test_set():
	var p: Creature = Creature.new()
	p.set_trait(Creature.CreatureTrait.CAT, true)
	assert_true(p.get_trait(Creature.CreatureTrait.CAT))

func test_multiset():
	var p: Creature = Creature.new()
	p.set_trait(Creature.CreatureTrait.CAT, true)
	p.set_trait(Creature.CreatureTrait.DOG, true)
	assert_true(p.get_trait(Creature.CreatureTrait.CAT))
	assert_true(p.get_trait(Creature.CreatureTrait.DOG))
	assert_false(p.get_trait(Creature.CreatureTrait.SNEK))
	p.queue_free()

func test_clear():
	var p: Creature = Creature.new()
	p.set_trait(Creature.CreatureTrait.CAT, true)
	p.set_trait(Creature.CreatureTrait.CAT, false)
	assert_false(p.get_trait(Creature.CreatureTrait.CAT))
	p.queue_free()

func test_name_set():
	var p: Creature = Creature.new()
	p.set_trait(Creature.CreatureTrait.SNEK, true)
	p.set_trait(Creature.CreatureTrait.ZOOMY, true)
	var names = p.get_trait_names()
	assert_eq(names, PackedStringArray(["SNEK", "ZOOMY"]))

func test_default():
	var p: Creature = Creature.new()
	assert_false(p.get_trait(Creature.CreatureTrait.CAT))
	p.queue_free()

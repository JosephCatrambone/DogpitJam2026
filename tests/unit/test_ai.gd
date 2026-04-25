extends GutTest

func test_scoring_function():
	var b := BoardState.new(3, 3)
	var ai = AIController.new()
	var c = Creature.new()
	c.traits = 0x1
	b.set_traits_xy(0, 0, 0x1)
	b.set_traits_xy(1, 0, 0x1)
	b.set_traits_xy(1, 1, 0x1)
	
	#ai.compute_place(0, b, [c], c)
	assert_eq(ai._compute_place(0, 0x1, b, [0x1, 0x1], 3), [0, 1, 1.0])
	
	b.set_traits_xy(0, 1, 0x1)
	assert_eq(ai._compute_place(0, 0x1, b, [], 3)[2], -1)

func test_ai_gives_right_item():
	# The AI should hand over 0x1 because that makes me lose.
	var b := BoardState.new(2, 2)
	var ai = AIController.new()
	var c = Creature.new()
	c.traits = 0x1
	var d = Creature.new()
	d.traits = 0x2
	var creatures: Array[Creature] = [c, d]
	
	b.set_traits_xy(0, 0, 0x1)
	assert_eq(ai.compute_pick(0, b, creatures), 0)
	
	# Same as above, but we should give 'd' instead of 'c' now:
	b.set_traits_xy(0, 0, 0x2)
	assert_eq(ai.compute_pick(0, b, creatures), 1)
	b.queue_free()

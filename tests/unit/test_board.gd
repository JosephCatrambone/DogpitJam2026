extends GutTest

func test_no_wins_when_empty():
	var b: BoardState = BoardState.new(3, 3)
	assert_eq(b.check_row_wins(), -1)
	assert_eq(b.check_col_wins(), -1)
	assert_eq(b.check_diagonal_tldr(), false)
	assert_eq(b.check_diagonal_bltr(), false)
	b.queue_free()

func test_basic_row_win():
	var b: BoardState = BoardState.new(5, 5)
	var cat: Creature = Creature.new()
	cat.set_trait(Creature.SpeciesTrait.CAT, true)
	b.set_traits_xy(0, 1, cat.traits)
	b.set_traits_xy(1, 1, cat.traits)
	assert_eq(b.check_row_wins(), 1)
	assert_eq(b.check_col_wins(), -1)
	assert_eq(b.check_diagonal_tldr(), false)
	assert_eq(b.check_diagonal_bltr(), false)
	cat.queue_free()
	b.queue_free()

func test_basic_col_win():
	var b: BoardState = BoardState.new(5, 5)
	var cat: Creature = Creature.new()
	cat.set_trait(Creature.SpeciesTrait.CAT, true)
	b.set_traits_xy(2, 0, cat.traits)
	b.set_traits_xy(2, 3, cat.traits)
	assert_eq(b.check_row_wins(), -1)
	assert_eq(b.check_col_wins(), 2)
	assert_eq(b.check_diagonal_tldr(), false)
	assert_eq(b.check_diagonal_bltr(), false)
	cat.queue_free()
	b.queue_free()

func test_serde():
	var w = Math.range_inclusive(2,10)
	var h = Math.range_inclusive(2,10)
	var b1: BoardState = BoardState.new(w, h)
	var b2: BoardState = BoardState.new(w, h)
	for y in range(0, h):
		for x in range(0, w):
			var v = Math.rint()%255
			b1.set_traits_xy(x, y, v)
			b2.set_traits_xy(x, y, v)
	var b_ser = b1.to_array()
	var b_recreated := BoardState.new(0, 0)
	b_recreated.from_array(b_ser)
	assert_eq(b_recreated.board_width, b2.board_width)
	assert_eq(b_recreated.board_height, b2.board_height)
	assert_eq(b_recreated.board_state, b2.board_state)
	b1.queue_free()
	b2.queue_free()
	b_recreated.queue_free()
	

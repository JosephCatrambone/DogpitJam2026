extends GutTest

func test_no_losses_when_empty():
	var b: BoardState = BoardState.new(3, 3)
	assert_eq(b.check_row_parade(), null)
	assert_eq(b.check_col_parade(), null)
	assert_eq(b.check_diagonals(), null)
	b.queue_free()

func test_no_losses():
	var b := BoardState.new(4, 4)
	for y in range(0, 4):
		for x in range(0, 4):
			var i = (x+y*4)
			b.set_traits_xy(x, y, 1<<i)
	assert_eq(b.check_row_parade(), null)
	assert_eq(b.check_col_parade(), null)
	b.queue_free()

func test_no_gameover():
	var b := BoardState.new(0, 0)
	b.from_array([4, 4,
		16396, 392, 0, 12804, 
		0, 0, 4100, 0, 
		0, 16648, 0, 0, 
		0, 0, 0, 0
	])
	assert_eq(b.check_row_parade(), null)
	assert_eq(b.check_col_parade(), null)
	b.queue_free()

func test_basic_row_lose():
	var b: BoardState = BoardState.new(5, 5)
	var cat: Creature = Creature.new()
	cat.set_trait(Creature.CreatureTrait.CAT, true)
	assert_eq(b.check_row_parade(), null)
	b.set_traits_xy(0, 1, cat.traits)
	assert_eq(b.check_row_parade(), null)
	b.set_traits_xy(1, 1, cat.traits)
	assert_eq(b.check_row_parade(), null)
	b.set_traits_xy(2, 1, cat.traits)
	assert_eq(b.check_row_parade(), null)
	b.set_traits_xy(3, 1, cat.traits)
	assert_eq(b.check_row_parade(), null)
	b.set_traits_xy(4, 1, cat.traits)
	assert_eq(b.check_row_parade(), [1, Creature.CreatureTrait.CAT])
	assert_eq(b.check_col_parade(), null)
	assert_eq(b.check_diagonals(), null)
	cat.queue_free()
	b.queue_free()

func test_basic_col_lose():
	var b: BoardState = BoardState.new(5, 5)
	var cat: Creature = Creature.new()
	cat.set_trait(Creature.CreatureTrait.CAT, true)
	b.set_traits_xy(2, 0, cat.traits)
	b.set_traits_xy(2, 1, cat.traits)
	b.set_traits_xy(2, 2, cat.traits)
	b.set_traits_xy(2, 3, cat.traits)
	assert_eq(b.check_col_parade(), null)
	b.set_traits_xy(2, 4, cat.traits)
	assert_eq(b.check_row_parade(), null)
	assert_eq(b.check_col_parade(), [2, Creature.CreatureTrait.CAT])
	assert_eq(b.check_diagonals(), null)
	cat.queue_free()
	b.queue_free()

func check_win():
	var board_arr = [4, 4, 
		16396, 5, 16452, 1052,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	]
	var b: BoardState = BoardState.new(0, 0)
	b.from_array(board_arr)
	assert_eq(b.check_row_parade(), [0, 2])

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
	

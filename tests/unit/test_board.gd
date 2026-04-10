extends GutTest

func test_no_wins_when_empty():
	var b: BoardState = BoardState.new(3)
	assert_eq(b.check_row_wins(), -1)
	assert_eq(b.check_col_wins(), -1)
	assert_eq(b.check_diagonal_tldr(), false)
	assert_eq(b.check_diagonal_bltr(), false)

func test_basic_row_win():
	var b: BoardState = BoardState.new(5)
	var cat: Piece = Piece.new()
	cat.set_trait(Piece.SpeciesTrait.CAT, true)
	b.set_traits_xy(0, 1, cat.traits)
	b.set_traits_xy(1, 1, cat.traits)
	assert_eq(b.check_row_wins(), 1)
	assert_eq(b.check_col_wins(), -1)
	assert_eq(b.check_diagonal_tldr(), false)
	assert_eq(b.check_diagonal_bltr(), false)

func test_basic_col_win():
	var b: BoardState = BoardState.new(5)
	var cat: Piece = Piece.new()
	cat.set_trait(Piece.SpeciesTrait.CAT, true)
	b.set_traits_xy(2, 0, cat.traits)
	b.set_traits_xy(2, 3, cat.traits)
	assert_eq(b.check_row_wins(), -1)
	assert_eq(b.check_col_wins(), 2)
	assert_eq(b.check_diagonal_tldr(), false)
	assert_eq(b.check_diagonal_bltr(), false)

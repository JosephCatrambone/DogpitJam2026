extends GutTest

func test_set():
	var p: Piece = Piece.new()
	p.set_trait(Piece.SpeciesTrait.CAT, true)
	assert_true(p.get_trait(Piece.SpeciesTrait.CAT))

func test_multiset():
	var p: Piece = Piece.new()
	p.set_trait(Piece.SpeciesTrait.CAT, true)
	p.set_trait(Piece.SpeciesTrait.DOG, true)
	assert_true(p.get_trait(Piece.SpeciesTrait.CAT))
	assert_true(p.get_trait(Piece.SpeciesTrait.DOG))
	assert_false(p.get_trait(Piece.SpeciesTrait.SNEK))
	p.queue_free()

func test_clear():
	var p: Piece = Piece.new()
	p.set_trait(Piece.SpeciesTrait.CAT, true)
	p.set_trait(Piece.SpeciesTrait.CAT, false)
	assert_false(p.get_trait(Piece.SpeciesTrait.CAT))
	p.queue_free()

func test_default():
	var p: Piece = Piece.new()
	assert_false(p.get_trait(Piece.SpeciesTrait.CAT))
	p.queue_free()

extends GutTest

#func test_softmax():
#	assert_eq(Math.softmax([0.1, 0.2, 0.4]), [0.1, 0.2, 0.6])

func test_random_select():
	assert_ne(Math.weighted_choice_of_values({"foo": 0.0, "bar": 1.0}), "foo")
	assert_ne(Math.weighted_choice_of_values({"foo": 0.0, "bar": 0.1}), "foo")
	assert_eq(Math.weighted_choice_of_values({"foo": 1.0, "bar": 0.0}), "foo")
	assert_eq(Math.weighted_choice_of_values({"foo": 2.1, "bar": 0.0}), "foo")

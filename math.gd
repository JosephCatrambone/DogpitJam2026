extends Node

func normalize_matching_dictionary_keys(prefix: String, dict: Dictionary):
	# An in-place operation that normalizes the given dict keys to a probability distribution.
	# Iterate over the dictionary once to get the max. We do this for numerical stability, though it's not strictly necessary.
	# In: foo: 0.1, bar: 0.5, foob: 0.2
	# Call with prefix=fo
	# Out: fo: 0.33, bar: 0.5, foob: 0.66  # Bar is skipped because it doesn't match prefix 'fo'.
	var max_value = 0.0
	for keyname in dict.keys():
		if keyname.begins_with(prefix):
			max_value = max(max_value, dict[keyname])
	if max_value == 0.0:
		# We found no keys.
		return
	var accumulator = 0.0
	for keyname in dict.keys():
		if keyname.begins_with(prefix):
			accumulator += exp(dict[keyname]-max_value)
	for keyname in dict.keys():
		if keyname.begins_with(prefix):
			dict[keyname] = exp(dict[keyname]-max_value)/accumulator

func softmax(values: PackedFloat32Array) -> PackedFloat32Array:
	var max_value = 0.0
	var results: PackedFloat32Array = []
	for v in values:
		max_value = max(v, max_value)
	var accumulator = 0.0
	for v in values:
		accumulator += exp(v-max_value)
	for v in values:
		results.append(exp(v-max_value)/accumulator)
	return results

func softmultistep_keys(value: float, key_order: PackedStringArray) -> Dictionary:
	# Given a set of keys like 'b0', 'b1', 'b2' and a value x from 0-1, remap the value
	# to the b's such that as we go from 0-1 the keys smoothly increase and decrease. Example:
	#f(0.0) -> {'b0': 1.0, 'b1': 0.0, 'b2': 0.0}
	#f(0.1) -> {'b0': 0.8, 'b1': 0.2, 'b2': 0.0}
	#f(0.2) -> {'b0': 0.6, 'b1': 0.4, 'b2': 0.0}
	#f(0.3) -> {'b0': 0.4, 'b1': 0.6, 'b2': 0.0}
	#f(0.4) -> {'b0': 0.2, 'b1': 0.8, 'b2': 0.0}
	#f(0.5) -> {'b0': 0.0, 'b1': 1.0, 'b2': 0.0}
	#f(0.6) -> {'b0': 0.0, 'b1': 0.8, 'b2': 0.2}
	#f(0.7) -> {'b0': 0.0, 'b1': 0.6, 'b2': 0.4}
	# If you need 0.0 to be 'none', just pass an empty name for the first value of key_order.
	if len(key_order) < 1:
		printerr("Got softmultistep with no keys!")
		return {}
	if len(key_order) < 2:
		printerr("Got softmultistep with only one key! ", key_order)
		return {key_order[0]: value}
	var results = {}
	for k in key_order:
		results[k] = 0.0
	var step_size = 1.0 / (len(key_order)-1)
	# We should be able to multiply out the step size so we don't need a loop.
	var start_key_index = floor(clamp(value, 0, 0.9999999)/step_size)
	var end_key_index = start_key_index+1
	var end_value = remap(value, start_key_index*step_size, end_key_index*step_size, 0.0, 1.0)
	var start_value = 1.0 - end_value
	results[key_order[end_key_index]] = end_value
	results[key_order[start_key_index]] = start_value
	return results

func set_random_seed(value: int):
	seed(value)

func rint() -> int:
	return randi()

func rfloat() -> float:
	return randf()

## Generate a uniform random variable, default between -1 and 1 with a peak at 0.
func uniform(offset: float = 0.0, scale: float = 1.0) -> float:
	# A random uniform betwen -1 and 1.
	return offset + (choice([-1, 1]) * rfloat() * rfloat() * scale)

func range_inclusive(from:int, to: int) -> int:
	return randi_range(from, to)

## Return the value of one element of an array at random.
func choice(options: Array):
	var idx = randi()%len(options)
	return options[idx]

## Given an array of probabilities, return the index of one of them according to the distribution.
func weighted_choice(weights: Array) -> int:
	var sum = 0.0
	for w in weights:
		sum += w
	if sum == 0.0:
		return -1
	var energy = self.rfloat()*sum
	var i = 0
	while i < len(weights) and energy > 0:
		energy -= weights[i]
		i += 1
	return i

## Given a map of key to weights, return a key at random. 
## Example: { "this is 50% likely": 0.5, "this is 25%": 0.25, "this is also 25": 0.25 }
func weighted_choice_of_values(weights: Dictionary):
	# Given a map of key -> weight, return a key at random.
	var sum = 0.0
	for v in weights.values():
		sum += v
	var energy = self.rfloat()*sum
	for k in weights.keys():
		if energy <= weights[k]:
			return k
		energy -= weights[k]
	# This can't happen.
	printerr("Ummm.")

## Generate a new shuffled array with elements from the original.  The original is unmodified.
func shuffle(array: Array, rng_state: int = -1) -> Array:
	if rng_state == -1:
		rng_state = rint()
	# Fisher-Yates shuffle:
	var shuffled_array_indices: PackedInt32Array = []
	for i in range(len(array)):
		shuffled_array_indices.append(i)
	for i in range(1, len(array)):
		var start_pos = i-1
		var new_pos = i + (hash(rng_state) % ((len(array) - 1 - i) + 1))  # What is a man? A miserable pile of edge cases.
		rng_state = hash(rng_state)
		var temp = shuffled_array_indices[start_pos]
		shuffled_array_indices[start_pos] = shuffled_array_indices[new_pos]
		shuffled_array_indices[new_pos] = temp
	var shuffled_array = []
	for i in range(len(array)):
		shuffled_array.append(array[shuffled_array_indices[i]])
	return shuffled_array

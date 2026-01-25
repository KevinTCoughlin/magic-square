class_name PuzzleGenerator
extends RefCounted

## Generates 3x3 magic square puzzles where all rows, columns, and diagonals sum to N.
## Uses configurable seeding for reproducible puzzles.

enum Difficulty { EASY, MEDIUM, HARD }

const DIFFICULTY_HIDDEN_COUNTS: Dictionary[Difficulty, Vector2i] = {
	Difficulty.EASY: Vector2i(2, 3),
	Difficulty.MEDIUM: Vector2i(4, 5),
	Difficulty.HARD: Vector2i(6, 7),
}

var rng: RandomNumberGenerator


func _init(seed_value: int = -1) -> void:
	rng = RandomNumberGenerator.new()
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


## Generate a puzzle with target sum N and specified difficulty.
## Returns dictionary with 'solution', 'visible_mask', 'target_sum', 'difficulty'.
func generate(target_sum: int, difficulty: Difficulty) -> Dictionary[String, Variant]:
	var solution := _generate_magic_square(target_sum)
	var visible_mask := _generate_visibility_mask(difficulty)

	return {
		"solution": solution,
		"visible_mask": visible_mask,
		"target_sum": target_sum,
		"difficulty": difficulty,
	}


## Generate a valid 3x3 magic square with the given target sum.
## Magic constant for 3x3 using numbers 1-9 is 15.
## We scale/shift to achieve different target sums.
func _generate_magic_square(target_sum: int) -> Array[int]:
	# Base magic squares stored as PackedInt32Array (contiguous memory)
	var base_squares: Array[PackedInt32Array] = [
		PackedInt32Array([2, 7, 6, 9, 5, 1, 4, 3, 8]),
		PackedInt32Array([2, 9, 4, 7, 5, 3, 6, 1, 8]),
		PackedInt32Array([4, 9, 2, 3, 5, 7, 8, 1, 6]),
		PackedInt32Array([6, 7, 2, 1, 5, 9, 8, 3, 4]),
		PackedInt32Array([6, 1, 8, 7, 5, 3, 2, 9, 4]),
		PackedInt32Array([8, 1, 6, 3, 5, 7, 4, 9, 2]),
		PackedInt32Array([8, 3, 4, 1, 5, 9, 6, 7, 2]),
		PackedInt32Array([4, 3, 8, 9, 5, 1, 2, 7, 6]),
	]

	# Pick a random base square
	var base: PackedInt32Array = base_squares[rng.randi() % base_squares.size()]

	# Base magic constant is 15. Scale to target.
	# target_sum = 15 + offset * 3, so offset = (target_sum - 15) / 3
	var offset := (target_sum - 15) / 3

	var result: Array[int] = []
	result.resize(9)
	for i in 9:
		result[i] = base[i] + offset

	return result


## Generate visibility mask based on difficulty.
## true = visible (given), false = hidden (player must fill).
func _generate_visibility_mask(difficulty: Difficulty) -> Array[bool]:
	var hidden_range: Vector2i = DIFFICULTY_HIDDEN_COUNTS[difficulty]
	var hidden_count := rng.randi_range(hidden_range.x, hidden_range.y)

	# Start with all visible
	var mask: Array[bool] = []
	for i in 9:
		mask.append(true)

	# Randomly hide cells
	var indices: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8]
	_shuffle_array(indices)

	for i in hidden_count:
		mask[indices[i]] = false

	return mask


## Generate with custom visibility (for advanced configuration).
## hidden_indices: array of cell indices (0-8) to hide.
func generate_custom(target_sum: int, hidden_indices: Array[int]) -> Dictionary[String, Variant]:
	var solution := _generate_magic_square(target_sum)

	var visible_mask: Array[bool] = []
	for i in 9:
		visible_mask.append(not (i in hidden_indices))

	return {
		"solution": solution,
		"visible_mask": visible_mask,
		"target_sum": target_sum,
		"difficulty": Difficulty.MEDIUM,
	}


func _shuffle_array(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp


## Validate that a grid satisfies magic square property.
## Returns untyped Dictionary for property access compatibility (.valid, .rows, etc.)
static func validate_solution(grid: Array[int], target_sum: int) -> Dictionary:
	var results := {
		"valid": true,
		"rows": [true, true, true],
		"cols": [true, true, true],
		"diagonals": [true, true],
	}

	# Check rows
	for row in 3:
		var sum := grid[row * 3] + grid[row * 3 + 1] + grid[row * 3 + 2]
		results.rows[row] = (sum == target_sum)
		if sum != target_sum:
			results.valid = false

	# Check columns
	for col in 3:
		var sum := grid[col] + grid[col + 3] + grid[col + 6]
		results.cols[col] = (sum == target_sum)
		if sum != target_sum:
			results.valid = false

	# Check diagonals
	var diag1 := grid[0] + grid[4] + grid[8]
	var diag2 := grid[2] + grid[4] + grid[6]
	results.diagonals[0] = (diag1 == target_sum)
	results.diagonals[1] = (diag2 == target_sum)
	if diag1 != target_sum or diag2 != target_sum:
		results.valid = false

	return results

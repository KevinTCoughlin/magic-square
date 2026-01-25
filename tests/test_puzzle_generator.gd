extends GutTest

## Unit tests for PuzzleGenerator

const PuzzleGen := preload("res://puzzle_generator.gd")


func test_validate_solution_valid_magic_square() -> void:
	var grid: Array[int] = [2, 7, 6, 9, 5, 1, 4, 3, 8]
	var result: Dictionary = PuzzleGen.validate_solution(grid, 15)

	assert_true(result.valid, "Standard magic square should be valid")
	assert_eq(result.rows, [true, true, true], "All rows should be valid")
	assert_eq(result.cols, [true, true, true], "All columns should be valid")
	assert_eq(result.diagonals, [true, true], "Both diagonals should be valid")


func test_validate_solution_invalid_row() -> void:
	var grid: Array[int] = [1, 7, 6, 9, 5, 1, 4, 3, 8]  # Changed first cell
	var result: Dictionary = PuzzleGen.validate_solution(grid, 15)

	assert_false(result.valid, "Modified grid should be invalid")
	assert_false(result.rows[0], "First row should be invalid")


func test_validate_solution_invalid_column() -> void:
	var grid: Array[int] = [2, 7, 6, 9, 5, 2, 4, 3, 8]  # Changed [5] from 1 to 2
	var result: Dictionary = PuzzleGen.validate_solution(grid, 15)

	assert_false(result.valid, "Modified grid should be invalid")
	assert_false(result.cols[2], "Third column should be invalid")


func test_validate_solution_with_offset() -> void:
	# Magic square with offset: target 21 means offset of 2 (21-15)/3
	var grid: Array[int] = [4, 9, 8, 11, 7, 3, 6, 5, 10]
	var result: Dictionary = PuzzleGen.validate_solution(grid, 21)

	assert_true(result.valid, "Offset magic square should be valid for target 21")


func test_generate_magic_square_sum_15() -> void:
	var gen := PuzzleGen.new(42)
	var puzzle: Dictionary = gen.generate(15, PuzzleGen.Difficulty.MEDIUM)
	var solution: Array = puzzle.solution

	# Check all rows sum to 15
	for row in 3:
		var row_sum: int = solution[row * 3] + solution[row * 3 + 1] + solution[row * 3 + 2]
		assert_eq(row_sum, 15, "Row %d should sum to 15" % row)

	# Check all columns sum to 15
	for col in 3:
		var col_sum: int = solution[col] + solution[col + 3] + solution[col + 6]
		assert_eq(col_sum, 15, "Column %d should sum to 15" % col)

	# Check diagonals
	var diag1: int = solution[0] + solution[4] + solution[8]
	var diag2: int = solution[2] + solution[4] + solution[6]
	assert_eq(diag1, 15, "Main diagonal should sum to 15")
	assert_eq(diag2, 15, "Anti-diagonal should sum to 15")


func test_generate_magic_square_sum_21() -> void:
	var gen := PuzzleGen.new(123)
	var puzzle: Dictionary = gen.generate(21, PuzzleGen.Difficulty.EASY)
	var solution: Array = puzzle.solution

	var result: Dictionary = PuzzleGen.validate_solution(solution, 21)
	assert_true(result.valid, "Generated puzzle with target 21 should be valid")


func test_generate_magic_square_sum_30() -> void:
	var gen := PuzzleGen.new(999)
	var puzzle: Dictionary = gen.generate(30, PuzzleGen.Difficulty.HARD)
	var solution: Array = puzzle.solution

	var result: Dictionary = PuzzleGen.validate_solution(solution, 30)
	assert_true(result.valid, "Generated puzzle with target 30 should be valid")


func test_generate_seeded_reproducibility() -> void:
	var gen1 := PuzzleGen.new(12345)
	var gen2 := PuzzleGen.new(12345)

	var puzzle1: Dictionary = gen1.generate(15, PuzzleGen.Difficulty.MEDIUM)
	var puzzle2: Dictionary = gen2.generate(15, PuzzleGen.Difficulty.MEDIUM)

	assert_eq(puzzle1.solution, puzzle2.solution, "Same seed should produce same solution")
	assert_eq(
		puzzle1.visible_mask, puzzle2.visible_mask, "Same seed should produce same visibility mask"
	)


func test_generate_different_seeds_different_results() -> void:
	var gen1 := PuzzleGen.new(111)
	var gen2 := PuzzleGen.new(222)

	var puzzle1: Dictionary = gen1.generate(15, PuzzleGen.Difficulty.MEDIUM)
	var puzzle2: Dictionary = gen2.generate(15, PuzzleGen.Difficulty.MEDIUM)

	# Very likely to be different (not guaranteed, but statistically improbable to be same)
	var same_solution: bool = puzzle1.solution == puzzle2.solution
	var same_mask: bool = puzzle1.visible_mask == puzzle2.visible_mask
	assert_false(same_solution and same_mask, "Different seeds should produce different puzzles")


func test_visibility_mask_easy_hidden_count() -> void:
	var gen := PuzzleGen.new(42)
	var puzzle: Dictionary = gen.generate(15, PuzzleGen.Difficulty.EASY)
	var mask: Array = puzzle.visible_mask

	var hidden_count: int = 0
	for visible in mask:
		if not visible:
			hidden_count += 1

	assert_true(hidden_count >= 2, "Easy should hide at least 2 cells")
	assert_true(hidden_count <= 3, "Easy should hide at most 3 cells")


func test_visibility_mask_medium_hidden_count() -> void:
	var gen := PuzzleGen.new(42)
	var puzzle: Dictionary = gen.generate(15, PuzzleGen.Difficulty.MEDIUM)
	var mask: Array = puzzle.visible_mask

	var hidden_count: int = 0
	for visible in mask:
		if not visible:
			hidden_count += 1

	assert_true(hidden_count >= 4, "Medium should hide at least 4 cells")
	assert_true(hidden_count <= 5, "Medium should hide at most 5 cells")


func test_visibility_mask_hard_hidden_count() -> void:
	var gen := PuzzleGen.new(42)
	var puzzle: Dictionary = gen.generate(15, PuzzleGen.Difficulty.HARD)
	var mask: Array = puzzle.visible_mask

	var hidden_count: int = 0
	for visible in mask:
		if not visible:
			hidden_count += 1

	assert_true(hidden_count >= 6, "Hard should hide at least 6 cells")
	assert_true(hidden_count <= 7, "Hard should hide at most 7 cells")


func test_generate_custom_specific_hidden() -> void:
	var gen := PuzzleGen.new(42)
	var hidden: Array[int] = [0, 4, 8]  # Hide corners of main diagonal
	var puzzle: Dictionary = gen.generate_custom(15, hidden)
	var mask: Array = puzzle.visible_mask

	assert_false(mask[0], "Cell 0 should be hidden")
	assert_true(mask[1], "Cell 1 should be visible")
	assert_true(mask[2], "Cell 2 should be visible")
	assert_true(mask[3], "Cell 3 should be visible")
	assert_false(mask[4], "Cell 4 should be hidden")
	assert_true(mask[5], "Cell 5 should be visible")
	assert_true(mask[6], "Cell 6 should be visible")
	assert_true(mask[7], "Cell 7 should be visible")
	assert_false(mask[8], "Cell 8 should be hidden")


func test_puzzle_dictionary_structure() -> void:
	var gen := PuzzleGen.new(42)
	var puzzle: Dictionary = gen.generate(18, PuzzleGen.Difficulty.MEDIUM)

	assert_has(puzzle, "solution", "Puzzle should have solution key")
	assert_has(puzzle, "visible_mask", "Puzzle should have visible_mask key")
	assert_has(puzzle, "target_sum", "Puzzle should have target_sum key")
	assert_has(puzzle, "difficulty", "Puzzle should have difficulty key")

	assert_eq(puzzle.solution.size(), 9, "Solution should have 9 cells")
	assert_eq(puzzle.visible_mask.size(), 9, "Mask should have 9 cells")
	assert_eq(puzzle.target_sum, 18, "Target sum should match input")
	assert_eq(puzzle.difficulty, PuzzleGen.Difficulty.MEDIUM, "Difficulty should match input")

class_name PuzzleConfig
extends Resource

## Custom resource for puzzle definitions.
## Enables hand-crafted puzzles and puzzle pack patterns.

@export var name: String = ""
@export var description: String = ""
@export var solution: Array[int] = []
@export var visible_mask: Array[bool] = []
@export var target_sum: int = 15
@export var difficulty: int = 1


## Validate that the resource has valid puzzle data.
func is_valid() -> bool:
	if solution.size() != 9:
		return false
	if visible_mask.size() != 9:
		return false
	if target_sum < 3:
		return false

	# Validate magic square property
	const PuzzleGen := preload("res://puzzle_generator.gd")
	var validation: Dictionary = PuzzleGen.validate_solution(solution, target_sum)
	return validation.valid


## Convert to dictionary format used by game.gd
func to_puzzle_dict() -> Dictionary:
	return {
		"solution": solution.duplicate(),
		"visible_mask": visible_mask.duplicate(),
		"target_sum": target_sum,
		"difficulty": difficulty,
	}


## Create a PuzzleConfig from a generator output dictionary.
static func from_dict(dict: Dictionary, puzzle_name: String = "") -> PuzzleConfig:
	var config := PuzzleConfig.new()
	config.name = puzzle_name
	config.solution = dict.get("solution", [])
	config.visible_mask = dict.get("visible_mask", [])
	config.target_sum = dict.get("target_sum", 15)
	config.difficulty = dict.get("difficulty", 1)
	return config

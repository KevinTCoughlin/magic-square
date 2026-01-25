extends Control

const CellScene := preload("res://cell.tscn")
const PuzzleGen := preload("res://puzzle_generator.gd")

@onready
var grid_container: GridContainer = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/GridContainer
@onready
var target_label: Label = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/TargetLabel
@onready
var status_label: Label = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/StatusLabel
@onready
var difficulty_option: OptionButton = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/HBoxContainer/DifficultyOption
@onready
var seed_input: LineEdit = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/HBoxContainer/SeedInput
@onready
var new_game_btn: Button = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/HBoxContainer/NewGameBtn
@onready
var sum_indicators: Control = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/SumIndicators

var generator: RefCounted
var current_puzzle: Dictionary
var cells: Array = []

# Sum indicator labels
var row_sums: Array[Label] = []
var col_sums: Array[Label] = []
var diag_sums: Array[Label] = []


func _ready() -> void:
	_setup_difficulty_options()
	_setup_sum_indicators()
	new_game_btn.pressed.connect(_on_new_game_pressed)
	_start_new_game()


func _setup_difficulty_options() -> void:
	difficulty_option.clear()
	difficulty_option.add_item("Easy", PuzzleGen.Difficulty.EASY)
	difficulty_option.add_item("Medium", PuzzleGen.Difficulty.MEDIUM)
	difficulty_option.add_item("Hard", PuzzleGen.Difficulty.HARD)
	difficulty_option.select(1)  # Default to Medium


func _setup_sum_indicators() -> void:
	# Create labels for row sums (right side)
	for i in 3:
		var lbl := Label.new()
		lbl.name = "Row%d" % i
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(40, 0)
		row_sums.append(lbl)
		sum_indicators.add_child(lbl)

	# Create labels for column sums (bottom)
	for i in 3:
		var lbl := Label.new()
		lbl.name = "Col%d" % i
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(80, 0)
		col_sums.append(lbl)
		sum_indicators.add_child(lbl)

	# Create labels for diagonal sums
	for i in 2:
		var lbl := Label.new()
		lbl.name = "Diag%d" % i
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(60, 0)
		diag_sums.append(lbl)
		sum_indicators.add_child(lbl)


func _start_new_game() -> void:
	# Parse seed
	var seed_val := -1
	if seed_input.text.length() > 0 and seed_input.text.is_valid_int():
		seed_val = int(seed_input.text)

	generator = PuzzleGen.new(seed_val)

	# Generate target sum (multiple of 3, between 12 and 30 for reasonable numbers)
	var base_targets := [12, 15, 18, 21, 24, 27, 30]
	var target_sum: int = base_targets[generator.rng.randi() % base_targets.size()]

	var difficulty: int = difficulty_option.get_selected_id()
	current_puzzle = generator.generate(target_sum, difficulty)

	_setup_grid()
	_update_display()


func _setup_grid() -> void:
	# Clear existing cells
	for cell in cells:
		cell.queue_free()
	cells.clear()

	# Create new cells
	for i in 9:
		var cell = CellScene.instantiate()
		cell.setup(i, current_puzzle.solution[i], not current_puzzle.visible_mask[i])
		cell.value_changed.connect(_on_cell_value_changed)
		grid_container.add_child(cell)
		cells.append(cell)


func _on_cell_value_changed(_cell_index: int, _new_value: int) -> void:
	_update_display()


func _update_display() -> void:
	var target: int = current_puzzle.target_sum
	target_label.text = "Target Sum: %d" % target

	# Get current grid values
	var current_grid: Array[int] = []
	for cell in cells:
		current_grid.append(cell.get_value())

	# Calculate and display sums
	_update_sum_indicators(current_grid, target)

	# Validate and update status
	var all_filled := true
	for val in current_grid:
		if val == 0:
			all_filled = false
			break

	if all_filled:
		var validation: Dictionary = PuzzleGen.validate_solution(current_grid, target)
		if validation.valid:
			status_label.text = "Correct! Well done!"
			status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.3))
		else:
			status_label.text = "Not quite - check the sums"
			status_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))

		# Highlight cells based on validation
		_highlight_cells(validation)
	else:
		status_label.text = "Fill in all cells"
		status_label.remove_theme_color_override("font_color")
		for cell in cells:
			cell.clear_highlight()


func _update_sum_indicators(grid: Array[int], target: int) -> void:
	# Row sums
	for row in 3:
		var sum := grid[row * 3] + grid[row * 3 + 1] + grid[row * 3 + 2]
		row_sums[row].text = "R%d: %d" % [row + 1, sum]
		_color_sum_label(row_sums[row], sum, target)

	# Column sums
	for col in 3:
		var sum := grid[col] + grid[col + 3] + grid[col + 6]
		col_sums[col].text = "C%d: %d" % [col + 1, sum]
		_color_sum_label(col_sums[col], sum, target)

	# Diagonal sums
	var diag1 := grid[0] + grid[4] + grid[8]
	var diag2 := grid[2] + grid[4] + grid[6]
	diag_sums[0].text = "D\\: %d" % diag1
	diag_sums[1].text = "D/: %d" % diag2
	_color_sum_label(diag_sums[0], diag1, target)
	_color_sum_label(diag_sums[1], diag2, target)


func _color_sum_label(lbl: Label, sum: int, target: int) -> void:
	if sum == target:
		lbl.add_theme_color_override("font_color", Color(0.2, 0.8, 0.3))
	elif sum > target:
		lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	else:
		lbl.remove_theme_color_override("font_color")


func _highlight_cells(_validation: Dictionary) -> void:
	for cell in cells:
		if not cell.is_editable:
			continue
		var is_correct: bool = cell.get_value() == cell.correct_value
		cell.set_highlight(is_correct)


func _on_new_game_pressed() -> void:
	_start_new_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

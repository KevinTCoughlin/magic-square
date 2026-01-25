class_name Cell
extends PanelContainer

signal value_changed(cell_index: int, new_value: int)

@export var cell_index: int = 0

var correct_value: int = 0
var is_editable: bool = true
var current_value: int = 0

var input: LineEdit
var label: Label

var _pending_setup: Dictionary = {}

# Cached styles to avoid allocation on every highlight
static var _style_correct: StyleBoxFlat
static var _style_incorrect: StyleBoxFlat


func _ready() -> void:
	input = $LineEdit
	label = $Label
	input.text_changed.connect(_on_text_changed)
	input.gui_input.connect(_on_input_gui_input)

	# Accessibility: ensure input is focusable
	input.focus_mode = Control.FOCUS_ALL
	focus_mode = Control.FOCUS_ALL

	if not _pending_setup.is_empty():
		_apply_setup(_pending_setup.index, _pending_setup.value, _pending_setup.editable)


func setup(index: int, value: int, editable: bool) -> void:
	cell_index = index
	correct_value = value
	is_editable = editable

	if not is_node_ready():
		_pending_setup = {"index": index, "value": value, "editable": editable}
		return

	_apply_setup(index, value, editable)


func _apply_setup(_index: int, value: int, editable: bool) -> void:
	# Accessibility: set descriptive name based on grid position
	var row: int = cell_index / 3 + 1
	var col: int = cell_index % 3 + 1
	var position_desc := tr("A11Y_CELL_POS") % [row, col]

	if editable:
		label.hide()
		input.show()
		input.text = ""
		input.editable = true
		input.placeholder_text = "?"
		input.tooltip_text = "%s - %s" % [position_desc, tr("A11Y_CELL_ENTER")]
		# Godot 4.5+ screen reader support
		input.set_accessibility_name("%s, %s, %s" % [position_desc, tr("A11Y_CELL_EMPTY"), tr("A11Y_CELL_ENTER")])
		current_value = 0
	else:
		input.hide()
		label.show()
		label.text = str(value)
		label.tooltip_text = "%s - %s" % [position_desc, tr("A11Y_CELL_VALUE") % value]
		# Godot 4.5+ screen reader support
		label.set_accessibility_name("%s, %s" % [position_desc, tr("A11Y_CELL_VALUE") % value])
		current_value = value


func set_highlight(is_correct: bool) -> void:
	if is_editable and current_value > 0:
		if is_correct:
			add_theme_stylebox_override("panel", _get_correct_style())
		else:
			add_theme_stylebox_override("panel", _get_incorrect_style())
	else:
		remove_theme_stylebox_override("panel")


static func _get_correct_style() -> StyleBoxFlat:
	if not _style_correct:
		_style_correct = StyleBoxFlat.new()
		_style_correct.bg_color = Color(0.2, 0.6, 0.3, 0.3)
		_style_correct.set_corner_radius_all(4)
	return _style_correct


static func _get_incorrect_style() -> StyleBoxFlat:
	if not _style_incorrect:
		_style_incorrect = StyleBoxFlat.new()
		_style_incorrect.bg_color = Color(0.7, 0.2, 0.2, 0.3)
		_style_incorrect.set_corner_radius_all(4)
	return _style_incorrect


func clear_highlight() -> void:
	remove_theme_stylebox_override("panel")


func get_value() -> int:
	return current_value


func _on_text_changed(new_text: String) -> void:
	# Filter to digits only, max 2 chars
	var filtered := ""
	for c in new_text:
		if c.is_valid_int() and filtered.length() < 2:
			filtered += c

	if filtered != new_text:
		input.text = filtered
		input.caret_column = filtered.length()

	current_value = int(filtered) if filtered.length() > 0 else 0
	_update_accessibility_name()
	value_changed.emit(cell_index, current_value)


func _update_accessibility_name() -> void:
	var row: int = cell_index / 3 + 1
	var col: int = cell_index % 3 + 1
	var position_desc := tr("A11Y_CELL_POS") % [row, col]
	if current_value > 0:
		input.set_accessibility_name("%s, %s" % [position_desc, tr("A11Y_CELL_VALUE") % current_value])
	else:
		input.set_accessibility_name("%s, %s" % [position_desc, tr("A11Y_CELL_EMPTY")])


func _on_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key := event as InputEventKey
		# Arrow key navigation
		match key.keycode:
			KEY_UP:
				_navigate(-3)
			KEY_DOWN:
				_navigate(3)
			KEY_LEFT:
				if input.caret_column == 0:
					_navigate(-1)
			KEY_RIGHT:
				if input.caret_column >= input.text.length():
					_navigate(1)


func _navigate(offset: int) -> void:
	var target := cell_index + offset
	if target >= 0 and target < 9:
		var parent := get_parent()
		if parent:
			var cells := parent.get_children()
			if target < cells.size() and cells[target] is Cell:
				var target_cell := cells[target] as Cell
				if target_cell.is_editable:
					target_cell.input.grab_focus()



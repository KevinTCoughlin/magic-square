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
	var position_desc := "Row %d, Column %d" % [row, col]

	if editable:
		label.hide()
		input.show()
		input.text = ""
		input.editable = true
		input.placeholder_text = "?"
		input.tooltip_text = "%s - Enter a number" % position_desc
		current_value = 0
	else:
		input.hide()
		label.show()
		label.text = str(value)
		label.tooltip_text = "%s - Value: %d" % [position_desc, value]
		current_value = value


func set_highlight(is_correct: bool) -> void:
	if is_editable and current_value > 0:
		if is_correct:
			add_theme_stylebox_override("panel", _create_style(Color(0.2, 0.6, 0.3, 0.3)))
		else:
			add_theme_stylebox_override("panel", _create_style(Color(0.7, 0.2, 0.2, 0.3)))
	else:
		remove_theme_stylebox_override("panel")


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
	value_changed.emit(cell_index, current_value)


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


func _create_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	return style

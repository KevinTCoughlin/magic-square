extends Control

@onready var label: Label = $CenterContainer/Label

func _ready() -> void:
	print("Hello, World!")
	label.text = "Hello, World!"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

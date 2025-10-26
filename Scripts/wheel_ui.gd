extends CanvasLayer

@onready var world: Node2D = $"../World"

@onready var selection_wheel: Control = $WheelControl/SelectionWheel

func _input(event: InputEvent) -> void:
	
	if $WheelControl.visible:
		get_viewport().set_input_as_handled()
	
	if event.is_action("open_menu"):
		$WheelControl.show()
	elif event.is_action("close_menu"):
		$WheelControl.hide()
	if $WheelControl.visible:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mat_to_change_to = selection_wheel.entries.get(selection_wheel.selected).material_name
				world.current_material = mat_to_change_to
				world.current_mat_label.text = "Current Material: " + mat_to_change_to.capitalize()
				$WheelControl.hide()

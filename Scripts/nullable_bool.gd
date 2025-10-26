extends Resource
class_name NullableBool

enum NBState {NULL, FALSE, TRUE}

var value := NBState.NULL

func set_value(new_value : NBState) -> void:
	value = new_value

func set_value_from_bool(new_value : bool) -> void:
	match new_value:
		true:
			value = NBState.TRUE
		false:
			value = NBState.FALSE

func get_value() -> Variant:
	match value:
		NBState.TRUE:
			return true
		NBState.FALSE:
			return false
		NBState.NULL:
			return null
		_: #I'm not sure this is needed persay, but I'd rather catch any random edge cases.
			print_rich("[pulse freq=0.8 color=#ffffff40 ease=-2.0][color=red]Nullable Bool value is neither null nor false nor true, but a secret fourth thing.[/color][/pulse]")
			return null

extends Node

func is_pause_pressed() -> bool:
	return Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause")

func is_confirm_pressed() -> bool:
	return Input.is_action_just_pressed("ui_accept")

func is_back_pressed() -> bool:
	return Input.is_action_just_pressed("ui_cancel")

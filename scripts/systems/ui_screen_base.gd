extends Control
class_name UIScreenBase

signal request_start_game
signal request_open_settings
signal request_quit
signal request_open_difficulty(mode: String)
signal request_quick_start(mode: String)
signal request_navigate(destination: String)

func _ready() -> void:
    # Derived screens should connect UI elements to these signals.
    pass

extends Node

func _ready() -> void:
    DeviceProfile.detect_profile()
    UIManager.show_main_menu()

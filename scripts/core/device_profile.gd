extends Node
const AppLogger = preload("res://scripts/core/logger.gd")

enum Profile { BIG_SCREEN, HANDHELD }
var current_profile: Profile = Profile.BIG_SCREEN

const HANDHELD_MAX_WIDTH: float = 900.0
var _input := Input

func detect_profile() -> Profile:
    var viewport_size: Vector2i = DisplayServer.window_get_size()
    var has_touch: bool = _input.is_emulating_touch_from_mouse()
    var is_handheld_device: bool = viewport_size.x < HANDHELD_MAX_WIDTH or has_touch
    current_profile = Profile.HANDHELD if is_handheld_device else Profile.BIG_SCREEN
    AppLogger.info("Device profile detected: %s" % ("BIG_SCREEN" if current_profile == Profile.BIG_SCREEN else "HANDHELD"))
    return current_profile

func is_big_screen() -> bool:
    return current_profile == Profile.BIG_SCREEN

func is_handheld() -> bool:
    return current_profile == Profile.HANDHELD

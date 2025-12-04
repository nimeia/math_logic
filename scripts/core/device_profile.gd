extends Node
class_name DeviceProfile

enum Profile { BIG_SCREEN, HANDHELD }
var current_profile: Profile = Profile.BIG_SCREEN

const HANDHELD_MAX_WIDTH: float = 900.0

func detect_profile() -> Profile:
    var viewport_size: Vector2i = DisplayServer.window_get_size()
    var has_touch: bool = Input.get_connected_touchscreen_count() > 0 or Input.is_emulating_touch_from_mouse()
    var is_handheld: bool = viewport_size.x < HANDHELD_MAX_WIDTH or has_touch
    current_profile = is_handheld ? Profile.HANDHELD : Profile.BIG_SCREEN
    Logger.info("Device profile detected: %s" % (current_profile == Profile.BIG_SCREEN ? "BIG_SCREEN" : "HANDHELD"))
    return current_profile

func is_big_screen() -> bool:
    return current_profile == Profile.BIG_SCREEN

func is_handheld() -> bool:
    return current_profile == Profile.HANDHELD

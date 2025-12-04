extends Node

func is_web() -> bool:
	return OS.has_feature("web")

func is_windows() -> bool:
	return OS.get_name() == "Windows"

func is_linux() -> bool:
	return OS.get_name() == "Linux"

func is_macos() -> bool:
	return OS.get_name() == "macOS"

func is_desktop() -> bool:
	return is_windows() or is_linux() or is_macos()

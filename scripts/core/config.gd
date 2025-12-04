extends Node

const CONFIG_DIR: String = "res://config"
var _config_cache: Dictionary = {}

func load_config(file_name: String) -> Dictionary:
    var path: String = "%s/%s" % [CONFIG_DIR, file_name]
    if not FileAccess.file_exists(path):
        push_warning("Config file not found: %s" % path)
        _config_cache[file_name] = {}
        return {}

    var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
    if file == null:
        push_error("Failed to open config file: %s" % path)
        _config_cache[file_name] = {}
        return {}

    var text: String = file.get_as_text()
    var parsed: Variant = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Config file %s is not a dictionary" % path)
        _config_cache[file_name] = {}
        return {}

    var data: Dictionary = parsed
    _config_cache[file_name] = data
    return data

func get_config(file_name: String) -> Dictionary:
    if _config_cache.has(file_name):
        return _config_cache[file_name]
    return load_config(file_name)

func clear_cache() -> void:
    _config_cache.clear()

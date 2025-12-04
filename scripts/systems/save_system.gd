extends Node
class_name SaveSystem

const SAVE_DIR: String = "user://saves"

func save_game(slot: int, state: Dictionary) -> bool:
    var dir_result: Error = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    if dir_result != OK:
        Logger.error("Failed to prepare save directory: %s" % str(dir_result))
        return false

    var path: String = "%s/save_%s.json" % [SAVE_DIR, str(slot)]
    var file := FileAccess.open(path, FileAccess.ModeFlags.WRITE)
    if file == null:
        Logger.error("Failed to open save file: %s" % path)
        return false

    var serialized: String = JSON.stringify(state, "  ")
    file.store_string(serialized)
    return true

func load_game(slot: int) -> Dictionary:
    var path: String = "%s/save_%s.json" % [SAVE_DIR, str(slot)]
    if not FileAccess.file_exists(path):
        Logger.warn("Save file not found: %s" % path)
        return {}

    var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
    if file == null:
        Logger.error("Failed to open save file: %s" % path)
        return {}

    var text: String = file.get_as_text()
    var parsed := JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        Logger.warn("Save data corrupted: %s" % path)
        return {}

    return parsed

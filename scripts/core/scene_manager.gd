extends Node
const AppLogger = preload("res://scripts/core/logger.gd")

var _current_scene: Node = Node.new()

func _ready() -> void:
    if get_tree() == null or get_tree().root == null:
        return
    get_tree().root.call_deferred("add_child", _current_scene)

func change_scene(scene_path: String) -> void:
    if scene_path.is_empty():
        AppLogger.warn("Scene path is empty")
        return
    var packed_scene := ResourceLoader.load(scene_path) as PackedScene
    if packed_scene == null:
        AppLogger.error("Failed to load scene: %s" % scene_path)
        return
    var next_scene := packed_scene.instantiate()
    if _current_scene != null and _current_scene.get_parent() != null:
        _current_scene.queue_free()
    _current_scene = next_scene
    get_tree().root.add_child(_current_scene)

func change_scene_deferred(scene_path: String) -> void:
    call_deferred("change_scene", scene_path)

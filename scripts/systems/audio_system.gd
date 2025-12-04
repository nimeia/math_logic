extends Node
class_name AudioSystem

var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _sfx_bus: StringName = "Master"

func _ready() -> void:
    if _music_player.get_parent() == null:
        add_child(_music_player)
        _music_player.bus = _sfx_bus

func set_music(stream: AudioStream) -> void:
    if stream == null:
        return
    _music_player.stream = stream

func play_music() -> void:
    if _music_player.stream == null:
        Logger.warn("Music stream not set")
        return
    _music_player.play()

func stop_music() -> void:
    _music_player.stop()

func play_sfx(stream: AudioStream) -> void:
    if stream == null:
        return
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = _sfx_bus
    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()

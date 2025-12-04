extends Node

enum LogLevel { DEBUG, INFO, WARNING, ERROR }
var _level: LogLevel = LogLevel.DEBUG

func set_level(level: LogLevel) -> void:
    _level = level

func debug(message: String) -> void:
    _emit(LogLevel.DEBUG, message)

func info(message: String) -> void:
    _emit(LogLevel.INFO, message)

func warn(message: String) -> void:
    _emit(LogLevel.WARNING, message)

func error(message: String) -> void:
    _emit(LogLevel.ERROR, message)

func _emit(level: LogLevel, message: String) -> void:
    if level < _level:
        return
    var prefix: String = "[LOG]"
    match level:
        LogLevel.DEBUG:
            prefix = "[DEBUG]"
        LogLevel.INFO:
            prefix = "[INFO]"
        LogLevel.WARNING:
            prefix = "[WARN]"
        LogLevel.ERROR:
            prefix = "[ERROR]"
    print("%s %s" % [prefix, message])

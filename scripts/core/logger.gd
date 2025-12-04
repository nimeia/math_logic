extends Node

enum LogLevel { DEBUG, INFO, WARNING, ERROR }
static var _level: LogLevel = LogLevel.DEBUG

static func set_level(level: LogLevel) -> void:
    _level = level

static func debug(message: String) -> void:
    _emit(LogLevel.DEBUG, message)

static func info(message: String) -> void:
    _emit(LogLevel.INFO, message)

static func warn(message: String) -> void:
    _emit(LogLevel.WARNING, message)

static func error(message: String) -> void:
    _emit(LogLevel.ERROR, message)

static func _emit(level: LogLevel, message: String) -> void:
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

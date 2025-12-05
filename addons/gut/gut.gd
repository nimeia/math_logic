extends Object
class_name GutTest

var _failures: Array[String] = []

func assert_true(condition: bool, message: String = "") -> bool:
    if not condition:
        _failures.append(_format_message(message, "Expected condition to be true"))
    return condition

func assert_false(condition: bool, message: String = "") -> bool:
    if condition:
        _failures.append(_format_message(message, "Expected condition to be false"))
    return not condition

func assert_eq(actual, expected, message: String = "") -> bool:
    if actual != expected:
        var default_msg := "Expected %s but got %s" % [str(expected), str(actual)]
        _failures.append(_format_message(message, default_msg))
        return false
    return true

func assert_ne(actual, unexpected, message: String = "") -> bool:
    if actual == unexpected:
        var default_msg := "Did not expect %s" % [str(unexpected)]
        _failures.append(_format_message(message, default_msg))
        return false
    return true

func fail(message: String = "Failure") -> void:
    _failures.append(message)

func get_failure_count() -> int:
    return _failures.size()

func get_failures() -> Array[String]:
    return _failures.duplicate()

func _format_message(message: String, fallback: String) -> String:
    if message.is_empty():
        return fallback
    return message

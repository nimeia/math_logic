extends SceneTree

const GutTest = preload("res://addons/gut/gut.gd")
const TEST_DIR := "res://tests"

func _init() -> void:
    var code := _run_tests()
    quit(code)

func _run_tests() -> int:
    var test_files := _collect_test_files()
    if test_files.is_empty():
        push_error("No test files found in %s" % TEST_DIR)
        return 1

    var total := 0
    var failed := 0

    for path in test_files:
        var script := load(path)
        if script == null:
            failed += 1
            push_error("Failed to load test script: %s" % path)
            continue

        var test_instance = script.new()
        if not (test_instance is GutTest):
            failed += 1
            push_error("%s does not extend GutTest" % path)
            continue

        var test_methods := _get_test_methods(test_instance)
        for method_name in test_methods:
            total += 1
            var before: int = test_instance.get_failure_count()
            test_instance.call(method_name)
            var after: int = test_instance.get_failure_count()
            if after > before:
                failed += 1
                var failures: Array = test_instance.get_failures().slice(before, after)
                for f in failures:
                    push_error("%s::%s - %s" % [path, method_name, f])

    print("Ran %s tests: %s passed, %s failed" % [total, total - failed, failed])
    return 0 if failed == 0 else 1

func _collect_test_files() -> Array[String]:
    var files: Array[String] = []
    var dir := DirAccess.open(TEST_DIR)
    if dir == null:
        return files
    for file_name in dir.get_files():
        if file_name.ends_with(".gd"):
            files.append("%s/%s" % [TEST_DIR, file_name])
    files.sort()
    return files

func _get_test_methods(test_instance: GutTest) -> Array[String]:
    var method_names: Array[String] = []
    for method in test_instance.get_method_list():
        if method.name.begins_with("test_"):
            method_names.append(method.name)
    method_names.sort()
    return method_names

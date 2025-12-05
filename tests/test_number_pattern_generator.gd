extends "res://addons/gut/gut.gd"
const NumberPatternGenerator = preload("res://scripts/gameplay/number_pattern_generator.gd")


const MAX_EASY_VALUE := 100
const MAX_MEDIUM_VALUE := 200
const MAX_HARD_VALUE := 1000

func _new_generator(seed: int) -> NumberPatternGenerator:
    var generator := NumberPatternGenerator.new()
    generator.rng.seed = seed
    return generator

func _assert_sequence_bounds(sequence: Array, max_value: int) -> void:
    for value in sequence:
        assert_true(value is int, "Sequence value should be an int")
        assert_true(value >= 0, "Sequence value should be non-negative")
        assert_true(value <= max_value, "Sequence value should be within difficulty bounds")

func _assert_placeholder(display: Array) -> void:
    var placeholder_count := 0
    for value in display:
        if str(value) == NumberPatternGenerator.PLACEHOLDER:
            placeholder_count += 1
    assert_eq(placeholder_count, 1, "Exactly one placeholder should be present")

func _assert_valid_puzzle(puzzle: Dictionary, expected_difficulty: String, max_value: int) -> void:
    assert_false(puzzle.is_empty(), "Generated puzzle should not be empty")
    assert_eq(puzzle.get("difficulty", ""), expected_difficulty, "Puzzle difficulty should be set")
    assert_true(puzzle.has("sequence"), "Puzzle should include a sequence")
    assert_true(puzzle.has("display"), "Puzzle should include a display array")
    assert_true(puzzle.has("missing_index"), "Puzzle should include missing index")
    assert_true(puzzle.has("answer"), "Puzzle should include answer")

    var sequence: Array = puzzle["sequence"]
    var display: Array = puzzle["display"]
    var missing_index: int = puzzle["missing_index"]
    var answer = puzzle["answer"]

    assert_eq(sequence.size(), display.size(), "Sequence and display should align")
    assert_true(missing_index >= 0, "Missing index should be non-negative")
    assert_true(missing_index < sequence.size(), "Missing index should be within display range")
    assert_eq(str(display[missing_index]), NumberPatternGenerator.PLACEHOLDER, "Display should hide the missing value")
    assert_eq(answer, sequence[missing_index], "Answer should match the missing sequence value")

    _assert_sequence_bounds(sequence, max_value)
    _assert_placeholder(display)

func test_easy_generation() -> void:
    var generator := _new_generator(1001)
    var puzzle := generator.generate_puzzle("easy")
    _assert_valid_puzzle(puzzle, "easy", MAX_EASY_VALUE)

func test_medium_generation() -> void:
    var generator := _new_generator(2002)
    var puzzle := generator.generate_puzzle("medium")
    _assert_valid_puzzle(puzzle, "medium", MAX_MEDIUM_VALUE)

func test_hard_generation() -> void:
    var generator := _new_generator(3003)
    var puzzle := generator.generate_puzzle("hard")
    _assert_valid_puzzle(puzzle, "hard", MAX_HARD_VALUE)

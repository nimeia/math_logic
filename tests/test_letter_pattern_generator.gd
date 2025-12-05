extends "res://addons/gut/gut.gd"

const LetterPatternGenerator = preload("res://scripts/gameplay/letter_pattern_generator.gd")

func _new_generator(seed: int) -> LetterPatternGenerator:
    var generator := LetterPatternGenerator.new()
    generator.rng.seed = seed
    return generator

func _char_to_idx(letter: String) -> int:
    return letter.unicode_at(0) - "A".unicode_at(0) + 1

func _assert_placeholder_array(display: Array) -> void:
    var count := 0
    for value in display:
        if str(value) == LetterPatternGenerator.PLACEHOLDER or (value is String and value.find(LetterPatternGenerator.PLACEHOLDER) >= 0):
            count += 1
    assert_eq(count, 1, "A single placeholder should exist in the display")

func _assert_placeholder_dict(display: Dictionary) -> void:
    var count := 0
    for value in display.values():
        if str(value) == LetterPatternGenerator.PLACEHOLDER or (value is String and value.find(LetterPatternGenerator.PLACEHOLDER) >= 0):
            count += 1
    assert_eq(count, 1, "A single placeholder should exist in the display")

func _assert_basic_sequence_puzzle(puzzle: Dictionary, expected_difficulty: String) -> void:
    assert_false(puzzle.is_empty(), "Puzzle should not be empty")
    assert_eq(puzzle.get("difficulty", ""), expected_difficulty, "Difficulty should be tagged")
    assert_true(puzzle.has("sequence"), "Sequence should be present")
    assert_true(puzzle.has("display"), "Display should be present")
    assert_true(puzzle.has("missing_index"), "Missing index should be present")
    assert_true(puzzle.has("answer"), "Answer should be present")

    var display: Array = puzzle["display"]
    var missing_index: int = puzzle["missing_index"]
    assert_true(missing_index >= 0 and missing_index < display.size(), "Missing index must be within the display")
    _assert_placeholder_array(display)

func _generate_template(generator: LetterPatternGenerator, template_id: String, base_seed: int, difficulty: String = "easy") -> Dictionary:
    var attempts := 0
    var seed := base_seed
    while attempts < 6:
        generator.rng.seed = seed
        for entry in generator._templates.get(difficulty, []):
            if entry.get("id", "") == template_id:
                var puzzle: Dictionary = entry["fn"].call()
                if not puzzle.is_empty():
                    puzzle["difficulty"] = difficulty
                    return puzzle
        seed += 1
        attempts += 1
    assert_true(false, "Template %s should generate a valid puzzle" % template_id)
    return {}

func test_easy_overall_generation() -> void:
    var generator := _new_generator(300)
    var puzzle := generator.generate_puzzle("easy")
    _assert_basic_sequence_puzzle(puzzle, "easy")

func test_l1_1_increasing_step_one() -> void:
    var generator := _new_generator(301)
    var puzzle := _generate_template(generator, "L1-1", 301)
    _assert_basic_sequence_puzzle(puzzle, "easy")
    var sequence: Array = puzzle["sequence"]
    assert_true(sequence.size() >= 4 and sequence.size() <= 5, "Length should be 4 or 5")
    for i in range(sequence.size() - 1):
        assert_eq(sequence[i + 1], char(sequence[i].unicode_at(0) + 1), "Sequence should increase by 1")
    assert_eq(puzzle["missing_index"], sequence.size() - 1, "Last value should be missing")

func test_l1_2_decreasing_step_one() -> void:
    var generator := _new_generator(302)
    var puzzle := _generate_template(generator, "L1-2", 302)
    _assert_basic_sequence_puzzle(puzzle, "easy")
    var sequence: Array = puzzle["sequence"]
    for i in range(sequence.size() - 1):
        assert_eq(sequence[i + 1], char(sequence[i].unicode_at(0) - 1), "Sequence should decrease by 1")
    assert_eq(puzzle["missing_index"], sequence.size() - 1, "Last value should be missing")

func test_l1_3_constant_step_two_or_three() -> void:
    var generator := _new_generator(303)
    var puzzle := _generate_template(generator, "L1-3", 303)
    _assert_basic_sequence_puzzle(puzzle, "easy")
    var metadata: Dictionary = puzzle.get("metadata", {})
    var step: int = metadata.get("step", 0)
    assert_true(step == 2 or step == 3, "Step should be 2 or 3")
    var sequence: Array = puzzle["sequence"]
    for i in range(sequence.size() - 1):
        var expected := char(sequence[i].unicode_at(0) + step)
        assert_eq(sequence[i + 1], expected, "Sequence should follow constant step")

func test_l1_4_alternating_letters() -> void:
    var generator := _new_generator(304)
    var puzzle := _generate_template(generator, "L1-4", 304)
    _assert_basic_sequence_puzzle(puzzle, "easy")
    var sequence: Array = puzzle["sequence"]
    assert_true(sequence.size() >= 5 and sequence.size() <= 6, "Length should be 5 or 6")
    var first: String = sequence[0]
    var second: String = sequence[1]
    assert_true(first != second, "Two alternating letters should differ")
    for i in range(sequence.size()):
        var expected := first if i % 2 == 0 else second
        assert_eq(sequence[i], expected, "Letters should alternate")
    var expected_answer: String = first if (sequence.size() - 1) % 2 == 0 else second
    assert_eq(puzzle["answer"], expected_answer, "Answer should follow alternation")

func test_l1_5_number_to_letter_mapping() -> void:
    var generator := _new_generator(305)
    var puzzle := _generate_template(generator, "L1-5", 305)
    _assert_basic_sequence_puzzle(puzzle, "easy")
    var sequence: Array = puzzle["sequence"]
    for i in range(sequence.size() - 1):
        assert_true(sequence[i + 1] - sequence[i] in [1, 2], "Numbers should advance by 1 or 2")
    assert_true(sequence.back() <= 26, "Numbers must map to alphabet")
    assert_eq(puzzle["answer"], char(sequence.back() + "A".unicode_at(0) - 1), "Answer should be mapped letter of last number")

func test_l1_6_letter_to_index_question() -> void:
    var generator := _new_generator(306)
    var puzzle := _generate_template(generator, "L1-6", 306)
    _assert_basic_sequence_puzzle(puzzle, "easy")
    var sequence: Array = puzzle["sequence"]
    var step: int = puzzle.get("metadata", {}).get("step", 0)
    for i in range(sequence.size() - 1):
        var expected := char(sequence[i].unicode_at(0) + step)
        assert_eq(sequence[i + 1], expected, "Sequence should follow constant step")
    assert_eq(puzzle.get("answer"), _char_to_idx(sequence.back()), "Answer should be index of last letter")
    assert_eq(puzzle.get("metadata", {}).get("answer_type", ""), "index", "Answer type should indicate index")

func test_medium_overall_generation() -> void:
    var generator := _new_generator(400)
    var puzzle := generator.generate_puzzle("medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")

func test_l2_1_missing_middle_constant_step() -> void:
    var generator := _new_generator(401)
    var puzzle := _generate_template(generator, "L2-1", 401, "medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")
    var sequence: Array = puzzle["sequence"]
    var step: int = puzzle.get("metadata", {}).get("step", 0)
    for i in range(sequence.size() - 1):
        var expected := char(sequence[i].unicode_at(0) + step)
        assert_eq(sequence[i + 1], expected, "Sequence should keep constant step")
    assert_true(puzzle["missing_index"] in [1, 2, 3], "Missing index should be in the middle range")

func test_l2_2_dual_progressions() -> void:
    var generator := _new_generator(402)
    var puzzle := _generate_template(generator, "L2-2", 402, "medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")
    var sequence: Array = puzzle["sequence"]
    var p1: int = puzzle.get("metadata", {}).get("p1", 0)
    var p2: int = puzzle.get("metadata", {}).get("p2", 0)
    var d1: int = puzzle.get("metadata", {}).get("d1", 0)
    var d2: int = puzzle.get("metadata", {}).get("d2", 0)
    for i in range(sequence.size()):
        var expected_idx := p1 + (i / 2) * d1 if i % 2 == 0 else p2 + (i / 2) * d2
        assert_eq(_char_to_idx(sequence[i]), expected_idx, "Odd/even terms should follow respective progressions")

func test_l2_3_pairwise_letter_and_number_sequences() -> void:
    var generator := _new_generator(403)
    var puzzle := _generate_template(generator, "L2-3", 403, "medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")
    var sequence: Array = puzzle["sequence"]
    var p: int = puzzle.get("metadata", {}).get("p", 0)
    var dL: int = puzzle.get("metadata", {}).get("dL", 0)
    var n0: int = puzzle.get("metadata", {}).get("n0", 0)
    var dN: int = puzzle.get("metadata", {}).get("dN", 0)
    for i in range(sequence.size()):
        var entry: String = sequence[i]
        var letter := entry.substr(0, 1)
        var number := int(entry.substr(1, entry.length()))
        assert_eq(_char_to_idx(letter), p + i * dL, "Letters should follow their arithmetic progression")
        assert_eq(number, n0 + i * dN, "Numbers should follow their arithmetic progression")

func test_l2_4_known_caesar_shift() -> void:
    var generator := _new_generator(404)
    var puzzle := _generate_template(generator, "L2-4", 404, "medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")
    var shift: int = puzzle.get("metadata", {}).get("shift", 0)
    var base_letters: Array = puzzle.get("metadata", {}).get("base_letters", [])
    assert_eq(base_letters.size(), 4, "Should include four base letters")
    for i in range(base_letters.size() - 1):
        var cipher := char(base_letters[i].unicode_at(0) + shift)
        assert_eq(puzzle["display"][i].split("→")[1], cipher, "Cipher letter should be shifted")
    assert_true(puzzle["display"].back().find("?") >= 0, "Last mapping should be hidden with placeholder")
    assert_eq(puzzle["answer"], char(base_letters.back().unicode_at(0) + shift), "Answer should apply the same shift")

func test_l2_5_digits_to_final_letter() -> void:
    var generator := _new_generator(405)
    var puzzle := _generate_template(generator, "L2-5", 405, "medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")
    var sequence: Array = puzzle["sequence"]
    var step: int = puzzle.get("metadata", {}).get("step", 0)
    for i in range(sequence.size() - 1):
        assert_eq(sequence[i + 1] - sequence[i], step, "Numbers should keep constant step")
    assert_eq(puzzle["answer"], char(sequence.back() + "A".unicode_at(0) - 1), "Answer should map last number to a letter")

func test_l2_6_dual_row_letter_and_index() -> void:
    var generator := _new_generator(406)
    var puzzle := _generate_template(generator, "L2-6", 406, "medium")
    _assert_basic_sequence_puzzle(puzzle, "medium")
    var letters: Array = puzzle["sequence"]
    var step: int = puzzle.get("metadata", {}).get("step", 0)
    for i in range(letters.size() - 1):
        var expected := char(letters[i].unicode_at(0) + step)
        assert_eq(letters[i + 1], expected, "Letters should advance by constant step")
    var display: Array = puzzle["display"]
    var missing_idx: int = puzzle["missing_index"]
    for i in range(display.size()):
        if i == missing_idx:
            continue
        var parts: Array = display[i].split("(")
        var letter: String = parts[0]
        var number: int = int(parts[1].replace(")", ""))
        assert_eq(number, _char_to_idx(letter), "Displayed number should be the index of the letter")
    assert_eq(puzzle["answer"], letters[missing_idx], "Answer should reveal missing letter")

func test_hard_overall_generation() -> void:
    var generator := _new_generator(500)
    var puzzle := generator.generate_puzzle("hard")
    _assert_basic_sequence_puzzle(puzzle, "hard")

func test_l3_1_growing_deltas() -> void:
    var generator := _new_generator(501)
    var puzzle := _generate_template(generator, "L3-1", 501, "hard")
    _assert_basic_sequence_puzzle(puzzle, "hard")
    var deltas := [1, 2, 3, 4]
    var sequence: Array = puzzle["sequence"]
    for i in range(deltas.size()):
        var expected := char(sequence[i].unicode_at(0) + deltas[i])
        assert_eq(sequence[i + 1], expected, "Sequence should use increasing deltas")

func test_l3_2_dual_sequences_with_increasing_steps() -> void:
    var generator := _new_generator(502)
    var puzzle := _generate_template(generator, "L3-2", 502, "hard")
    _assert_basic_sequence_puzzle(puzzle, "hard")
    var letters_meta: Array = puzzle.get("metadata", {}).get("letters", [])
    var numbers_meta: Array = puzzle.get("metadata", {}).get("numbers", [])
    var letter_deltas: Array = puzzle.get("metadata", {}).get("letter_deltas", [])
    var number_deltas: Array = puzzle.get("metadata", {}).get("number_deltas", [])
    var sequence: Array = puzzle["sequence"]
    assert_eq(letters_meta.size(), numbers_meta.size(), "Letter and number sequences should align")
    for i in range(letters_meta.size() - 1):
        assert_eq(letters_meta[i + 1] - letters_meta[i], letter_deltas[i], "Letter deltas should increase by pattern")
        assert_eq(numbers_meta[i + 1] - numbers_meta[i], number_deltas[i], "Number deltas should increase by pattern")
        var entry: String = sequence[i + 1]
        var letter := entry.substr(0, 1)
        var number := int(entry.substr(1, entry.length()))
        assert_eq(_char_to_idx(letter), letters_meta[i + 1], "Letter entries should follow metadata")
        assert_eq(number, numbers_meta[i + 1], "Number entries should follow metadata")

func test_l3_3_alternating_steps() -> void:
    var generator := _new_generator(503)
    var puzzle := _generate_template(generator, "L3-3", 503, "hard")
    _assert_basic_sequence_puzzle(puzzle, "hard")
    var add_a: int = puzzle.get("metadata", {}).get("add_a", 0)
    var add_b: int = puzzle.get("metadata", {}).get("add_b", 0)
    var sequence: Array = puzzle["sequence"]
    for i in range(sequence.size() - 1):
        var step := add_a if i % 2 == 0 else add_b
        var expected := char(sequence[i].unicode_at(0) + step)
        assert_eq(sequence[i + 1], expected, "Sequence should alternate steps")

func test_l3_4_unknown_shift_decoding() -> void:
    var generator := _new_generator(504)
    var puzzle := _generate_template(generator, "L3-4", 504, "hard")
    _assert_basic_sequence_puzzle(puzzle, "hard")
    var shift: int = puzzle.get("metadata", {}).get("shift", 0)
    var base_letters: Array = puzzle.get("metadata", {}).get("base_letters", [])
    for i in range(base_letters.size() - 1):
        var mapping_parts: Array = puzzle["display"][i].split("→")
        var cipher: String = mapping_parts[1]
        assert_eq(cipher, char(base_letters[i].unicode_at(0) + shift), "Cipher should apply discovered shift")
    assert_true(puzzle["display"].back().find("?") >= 0, "Last cipher should be hidden")
    assert_eq(puzzle["answer"], char(base_letters.back().unicode_at(0) + shift), "Answer should apply same shift")

func test_l3_5_grid_uses_row_and_column_steps() -> void:
    var generator := _new_generator(505)
    var puzzle := _generate_template(generator, "L3-5", 505, "hard")
    assert_false(puzzle.is_empty(), "Puzzle should not be empty")
    var dH: int = puzzle.get("metadata", {}).get("dH", 0)
    var dV: int = puzzle.get("metadata", {}).get("dV", 0)
    var start: int = puzzle.get("metadata", {}).get("start", 0)
    var cells: Dictionary = puzzle.get("cells", {})
    var display: Dictionary = puzzle.get("display", {})
    _assert_placeholder_dict(display)
    assert_eq(cells.get("r1c1", ""), char("A".unicode_at(0) + start - 1), "Top-left should match start")
    for r in range(3):
        for c in range(3):
            var key := "r%dc%d" % [r + 1, c + 1]
            var expected_idx := start + c * dH + r * dV
            assert_eq(_char_to_idx(cells[key]), expected_idx, "Grid should follow row/col arithmetic")

func test_l3_6_linear_letter_number_relation() -> void:
    var generator := _new_generator(506)
    var puzzle := _generate_template(generator, "L3-6", 506, "hard")
    _assert_basic_sequence_puzzle(puzzle, "hard")
    var relation: int = puzzle.get("metadata", {}).get("relation", 0)
    var offset: int = puzzle.get("metadata", {}).get("offset", 0)
    var sequence: Array = puzzle["sequence"]
    var missing_idx: int = puzzle["missing_index"]
    for i in range(sequence.size()):
        var entry: String = sequence[i]
        var parts: Array = entry.split("→")
        var letter: String = parts[0]
        var number: int = int(parts[1]) if parts[1] != LetterPatternGenerator.PLACEHOLDER else puzzle["answer"]
        var idx_val: int = _char_to_idx(letter)
        if relation == 1:
            assert_eq(number, idx_val + offset, "Number should equal index plus offset")
        else:
            assert_eq(number, idx_val * 2, "Number should double the index")
    var missing_entry_letter: String = sequence[missing_idx].split("→")[0]
    var expected_answer: int = _char_to_idx(missing_entry_letter) + offset if relation == 1 else _char_to_idx(missing_entry_letter) * 2
    assert_eq(puzzle["answer"], expected_answer, "Answer should follow linear relation")

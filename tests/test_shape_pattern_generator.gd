extends "res://addons/gut/gut.gd"

const ShapePatternGenerator = preload("res://scripts/gameplay/shape_pattern_generator.gd")

const MAX_EASY_VALUE := 50
const MAX_MEDIUM_VALUE := 200
const MAX_HARD_VALUE := 1000

func _new_generator(seed: int) -> ShapePatternGenerator:
    var generator := ShapePatternGenerator.new()
    generator.rng.seed = seed
    return generator

func _assert_cell_bounds(cells: Dictionary, max_value: int) -> void:
    for value in cells.values():
        assert_true(value is int, "Cell value should be an int")
        assert_true(value >= 0, "Cell value should be non-negative")
        assert_true(value <= max_value, "Cell value should be within difficulty bounds")

func _assert_placeholder(display: Dictionary) -> void:
    var placeholder_count := 0
    for value in display.values():
        if str(value) == ShapePatternGenerator.PLACEHOLDER:
            placeholder_count += 1
    assert_eq(placeholder_count, 1, "Exactly one placeholder should be present")

func _assert_valid_puzzle(puzzle: Dictionary, max_value: int = MAX_EASY_VALUE) -> void:
    assert_false(puzzle.is_empty(), "Generated puzzle should not be empty")
    assert_true(puzzle.has("cells"), "Puzzle should include cells")
    assert_true(puzzle.has("display"), "Puzzle should include display")
    assert_true(puzzle.has("missing_key"), "Puzzle should include missing_key")
    assert_true(puzzle.has("answer"), "Puzzle should include answer")

    var cells: Dictionary = puzzle["cells"]
    var display: Dictionary = puzzle["display"]
    var missing_key: String = puzzle["missing_key"]
    var answer = puzzle["answer"]

    assert_true(display.has(missing_key), "Display should hide the missing cell")
    assert_true(cells.has(missing_key), "Cells should contain the missing key")
    assert_eq(str(display[missing_key]), ShapePatternGenerator.PLACEHOLDER, "Display should use placeholder for missing cell")
    assert_eq(answer, cells[missing_key], "Answer should match missing cell value")

    _assert_cell_bounds(cells, max_value)
    _assert_placeholder(display)

func _generate_template(generator: ShapePatternGenerator, template_id: String, base_seed: int, difficulty: String = "easy") -> Dictionary:
    var attempts := 0
    var seed := base_seed
    while attempts < 6:
        generator.rng.seed = seed
        for entry in generator._templates.get(difficulty, []):
            if entry.get("id", "") == template_id:
                var puzzle: Dictionary = entry["fn"].call()
                if not puzzle.is_empty():
                    return puzzle
        seed += 1
        attempts += 1
    assert_true(false, "Template %s should generate a valid puzzle" % template_id)
    return {}

func test_easy_generation_overall() -> void:
    var generator := _new_generator(2024)
    var puzzle := generator.generate_puzzle("easy")
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.get("difficulty", ""), "easy", "Difficulty should be set on generated puzzle")

func test_l1_1_row_sum() -> void:
    var generator := _new_generator(101)
    var puzzle := _generate_template(generator, "L1-1", 101)
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.cells["r1c3"], puzzle.cells["r1c1"] + puzzle.cells["r1c2"], "Right cell should equal left + middle")

func test_l1_2_column_sum() -> void:
    var generator := _new_generator(202)
    var puzzle := _generate_template(generator, "L1-2", 202)
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.cells["r3c1"], puzzle.cells["r1c1"] + puzzle.cells["r2c1"], "Bottom cell should equal top + middle")

func test_l1_3_grid_row_sum() -> void:
    var generator := _new_generator(303)
    var puzzle := _generate_template(generator, "L1-3", 303)
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.cells["r2c2"], puzzle.cells["r1c1"] + puzzle.cells["r1c2"], "Bottom-right should equal top row sum")

func test_l1_4_cross_center_from_lr() -> void:
    var generator := _new_generator(404)
    var puzzle := _generate_template(generator, "L1-4", 404)
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.cells["C"], puzzle.cells["L"] + puzzle.cells["R"], "Center should equal left + right")

func test_l1_5_triangle_center() -> void:
    var generator := _new_generator(505)
    var puzzle := _generate_template(generator, "L1-5", 505)
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.cells["C"], puzzle.cells["T"] + puzzle.cells["L"], "Triangle center should equal top + left")

func test_l1_6_cross_center_from_ud() -> void:
    var generator := _new_generator(606)
    var puzzle := _generate_template(generator, "L1-6", 606)
    _assert_valid_puzzle(puzzle)
    assert_eq(puzzle.cells["C"], puzzle.cells["U"] + puzzle.cells["D"], "Center should equal up + down")

func test_medium_generation_overall() -> void:
    var generator := _new_generator(707)
    var puzzle := generator.generate_puzzle("medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    assert_eq(puzzle.get("difficulty", ""), "medium", "Difficulty should be set on generated puzzle")

func test_hard_generation_overall() -> void:
    var generator := _new_generator(9090)
    var puzzle := generator.generate_puzzle("hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)
    assert_eq(puzzle.get("difficulty", ""), "hard", "Difficulty should be set on generated puzzle")

func test_l2_1_grid_rows_sum() -> void:
    var generator := _new_generator(808)
    var puzzle := _generate_template(generator, "L2-1", 808, "medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    for row in range(3):
        var key_left := "r%dc1" % (row + 1)
        var key_mid := "r%dc2" % (row + 1)
        var key_right := "r%dc3" % (row + 1)
        assert_eq(puzzle.cells[key_right], puzzle.cells[key_left] + puzzle.cells[key_mid], "Row %d right should equal left + middle" % (row + 1))

func test_l2_2_grid_cols_sum() -> void:
    var generator := _new_generator(909)
    var puzzle := _generate_template(generator, "L2-2", 909, "medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    for col in range(3):
        var key_top := "r1c%d" % (col + 1)
        var key_mid := "r2c%d" % (col + 1)
        var key_bottom := "r3c%d" % (col + 1)
        assert_eq(puzzle.cells[key_bottom], puzzle.cells[key_top] + puzzle.cells[key_mid], "Column %d bottom should equal top + middle" % (col + 1))

func test_l2_3_row_and_col_sums() -> void:
    var generator := _new_generator(1010)
    var puzzle := _generate_template(generator, "L2-3", 1010, "medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    assert_eq(puzzle.cells["r1c3"], puzzle.cells["r1c1"] + puzzle.cells["r1c2"], "Row 1 sum should be correct")
    assert_eq(puzzle.cells["r2c3"], puzzle.cells["r2c1"] + puzzle.cells["r2c2"], "Row 2 sum should be correct")
    assert_eq(puzzle.cells["r3c1"], puzzle.cells["r1c1"] + puzzle.cells["r2c1"], "Column 1 sum should be correct")
    assert_eq(puzzle.cells["r3c2"], puzzle.cells["r1c2"] + puzzle.cells["r2c2"], "Column 2 sum should be correct")
    assert_eq(puzzle.cells["r3c3"], puzzle.cells["r1c3"] + puzzle.cells["r2c3"], "Bottom-right should equal row sums")
    assert_eq(puzzle.cells["r3c3"], puzzle.cells["r3c1"] + puzzle.cells["r3c2"], "Bottom-right should equal column sums")

func test_l2_4_cross_full_sum() -> void:
    var generator := _new_generator(1111)
    var puzzle := _generate_template(generator, "L2-4", 1111, "medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    assert_eq(puzzle.cells["C"], puzzle.cells["U"] + puzzle.cells["D"] + puzzle.cells["L"] + puzzle.cells["R"], "Center should equal sum of all directions")

func test_l2_5_cross_mul_plus_sum() -> void:
    var generator := _new_generator(1212)
    var puzzle := _generate_template(generator, "L2-5", 1212, "medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    assert_eq(puzzle.cells["C"], puzzle.cells["U"] * puzzle.cells["D"] + puzzle.cells["L"] + puzzle.cells["R"], "Center should equal product plus sides")

func test_l2_6_triangle_edge_sums_equal() -> void:
    var generator := _new_generator(1313)
    var puzzle := _generate_template(generator, "L2-6", 1313, "medium")
    _assert_valid_puzzle(puzzle, MAX_MEDIUM_VALUE)
    var target_sum: int = puzzle.cells["S"]
    assert_true(target_sum > 0, "Edge target sum should be positive")
    assert_eq(puzzle.cells["A"] + puzzle.cells["D"] + puzzle.cells["B"], target_sum, "Edge AB sum should equal target")
    assert_eq(puzzle.cells["B"] + puzzle.cells["E"] + puzzle.cells["C"], target_sum, "Edge BC sum should equal target")
    assert_eq(puzzle.cells["C"] + puzzle.cells["F"] + puzzle.cells["A"], target_sum, "Edge CA sum should equal target")

func test_l3_1_magic_square_rows_cols_and_diagonals() -> void:
    var generator := _new_generator(2025)
    var puzzle := _generate_template(generator, "L3-1", 2025, "hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)

    var target_sum: int = puzzle.cells["r1c1"] + puzzle.cells["r1c2"] + puzzle.cells["r1c3"]
    for row in range(3):
        var key_a := "r%dc1" % (row + 1)
        var key_b := "r%dc2" % (row + 1)
        var key_c := "r%dc3" % (row + 1)
        assert_eq(puzzle.cells[key_a] + puzzle.cells[key_b] + puzzle.cells[key_c], target_sum, "Row %d should match magic sum" % (row + 1))
    for col in range(3):
        var key_a := "r1c%d" % (col + 1)
        var key_b := "r2c%d" % (col + 1)
        var key_c := "r3c%d" % (col + 1)
        assert_eq(puzzle.cells[key_a] + puzzle.cells[key_b] + puzzle.cells[key_c], target_sum, "Column %d should match magic sum" % (col + 1))
    assert_eq(puzzle.cells["r1c1"] + puzzle.cells["r2c2"] + puzzle.cells["r3c3"], target_sum, "Primary diagonal should match magic sum")
    assert_eq(puzzle.cells["r1c3"] + puzzle.cells["r2c2"] + puzzle.cells["r3c1"], target_sum, "Secondary diagonal should match magic sum")

func test_l3_2_magic_triangle_two_missing_variants() -> void:
    var generator := _new_generator(2121)
    var puzzle := _generate_template(generator, "L3-2", 2121, "hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)

    var target_sum: int = puzzle.cells["S"]
    assert_true(target_sum > 0, "Target sum should be positive")
    assert_eq(puzzle.cells["A"] + puzzle.cells["D"] + puzzle.cells["B"], target_sum, "Edge AB should match target")
    assert_eq(puzzle.cells["B"] + puzzle.cells["E"] + puzzle.cells["C"], target_sum, "Edge BC should match target")
    assert_eq(puzzle.cells["C"] + puzzle.cells["F"] + puzzle.cells["A"], target_sum, "Edge CA should match target")

func test_l3_3_magic_square_with_corner_sum() -> void:
    var generator := _new_generator(2323)
    var puzzle := _generate_template(generator, "L3-3", 2323, "hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)

    var target_sum: int = puzzle.cells["r1c1"] + puzzle.cells["r1c2"] + puzzle.cells["r1c3"]
    for row in range(3):
        var key_a := "r%dc1" % (row + 1)
        var key_b := "r%dc2" % (row + 1)
        var key_c := "r%dc3" % (row + 1)
        assert_eq(puzzle.cells[key_a] + puzzle.cells[key_b] + puzzle.cells[key_c], target_sum, "Row %d should match target sum" % (row + 1))
    for col in range(3):
        var key_a := "r1c%d" % (col + 1)
        var key_b := "r2c%d" % (col + 1)
        var key_c := "r3c%d" % (col + 1)
        assert_eq(puzzle.cells[key_a] + puzzle.cells[key_b] + puzzle.cells[key_c], target_sum, "Column %d should match target sum" % (col + 1))

    var corner_sum: int = puzzle.cells["r1c1"] + puzzle.cells["r1c3"] + puzzle.cells["r3c1"] + puzzle.cells["r3c3"]
    assert_eq(corner_sum, puzzle.metadata.get("corner_sum", corner_sum), "Corner sum metadata should reflect actual sum")

func test_l3_4_double_circle_intersection() -> void:
    var generator := _new_generator(2424)
    var puzzle := _generate_template(generator, "L3-4", 2424, "hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)

    var target_sum: int = puzzle.cells["S"]
    assert_eq(puzzle.cells["A"] + puzzle.cells["X"] + puzzle.cells["B"], target_sum, "Circle 1 sum should match target")
    assert_eq(puzzle.cells["C"] + puzzle.cells["X"] + puzzle.cells["D"], target_sum, "Circle 2 sum should match target")

func test_l3_5_square_diagonal_and_center_average() -> void:
    var generator := _new_generator(2525)
    var puzzle := _generate_template(generator, "L3-5", 2525, "hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)

    assert_eq(puzzle.cells["A"] + puzzle.cells["C"], puzzle.cells["B"] + puzzle.cells["D"], "Diagonal sums should balance")
    var total: int = puzzle.cells["A"] + puzzle.cells["B"] + puzzle.cells["C"] + puzzle.cells["D"]
    assert_eq(puzzle.cells["E"], total / 4, "Center should be average of corners")

func test_l3_6_progressive_shapes_sequence() -> void:
    var generator := _new_generator(2626)
    var puzzle := _generate_template(generator, "L3-6", 2626, "hard")
    _assert_valid_puzzle(puzzle, MAX_HARD_VALUE)

    var base_sum: int = puzzle.metadata.get("base_sum", 0)
    var delta: int = puzzle.metadata.get("delta", 0)
    for stage in range(3):
        var prefix := "s%d_" % (stage + 1)
        var target_sum: int = base_sum + stage * delta
        var computed_sum: int = puzzle.cells[prefix + "C"] + puzzle.cells[prefix + "U"] + puzzle.cells[prefix + "L"] + puzzle.cells[prefix + "R"]
        assert_eq(computed_sum, target_sum, "Stage %d total should match progressive rule" % (stage + 1))

extends Node
class_name ShapePatternGenerator

const PLACEHOLDER := "?"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _templates: Dictionary = {}

func _init() -> void:
    rng.randomize()
    _templates = {
        "easy": [
            {"id": "L1-1", "fn": Callable(self, "_template_l1_1")},
            {"id": "L1-2", "fn": Callable(self, "_template_l1_2")},
            {"id": "L1-3", "fn": Callable(self, "_template_l1_3")},
            {"id": "L1-4", "fn": Callable(self, "_template_l1_4")},
            {"id": "L1-5", "fn": Callable(self, "_template_l1_5")},
            {"id": "L1-6", "fn": Callable(self, "_template_l1_6")}
        ],
        "medium": [
            {"id": "L2-1", "fn": Callable(self, "_template_l2_1")},
            {"id": "L2-2", "fn": Callable(self, "_template_l2_2")},
            {"id": "L2-3", "fn": Callable(self, "_template_l2_3")},
            {"id": "L2-4", "fn": Callable(self, "_template_l2_4")},
            {"id": "L2-5", "fn": Callable(self, "_template_l2_5")},
            {"id": "L2-6", "fn": Callable(self, "_template_l2_6")}
        ],
        "hard": [
            {"id": "L3-1", "fn": Callable(self, "_template_l3_1")},
            {"id": "L3-2", "fn": Callable(self, "_template_l3_2")},
            {"id": "L3-3", "fn": Callable(self, "_template_l3_3")},
            {"id": "L3-4", "fn": Callable(self, "_template_l3_4")},
            {"id": "L3-5", "fn": Callable(self, "_template_l3_5")},
            {"id": "L3-6", "fn": Callable(self, "_template_l3_6")}
        ]
    }

func generate_puzzle(difficulty: String) -> Dictionary:
    var bucket: Array = _templates.get(difficulty, [])
    if bucket.is_empty():
        bucket = _templates.get("easy", [])
    for _i in range(48):
        var choice: Dictionary = bucket[rng.randi_range(0, bucket.size() - 1)]
        var result: Dictionary = choice.fn.call() as Dictionary
        if not result.is_empty():
            result["difficulty"] = difficulty
            return result
    return {}

func _build_puzzle(cells: Dictionary, template_id: String, missing_key: String, metadata: Dictionary = {}) -> Dictionary:
    if not cells.has(missing_key):
        return {}
    var display := cells.duplicate()
    display[missing_key] = PLACEHOLDER
    return {
        "template_id": template_id,
        "cells": cells,
        "display": display,
        "missing_key": missing_key,
        "answer": cells[missing_key],
        "metadata": metadata
    }

func _are_cells_in_bounds(cells: Dictionary, max_value: int, min_value: int = 0) -> bool:
    for value in cells.values():
        if value < min_value or value > max_value:
            return false
    return true

func _choose_missing(keys: Array, prefer: Array = [], prefer_weight: float = 0.75) -> String:
    if keys.is_empty():
        return ""
    if not prefer.is_empty() and rng.randf() < prefer_weight:
        return prefer[rng.randi_range(0, prefer.size() - 1)]
    return keys[rng.randi_range(0, keys.size() - 1)]

func _template_l1_1() -> Dictionary:
    var a: int = rng.randi_range(1, 20)
    var b: int = rng.randi_range(1, 20)
    var cells := {
        "r1c1": a,
        "r1c2": b,
        "r1c3": a + b
    }
    if not _are_cells_in_bounds(cells, 50):
        return {}
    var missing: String = _choose_missing(cells.keys(), ["r1c3"], 0.8)
    return _build_puzzle(cells, "L1-1", missing, {"structure": "line_row"})

func _template_l1_2() -> Dictionary:
    var a: int = rng.randi_range(1, 20)
    var b: int = rng.randi_range(1, 20)
    var cells := {
        "r1c1": a,
        "r2c1": b,
        "r3c1": a + b
    }
    if not _are_cells_in_bounds(cells, 50):
        return {}
    var missing: String = _choose_missing(cells.keys(), ["r3c1"], 0.8)
    return _build_puzzle(cells, "L1-2", missing, {"structure": "line_col"})

func _template_l1_3() -> Dictionary:
    var a: int = rng.randi_range(1, 20)
    var b: int = rng.randi_range(1, 20)
    var d: int = rng.randi_range(1, 20)
    var cells := {
        "r1c1": a,
        "r1c2": b,
        "r2c1": d,
        "r2c2": a + b
    }
    if not _are_cells_in_bounds(cells, 50):
        return {}
    return _build_puzzle(cells, "L1-3", "r2c2", {"structure": "grid_2x2"})

func _template_l1_4() -> Dictionary:
    var left_val: int = rng.randi_range(1, 20)
    var right_val: int = rng.randi_range(1, 20)
    var cells := {
        "L": left_val,
        "R": right_val,
        "C": left_val + right_val,
        "U": rng.randi_range(1, 20),
        "D": rng.randi_range(1, 20)
    }
    if not _are_cells_in_bounds(cells, 50):
        return {}
    return _build_puzzle(cells, "L1-4", "C", {"structure": "cross_lr"})

func _template_l1_5() -> Dictionary:
    var t: int = rng.randi_range(1, 20)
    var l: int = rng.randi_range(1, 20)
    var cells := {
        "T": t,
        "L": l,
        "R": rng.randi_range(1, 20),
        "C": t + l
    }
    if not _are_cells_in_bounds(cells, 50):
        return {}
    return _build_puzzle(cells, "L1-5", "C", {"structure": "triangle_center"})

func _template_l1_6() -> Dictionary:
    var u: int = rng.randi_range(1, 20)
    var d_val: int = rng.randi_range(1, 20)
    var cells := {
        "U": u,
        "D": d_val,
        "C": u + d_val,
        "L": rng.randi_range(1, 20),
        "R": rng.randi_range(1, 20)
    }
    if not _are_cells_in_bounds(cells, 50):
        return {}
    var missing: String = _choose_missing(["C", "U", "D"], ["C"], 0.75)
    return _build_puzzle(cells, "L1-6", missing, {"structure": "cross_ud"})

func _template_l2_1() -> Dictionary:
    var cells: Dictionary = {}
    for row in range(3):
        var left_val: int = rng.randi_range(1, 50)
        var mid_val: int = rng.randi_range(1, 50)
        cells["r%dc1" % (row + 1)] = left_val
        cells["r%dc2" % (row + 1)] = mid_val
        cells["r%dc3" % (row + 1)] = left_val + mid_val
    if not _are_cells_in_bounds(cells, 200):
        return {}
    var missing: String = _choose_missing(["r1c3", "r2c3", "r3c3"], [], 0.6)
    return _build_puzzle(cells, "L2-1", missing, {"structure": "grid_3x3_row"})

func _template_l2_2() -> Dictionary:
    var cells: Dictionary = {}
    for col in range(3):
        var top_val: int = rng.randi_range(1, 50)
        var mid_val: int = rng.randi_range(1, 50)
        cells["r1c%d" % (col + 1)] = top_val
        cells["r2c%d" % (col + 1)] = mid_val
        cells["r3c%d" % (col + 1)] = top_val + mid_val
    if not _are_cells_in_bounds(cells, 200):
        return {}
    var missing: String = _choose_missing(["r3c1", "r3c2", "r3c3"], [], 0.6)
    return _build_puzzle(cells, "L2-2", missing, {"structure": "grid_3x3_col"})

func _template_l2_3() -> Dictionary:
    var cells: Dictionary = {}
    cells["r1c1"] = rng.randi_range(1, 30)
    cells["r1c2"] = rng.randi_range(1, 30)
    cells["r2c1"] = rng.randi_range(1, 30)
    cells["r2c2"] = rng.randi_range(1, 30)
    cells["r1c3"] = cells["r1c1"] + cells["r1c2"]
    cells["r2c3"] = cells["r2c1"] + cells["r2c2"]
    cells["r3c1"] = cells["r1c1"] + cells["r2c1"]
    cells["r3c2"] = cells["r1c2"] + cells["r2c2"]
    cells["r3c3"] = cells["r1c3"] + cells["r2c3"]
    if not _are_cells_in_bounds(cells, 200):
        return {}
    return _build_puzzle(cells, "L2-3", "r3c3", {"structure": "grid_3x3_combo"})

func _template_l2_4() -> Dictionary:
    var cells := {
        "U": rng.randi_range(1, 40),
        "D": rng.randi_range(1, 40),
        "L": rng.randi_range(1, 40),
        "R": rng.randi_range(1, 40)
    }
    cells["C"] = cells["U"] + cells["D"] + cells["L"] + cells["R"]
    if not _are_cells_in_bounds(cells, 200):
        return {}
    var missing: String = _choose_missing(["C", "U", "D", "L", "R"], ["C"], 0.7)
    return _build_puzzle(cells, "L2-4", missing, {"structure": "cross_sum"})

func _template_l2_5() -> Dictionary:
    var u: int = rng.randi_range(1, 5)
    var d_val: int = rng.randi_range(1, 5)
    var l: int = rng.randi_range(1, 20)
    var r: int = rng.randi_range(1, 20)
    var center: int = u * d_val + l + r
    var cells := {"U": u, "D": d_val, "L": l, "R": r, "C": center}
    if not _are_cells_in_bounds(cells, 200):
        return {}
    return _build_puzzle(cells, "L2-5", "C", {"structure": "cross_mul_sum"})

func _template_l2_6() -> Dictionary:
    var a: int = rng.randi_range(1, 20)
    var b: int = rng.randi_range(1, 20)
    var c: int = rng.randi_range(1, 20)
    var min_s: int = max(max(a + b, b + c), c + a) + 1
    var s_val: int = rng.randi_range(min_s, min_s + 15)
    var d: int = s_val - a - b
    var e: int = s_val - b - c
    var f: int = s_val - c - a
    if d <= 0 or e <= 0 or f <= 0:
        return {}
    var cells := {"A": a, "B": b, "C": c, "D": d, "E": e, "F": f, "S": s_val}
    if not _are_cells_in_bounds(cells, 200):
        return {}
    var missing: String = _choose_missing(["D", "E", "F"], [], 0.8)
    return _build_puzzle(cells, "L2-6", missing, {"structure": "triangle_edge_sum", "target_sum": s_val})

func _template_l3_1() -> Dictionary:
    var base := [[8, 1, 6], [3, 5, 7], [4, 9, 2]]
    var k: int = rng.randi_range(1, 3)
    var c: int = rng.randi_range(0, 3)
    var cells: Dictionary = {}
    for r in range(3):
        for col in range(3):
            var value: int = base[r][col] * k + c
            cells["r%dc%d" % [r + 1, col + 1]] = value
    var magic_sum: int = cells["r1c1"] + cells["r1c2"] + cells["r1c3"]
    var missing: String = _choose_missing(cells.keys(), [], 0.6)
    return _build_puzzle(cells, "L3-1", missing, {"structure": "magic_square", "k": k, "c": c, "magic_sum": magic_sum})

func _template_l3_2() -> Dictionary:
    var a: int = rng.randi_range(1, 20)
    var b: int = rng.randi_range(1, 20)
    var c: int = rng.randi_range(1, 20)
    var min_s: int = max(max(a + b, b + c), c + a) + 1
    var s_val: int = rng.randi_range(min_s, min_s + 20)
    var d: int = s_val - a - b
    var e: int = s_val - b - c
    var f: int = s_val - c - a
    if d <= 0 or e <= 0 or f <= 0:
        return {}
    var cells := {"A": a, "B": b, "C": c, "D": d, "E": e, "F": f, "S": s_val}
    var missing: String = _choose_missing(["D", "E", "F", "A", "B", "C"], [], 0.6)
    return _build_puzzle(cells, "L3-2", missing, {"structure": "magic_triangle", "target_sum": s_val})

func _template_l3_3() -> Dictionary:
    var base := [[8, 1, 6], [3, 5, 7], [4, 9, 2]]
    var k: int = rng.randi_range(1, 3)
    var c: int = rng.randi_range(0, 3)
    var cells: Dictionary = {}
    for r in range(3):
        for col in range(3):
            var value: int = base[r][col] * k + c
            cells["r%dc%d" % [r + 1, col + 1]] = value
    var magic_sum: int = cells["r1c1"] + cells["r1c2"] + cells["r1c3"]
    var corner_sum: int = cells["r1c1"] + cells["r1c3"] + cells["r3c1"] + cells["r3c3"]
    var missing: String = _choose_missing(["r1c1", "r1c3", "r3c1", "r3c3"], [], 0.7)
    return _build_puzzle(cells, "L3-3", missing, {"structure": "magic_square_corner", "k": k, "c": c, "magic_sum": magic_sum, "corner_sum": corner_sum})

func _template_l3_4() -> Dictionary:
    var target_sum: int = rng.randi_range(15, 50)
    var a: int = rng.randi_range(1, target_sum - 2)
    var x: int = rng.randi_range(1, target_sum - a - 1)
    var b: int = target_sum - a - x
    var c_val: int = rng.randi_range(1, target_sum - 2)
    var d: int = target_sum - c_val - x
    if b <= 0 or d <= 0:
        return {}
    var cells := {"A": a, "B": b, "C": c_val, "D": d, "X": x, "S": target_sum}
    if not _are_cells_in_bounds(cells, 1000):
        return {}
    var missing: String = _choose_missing(["X", "A", "B", "C", "D"], ["X"], 0.7)
    return _build_puzzle(cells, "L3-4", missing, {"structure": "double_circle", "sum": target_sum})

func _template_l3_5() -> Dictionary:
    var a: int = rng.randi_range(1, 30)
    var b: int = rng.randi_range(1, 30)
    var c: int = rng.randi_range(1, 30)
    var d: int = a + c - b
    if d <= 0:
        return {}
    var total: int = a + b + c + d
    if total % 4 != 0:
        return {}
    var e: int = total / 4
    var cells := {"A": a, "B": b, "C": c, "D": d, "E": e}
    if not _are_cells_in_bounds(cells, 1000):
        return {}
    var missing: String = _choose_missing(["D", "E", "A", "B", "C"], ["D", "E"], 0.65)
    return _build_puzzle(cells, "L3-5", missing, {"structure": "square_diag", "total_average": e})

func _template_l3_6() -> Dictionary:
    var base_sum: int = rng.randi_range(12, 25)
    var delta: int = rng.randi_range(2, 6)
    var stages: Array = []
    var cells: Dictionary = {}
    for i in range(3):
        var target: int = base_sum + i * delta
        var center: int = rng.randi_range(2, target - 2)
        var remaining: int = target - center
        var up: int = rng.randi_range(1, remaining - 1)
        var left_val: int = rng.randi_range(1, remaining - up)
        var right_val: int = remaining - up - left_val
        if right_val <= 0:
            return {}
        var prefix := "s%d_" % (i + 1)
        cells[prefix + "C"] = center
        cells[prefix + "U"] = up
        cells[prefix + "L"] = left_val
        cells[prefix + "R"] = right_val
        stages.append({"sum": target, "center": center})
    if not _are_cells_in_bounds(cells, 1000):
        return {}
    var missing: String = _choose_missing(["s3_C", "s3_U", "s3_L", "s3_R"], ["s3_C"], 0.75)
    return _build_puzzle(cells, "L3-6", missing, {"structure": "progressive_shapes", "base_sum": base_sum, "delta": delta, "stages": stages})

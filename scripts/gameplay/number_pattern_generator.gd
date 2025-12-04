extends Node
class_name NumberPatternGenerator

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
            {"id": "L1-6", "fn": Callable(self, "_template_l1_6")},
            {"id": "L1-7", "fn": Callable(self, "_template_l1_7")},
            {"id": "L1-8", "fn": Callable(self, "_template_l1_8")}
        ],
        "medium": [
            {"id": "L2-1", "fn": Callable(self, "_template_l2_1")},
            {"id": "L2-2", "fn": Callable(self, "_template_l2_2")},
            {"id": "L2-3", "fn": Callable(self, "_template_l2_3")},
            {"id": "L2-4", "fn": Callable(self, "_template_l2_4")},
            {"id": "L2-5", "fn": Callable(self, "_template_l2_5")},
            {"id": "L2-6", "fn": Callable(self, "_template_l2_6")},
            {"id": "L2-7", "fn": Callable(self, "_template_l2_7")},
            {"id": "L2-8", "fn": Callable(self, "_template_l2_8")}
        ],
        "hard": [
            {"id": "L3-1", "fn": Callable(self, "_template_l3_1")},
            {"id": "L3-2", "fn": Callable(self, "_template_l3_2")},
            {"id": "L3-3", "fn": Callable(self, "_template_l3_3")},
            {"id": "L3-4", "fn": Callable(self, "_template_l3_4")},
            {"id": "L3-5", "fn": Callable(self, "_template_l3_5")},
            {"id": "L3-6", "fn": Callable(self, "_template_l3_6")},
            {"id": "L3-7", "fn": Callable(self, "_template_l3_7")},
            {"id": "L3-8", "fn": Callable(self, "_template_l3_8")}
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

func _build_puzzle(sequence: Array, template_id: String, missing_index: int, metadata: Dictionary = {}) -> Dictionary:
    if missing_index < 0 or missing_index >= sequence.size():
        return {}
    var display := sequence.duplicate()
    display[missing_index] = PLACEHOLDER
    return {
        "template_id": template_id,
        "sequence": sequence,
        "display": display,
        "missing_index": missing_index,
        "answer": sequence[missing_index],
        "metadata": metadata
    }

func _select_missing(count: int, prefer_last: bool = true, middle_candidates: Array = [], prefer_last_weight: float = 0.75) -> int:
    if prefer_last and (middle_candidates.is_empty() or rng.randf() < prefer_last_weight):
        return count - 1
    if middle_candidates.is_empty():
        return count - 1
    return middle_candidates[rng.randi_range(0, middle_candidates.size() - 1)]

func _sequence_in_bounds(values: Array, max_value: int, min_value: int = 0) -> bool:
    for v in values:
        if v < min_value or v > max_value:
            return false
    return true

func _template_l1_1() -> Dictionary:
    var d: int = rng.randi_range(1, 5)
    var a1: int = rng.randi_range(0, 30)
    var seq: Array[int] = []
    for i in range(5):
        seq.append(a1 + i * d)
    if not _sequence_in_bounds(seq, 50):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.7)
    return _build_puzzle(seq, "L1-1", missing, {"d": d, "a1": a1})

func _template_l1_2() -> Dictionary:
    var d: int = rng.randi_range(1, 5)
    var a1: int = rng.randi_range(d * 4, 50)
    var seq: Array[int] = []
    for i in range(5):
        seq.append(a1 - i * d)
    if not _sequence_in_bounds(seq, 50):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.7)
    return _build_puzzle(seq, "L1-2", missing, {"d": d, "a1": a1})

func _template_l1_3() -> Dictionary:
    var a1_options := [0, 10, 20]
    var a1: int = a1_options[rng.randi_range(0, a1_options.size() - 1)]
    var seq: Array[int] = []
    for i in range(5):
        seq.append(a1 + i * 10)
    if not _sequence_in_bounds(seq, 60):
        return {}
    var missing: int = _select_missing(seq.size(), true, [], 0.9)
    return _build_puzzle(seq, "L1-3", missing, {"a1": a1, "d": 10})

func _template_l1_4() -> Dictionary:
    var a1: int = rng.randi_range(1, 5)
    var seq: Array[int] = []
    for i in range(5):
        seq.append(a1 * int(pow(2, i)))
    if not _sequence_in_bounds(seq, 100):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.8)
    return _build_puzzle(seq, "L1-4", missing, {"a1": a1, "q": 2})

func _template_l1_5() -> Dictionary:
    var k: int = rng.randi_range(3, 6)
    var a1: int = int(pow(2, k))
    var seq: Array[int] = []
    for i in range(5):
        seq.append(a1 / int(pow(2, i)))
    if not _sequence_in_bounds(seq, 100):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.8)
    return _build_puzzle(seq, "L1-5", missing, {"k": k, "a1": a1})

func _template_l1_6() -> Dictionary:
    var a1: int = rng.randi_range(0, 10)
    var seq: Array[int] = [a1]
    var diff: int = 1
    while seq.size() < 6:
        seq.append(seq.back() + diff)
        diff += 1
    if not _sequence_in_bounds(seq, 60):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.65)
    return _build_puzzle(seq, "L1-6", missing, {"a1": a1})

func _template_l1_7() -> Dictionary:
    var a: int = rng.randi_range(1, 3)
    var b_options := [4, 5, 6]
    var b: int = b_options[rng.randi_range(0, b_options.size() - 1)]
    if b <= a:
        return {}
    var a1: int = rng.randi_range(0, 20)
    var seq: Array[int] = [a1]
    var deltas := [a, a, b]
    while seq.size() < 7:
        var delta: int = deltas[(seq.size() - 1) % deltas.size()]
        seq.append(seq.back() + delta)
    if not _sequence_in_bounds(seq, 100):
        return {}
    var missing: int = _select_missing(seq.size(), true, [], 0.75)
    return _build_puzzle(seq, "L1-7", missing, {"a": a, "b": b, "a1": a1})

func _template_l1_8() -> Dictionary:
    var a1: int = rng.randi_range(1, 20)
    var d: int = rng.randi_range(1, 3)
    var c: int = rng.randi_range(1, 9)
    var seq: Array[int] = []
    for i in range(6):
        if i % 2 == 0:
            seq.append(a1 + (i / 2) * d)
        else:
            seq.append(c)
    if not _sequence_in_bounds(seq, 100):
        return {}
    var missing: int = _select_missing(seq.size(), false, [4, 5], 0.5)
    return _build_puzzle(seq, "L1-8", missing, {"a1": a1, "d": d, "c": c})

func _template_l2_1() -> Dictionary:
    var a1: int = rng.randi_range(0, 20)
    var d0: int = rng.randi_range(1, 3)
    var seq: Array[int] = [a1]
    var delta: int = d0
    while seq.size() < 6:
        seq.append(seq.back() + delta)
        delta += 2
    if not _sequence_in_bounds(seq, 200):
        return {}
    var missing: int = _select_missing(seq.size(), true, [3], 0.7)
    return _build_puzzle(seq, "L2-1", missing, {"a1": a1, "d0": d0})

func _template_l2_2() -> Dictionary:
    var a1: int = rng.randi_range(0, 20)
    var d1: int = rng.randi_range(1, 3)
    var b1: int = rng.randi_range(0, 20)
    var d2: int = rng.randi_range(1, 3)
    if a1 == b1 and d1 == d2:
        return {}
    var seq: Array[int] = []
    for i in range(6):
        if i % 2 == 0:
            seq.append(a1 + (i / 2) * d1)
        else:
            seq.append(b1 + (i / 2) * d2)
    if not _sequence_in_bounds(seq, 200):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.65)
    return _build_puzzle(seq, "L2-2", missing, {"a1": a1, "d1": d1, "b1": b1, "d2": d2})

func _template_l2_3() -> Dictionary:
    var k: int = rng.randi_range(1, 3)
    var seq: Array[int] = []
    for i in range(5):
        var term: int = int(pow(k + i, 2))
        seq.append(term)
    if not _sequence_in_bounds(seq, 200):
        return {}
    var missing: int = _select_missing(seq.size(), true, [], 0.85)
    return _build_puzzle(seq, "L2-3", missing, {"k": k})

func _template_l2_4() -> Dictionary:
    var k: int = rng.randi_range(1, 3)
    var c_candidates := [-3, -2, -1, 1, 2, 3]
    var c: int = c_candidates[rng.randi_range(0, c_candidates.size() - 1)]
    var seq: Array[int] = []
    for i in range(5):
        var term: int = int(pow(k + i, 2)) + c
        seq.append(term)
    if not _sequence_in_bounds(seq, 200, 0):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2], 0.7)
    return _build_puzzle(seq, "L2-4", missing, {"k": k, "c": c})

func _template_l2_5() -> Dictionary:
    var a1: int = rng.randi_range(1, 5)
    var a2: int = rng.randi_range(1, 5)
    var seq: Array[int] = [a1, a2]
    while seq.size() < 6:
        seq.append(seq[-1] + seq[-2])
    if not _sequence_in_bounds(seq, 200):
        return {}
    var missing: int = _select_missing(seq.size(), true, [3], 0.7)
    return _build_puzzle(seq, "L2-5", missing, {"a1": a1, "a2": a2})

func _template_l2_6() -> Dictionary:
    var a: int = rng.randi_range(1, 3)
    var b: int = rng.randi_range(4, 6)
    var a1: int = rng.randi_range(0, 30)
    var seq: Array[int] = [a1]
    var deltas := [a, b]
    while seq.size() < 6:
        var delta: int = deltas[(seq.size() - 1) % deltas.size()]
        seq.append(seq.back() + delta)
    if not _sequence_in_bounds(seq, 200):
        return {}
    var missing: int = _select_missing(seq.size(), true, [2, 3], 0.7)
    return _build_puzzle(seq, "L2-6", missing, {"a1": a1, "a": a, "b": b})

func _template_l2_7() -> Dictionary:
    var a1: int = rng.randi_range(1, 9)
    var a2: int = rng.randi_range(1, 9)
    var c_candidates := [-3, -2, -1, 1, 2, 3]
    var c: int = c_candidates[rng.randi_range(0, c_candidates.size() - 1)]
    var seq: Array[int] = [a1, a2]
    while seq.size() < 6:
        seq.append(seq[-1] + seq[-2] + c)
    if not _sequence_in_bounds(seq, 200):
        return {}
    var missing: int = _select_missing(seq.size(), true, [3], 0.65)
    return _build_puzzle(seq, "L2-7", missing, {"a1": a1, "a2": a2, "c": c})

func _template_l2_8() -> Dictionary:
    var a1: int = rng.randi_range(1, 9)
    var k: int = rng.randi_range(2, 3)
    var c_candidates := [1, 2, 3, -1]
    var c: int = c_candidates[rng.randi_range(0, c_candidates.size() - 1)]
    var seq: Array[int] = [a1]
    while seq.size() < 5:
        seq.append(seq.back() * k + c)
        if seq.back() > 200:
            return {}
    var missing: int = _select_missing(seq.size(), true, [3], 0.7)
    return _build_puzzle(seq, "L2-8", missing, {"a1": a1, "k": k, "c": c})

func _template_l3_1() -> Dictionary:
    var a1: int = rng.randi_range(0, 50)
    var d0: int = rng.randi_range(2, 5)
    var step: int = rng.randi_range(1, 2)
    var seq: Array[int] = [a1]
    var delta: int = d0
    while seq.size() < 7:
        seq.append(seq.back() + delta)
        delta += step
    if not _sequence_in_bounds(seq, 1000):
        return {}
    var missing: int = _select_missing(seq.size(), true, [5], 0.65)
    return _build_puzzle(seq, "L3-1", missing, {"a1": a1, "d0": d0, "step": step})

func _template_l3_2() -> Dictionary:
    var x1: int = rng.randi_range(1, 30)
    var dx: int = rng.randi_range(1, 5)
    var y1: int = rng.randi_range(1, 4)
    var q: int = rng.randi_range(2, 3)
    var seq: Array[int] = []
    for i in range(7):
        if i % 2 == 0:
            seq.append(x1 + (i / 2) * dx)
        else:
            seq.append(y1 * int(pow(q, i / 2)))
    if not _sequence_in_bounds(seq, 1000):
        return {}
    var missing: int = _select_missing(seq.size(), true, [4], 0.65)
    return _build_puzzle(seq, "L3-2", missing, {"x1": x1, "dx": dx, "y1": y1, "q": q})

func _template_l3_3() -> Dictionary:
    var x1: int = rng.randi_range(1, 25)
    var dx: int = rng.randi_range(1, 5)
    var y1: int = rng.randi_range(1, 25)
    var dy: int = rng.randi_range(1, 5)
    if dx == dy and abs(x1 - y1) <= 1:
        return {}
    var seq: Array[int] = []
    for i in range(7):
        if i % 2 == 0:
            seq.append(x1 + (i / 2) * dx)
        else:
            seq.append(y1 + (i / 2) * dy)
    if not _sequence_in_bounds(seq, 1000):
        return {}
    var missing: int = _select_missing(seq.size(), true, [4], 0.65)
    return _build_puzzle(seq, "L3-3", missing, {"x1": x1, "dx": dx, "y1": y1, "dy": dy})

func _template_l3_4() -> Dictionary:
    var a1: int = rng.randi_range(1, 9)
    var a2: int = rng.randi_range(1, 9)
    var c_candidates: Array[int] = [-5, -4, -3, -2, -1, 1, 2, 3, 4, 5]
    var c: int = c_candidates[rng.randi_range(0, c_candidates.size() - 1)]
    var seq: Array[int] = [a1, a2]
    while seq.size() < 7:
        var next: int = seq[-1] + seq[-2] + c
        if next > 1000:
            return {}
        seq.append(next)
    if not _sequence_in_bounds(seq, 1000, 0):
        return {}
    var missing: int = _select_missing(seq.size(), true, [5], 0.6)
    return _build_puzzle(seq, "L3-4", missing, {"a1": a1, "a2": a2, "c": c})

func _template_l3_5() -> Dictionary:
    var a_options := [1, 2]
    var a: int = a_options[rng.randi_range(0, a_options.size() - 1)]
    var b: int = rng.randi_range(-2, 3)
    var c: int = rng.randi_range(0, 5)
    var start_n: int = rng.randi_range(1, 2)
    var seq: Array[int] = []
    for i in range(7):
        var n_val: int = start_n + i
        var term: int = a * n_val * n_val + b * n_val + c
        seq.append(term)
    if not _sequence_in_bounds(seq, 1000, 0):
        return {}
    var missing: int = _select_missing(seq.size(), true, [4], 0.65)
    return _build_puzzle(seq, "L3-5", missing, {"a": a, "b": b, "c": c, "start_n": start_n})

func _template_l3_6() -> Dictionary:
    var a1: int = rng.randi_range(1, 9)
    var k: int = rng.randi_range(2, 3)
    var m: int = rng.randi_range(1, 5)
    var sign: int = rng.randf() < 0.5 ? 1 : -1
    var seq: Array[int] = [a1]
    while seq.size() < 6:
        var next: int = seq.back() * k + sign * m
        if next < 0 or next > 1000:
            return {}
        seq.append(next)
    var missing: int = _select_missing(seq.size(), true, [3], 0.65)
    return _build_puzzle(seq, "L3-6", missing, {"a1": a1, "k": k, "m": m, "sign": sign})

func _template_l3_7() -> Dictionary:
    var a1: int = rng.randi_range(1, 9)
    var add: int = rng.randi_range(1, 5)
    var k: int = rng.randi_range(2, 3)
    var seq: Array[int] = [a1]
    var toggle_add := true
    while seq.size() < 7:
        var next: int = toggle_add ? seq.back() + add : seq.back() * k
        toggle_add = not toggle_add
        if next > 1000:
            return {}
        seq.append(next)
    var missing: int = _select_missing(seq.size(), true, [4], 0.65)
    return _build_puzzle(seq, "L3-7", missing, {"a1": a1, "add": add, "k": k})

func _template_l3_8() -> Dictionary:
    if rng.randf() < 0.5:
        var base: int = rng.randi_range(2, 3)
        var seq: Array[int] = []
        for i in range(6):
            seq.append(int(pow(base, i)))
        if not _sequence_in_bounds(seq, 1000):
            return {}
        var missing: int = _select_missing(seq.size(), true, [3], 0.7)
        return _build_puzzle(seq, "L3-8", missing, {"mode": "pure_power", "base": base})
    var start_n: int = rng.randi_range(1, 2)
    var seq_mix: Array[int] = []
    for i in range(6):
        var n_val: int = start_n + i
        if i % 2 == 0:
            seq_mix.append(n_val * n_val)
        else:
            seq_mix.append(n_val * n_val * n_val)
    if not _sequence_in_bounds(seq_mix, 1000):
        return {}
    var missing_mix: int = _select_missing(seq_mix.size(), true, [3], 0.65)
    return _build_puzzle(seq_mix, "L3-8", missing_mix, {"mode": "square_cube", "start_n": start_n})

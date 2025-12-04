extends Node
class_name LetterPatternGenerator

const PLACEHOLDER := "?"
const ALPHABET_COUNT := 26

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
    for _i in range(64):
        var choice: Dictionary = bucket[rng.randi_range(0, bucket.size() - 1)]
        var result: Dictionary = choice.fn.call() as Dictionary
        if not result.is_empty():
            result["difficulty"] = difficulty
            return result
    return {}

func _build_puzzle(sequence: Array, template_id: String, missing_index: int, metadata: Dictionary = {}, answer_override = null) -> Dictionary:
    if missing_index < 0 or missing_index >= sequence.size():
        return {}
    var display := sequence.duplicate()
    display[missing_index] = PLACEHOLDER
    var answer_value = answer_override if answer_override != null else sequence[missing_index]
    return {
        "template_id": template_id,
        "sequence": sequence,
        "display": display,
        "missing_index": missing_index,
        "answer": answer_value,
        "metadata": metadata
    }

func _build_cells_puzzle(cells: Dictionary, template_id: String, missing_key: String, metadata: Dictionary = {}) -> Dictionary:
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

func _select_missing(count: int, prefer_last: bool = true, middle_candidates: Array = [], prefer_last_weight: float = 0.75) -> int:
    if prefer_last and (middle_candidates.is_empty() or rng.randf() < prefer_last_weight):
        return count - 1
    if middle_candidates.is_empty():
        return count - 1
    return middle_candidates[rng.randi_range(0, middle_candidates.size() - 1)]

func _idx_to_char(idx: int) -> String:
    if idx < 1 or idx > ALPHABET_COUNT:
        return ""
    return char("A".unicode_at(0) + idx - 1)

func _char_to_idx(letter: String) -> int:
    if letter.is_empty():
        return 0
    return letter.unicode_at(0) - "A".unicode_at(0) + 1

func _ensure_indices_in_range(indices: Array, max_idx: int = ALPHABET_COUNT) -> bool:
    for idx in indices:
        if idx < 1 or idx > max_idx:
            return false
    return true

func _template_l1_1() -> Dictionary:
    var length: int = rng.randi_range(4, 5)
    var max_start: int = ALPHABET_COUNT - length + 1
    var start_idx: int = rng.randi_range(1, max_start)
    var sequence: Array[String] = []
    for i in range(length):
        sequence.append(_idx_to_char(start_idx + i))
    return _build_puzzle(sequence, "L1-1", sequence.size() - 1, {"start": start_idx, "length": length})

func _template_l1_2() -> Dictionary:
    var length: int = rng.randi_range(4, 5)
    var start_idx: int = rng.randi_range(length, ALPHABET_COUNT)
    var sequence: Array[String] = []
    for i in range(length):
        sequence.append(_idx_to_char(start_idx - i))
    return _build_puzzle(sequence, "L1-2", sequence.size() - 1, {"start": start_idx, "length": length})

func _template_l1_3() -> Dictionary:
    var step: int = [2, 3][rng.randi_range(0, 1)]
    var length: int = rng.randi_range(4, 5)
    var max_start: int = ALPHABET_COUNT - (length - 1) * step
    var start_idx: int = rng.randi_range(1, max_start)
    var sequence: Array[String] = []
    for i in range(length):
        sequence.append(_idx_to_char(start_idx + i * step))
    var missing: int = _select_missing(sequence.size(), true, [1, 2], 0.65)
    return _build_puzzle(sequence, "L1-3", missing, {"start": start_idx, "step": step, "length": length})

func _template_l1_4() -> Dictionary:
    var p: int = rng.randi_range(1, ALPHABET_COUNT)
    var q: int = rng.randi_range(1, ALPHABET_COUNT)
    if p == q:
        return {}
    var length: int = rng.randi_range(5, 6)
    var sequence: Array[String] = []
    for i in range(length):
        var char_idx: int = p if i % 2 == 0 else q
        sequence.append(_idx_to_char(char_idx))
    return _build_puzzle(sequence, "L1-4", sequence.size() - 1, {"p": p, "q": q, "length": length})

func _template_l1_5() -> Dictionary:
    var length: int = rng.randi_range(4, 5)
    var step: int = [1, 2][rng.randi_range(0, 1)]
    var max_start: int = ALPHABET_COUNT - (length - 1) * step
    var start_num: int = rng.randi_range(1, max_start)
    var sequence: Array[int] = []
    for i in range(length):
        sequence.append(start_num + i * step)
    var missing: int = sequence.size() - 1
    var answer_letter: String = _idx_to_char(sequence[missing])
    return _build_puzzle(sequence, "L1-5", missing, {"start": start_num, "step": step, "length": length, "mapping": "A=1"}, answer_letter)

func _template_l1_6() -> Dictionary:
    var length: int = rng.randi_range(4, 5)
    var step: int = rng.randi_range(1, 3)
    var max_start: int = ALPHABET_COUNT - (length - 1) * step
    var start_idx: int = rng.randi_range(1, max_start)
    var letters: Array[String] = []
    for i in range(length):
        letters.append(_idx_to_char(start_idx + i * step))
    var missing: int = letters.size() - 1
    var answer_number: int = _char_to_idx(letters[missing])
    return _build_puzzle(letters, "L1-6", missing, {"start": start_idx, "step": step, "length": length, "answer_type": "index"}, answer_number)

func _template_l2_1() -> Dictionary:
    var step: int = rng.randi_range(2, 4)
    var length: int = 5
    var max_start: int = ALPHABET_COUNT - (length - 1) * step
    var start_idx: int = rng.randi_range(1, max_start)
    var sequence: Array[String] = []
    for i in range(length):
        sequence.append(_idx_to_char(start_idx + i * step))
    var missing: int = _select_missing(sequence.size(), false, [1, 2, 3], 0.4)
    return _build_puzzle(sequence, "L2-1", missing, {"start": start_idx, "step": step, "length": length})

func _template_l2_2() -> Dictionary:
    var length: int = rng.randi_range(6, 7)
    var p1: int = rng.randi_range(1, 20)
    var d1: int = rng.randi_range(1, 2)
    var p2: int = rng.randi_range(1, 20)
    var d2: int = rng.randi_range(1, 2)
    if p1 == p2 and d1 == d2:
        return {}
    var sequence: Array[String] = []
    for i in range(length):
        var idx_val: int = 0
        if i % 2 == 0:
            idx_val = p1 + (i / 2) * d1
        else:
            idx_val = p2 + (i / 2) * d2
        sequence.append(_idx_to_char(idx_val))
    var idx_values: Array[int] = []
    for item in sequence:
        idx_values.append(_char_to_idx(item))
    if not _ensure_indices_in_range(idx_values):
        return {}
    var missing: int = _select_missing(sequence.size(), true, [length - 2], 0.6)
    return _build_puzzle(sequence, "L2-2", missing, {"p1": p1, "p2": p2, "d1": d1, "d2": d2, "length": length})

func _template_l2_3() -> Dictionary:
    var length: int = rng.randi_range(4, 5)
    var p: int = rng.randi_range(1, 20)
    var dL: int = rng.randi_range(1, 2)
    var n0: int = rng.randi_range(1, 20)
    var dN: int = rng.randi_range(1, 3)
    var sequence: Array[String] = []
    for i in range(length):
        var letter := _idx_to_char(p + i * dL)
        var num := n0 + i * dN
        if num > 100:
            return {}
        sequence.append("%s%s" % [letter, num])
    var indices: Array[int] = []
    for entry in sequence:
        indices.append(_char_to_idx(String(entry).substr(0, 1)))
    if not _ensure_indices_in_range(indices):
        return {}
    var missing: int = sequence.size() - 1
    return _build_puzzle(sequence, "L2-3", missing, {"p": p, "dL": dL, "n0": n0, "dN": dN, "length": length})

func _template_l2_4() -> Dictionary:
    var shift: int = rng.randi_range(1, 3)
    var length: int = 4
    var start_idx: int = rng.randi_range(1, ALPHABET_COUNT - shift - (length - 1))
    var base_letters: Array[String] = []
    var sequence: Array[String] = []
    for i in range(length):
        var base_idx: int = start_idx + i
        var cipher_idx: int = base_idx + shift
        base_letters.append(_idx_to_char(base_idx))
        var cipher_char: String = PLACEHOLDER if i == length - 1 else _idx_to_char(cipher_idx)
        sequence.append("%s→%s" % [_idx_to_char(base_idx), cipher_char])
    var answer: String = _idx_to_char(start_idx + (length - 1) + shift)
    return {
        "template_id": "L2-4",
        "sequence": sequence,
        "display": sequence,
        "missing_index": length - 1,
        "answer": answer,
        "metadata": {"shift": shift, "base_letters": base_letters, "length": length}
    }

func _template_l2_5() -> Dictionary:
    var length: int = 4
    var step: int = rng.randi_range(1, 3)
    var max_start: int = ALPHABET_COUNT - (length - 1) * step
    var start_num: int = rng.randi_range(1, max_start)
    var sequence: Array[int] = []
    for i in range(length):
        sequence.append(start_num + i * step)
    var missing: int = sequence.size() - 1
    var answer_letter: String = _idx_to_char(sequence[missing])
    return _build_puzzle(sequence, "L2-5", missing, {"start": start_num, "step": step, "length": length}, answer_letter)

func _template_l2_6() -> Dictionary:
    var length: int = 4
    var step: int = rng.randi_range(1, 2)
    var max_start: int = ALPHABET_COUNT - (length - 1) * step
    var start_idx: int = rng.randi_range(1, max_start)
    var letters: Array[String] = []
    var display: Array[String] = []
    for i in range(length):
        var letter := _idx_to_char(start_idx + i * step)
        letters.append(letter)
        display.append("%s(%d)" % [letter, _char_to_idx(letter)])
    var missing: int = _select_missing(length, false, [1, 2], 0.5)
    display[missing] = PLACEHOLDER
    return {
        "template_id": "L2-6",
        "sequence": letters,
        "display": display,
        "missing_index": missing,
        "answer": letters[missing],
        "metadata": {"start": start_idx, "step": step, "length": length, "paired": true}
    }

func _template_l3_1() -> Dictionary:
    var length: int = 5
    var start_idx: int = rng.randi_range(1, 15)
    var deltas := [1, 2, 3, 4]
    var indices: Array[int] = [start_idx]
    for delta in deltas:
        indices.append(indices.back() + delta)
    if not _ensure_indices_in_range(indices):
        return {}
    var sequence: Array[String] = []
    for idx in indices:
        sequence.append(_idx_to_char(idx))
    var missing: int = _select_missing(sequence.size(), true, [2, 3], 0.6)
    return _build_puzzle(sequence, "L3-1", missing, {"start": start_idx, "deltas": deltas})

func _template_l3_2() -> Dictionary:
    var length: int = 4
    var letter_base: int = rng.randi_range(1, 10)
    var number_base: int = rng.randi_range(1, 10)
    var letter_delta_start: int = rng.randi_range(1, 2)
    var number_delta_start: int = rng.randi_range(2, 3)
    var letter_deltas: Array[int] = [letter_delta_start, letter_delta_start + 1, letter_delta_start + 2]
    var number_deltas: Array[int] = [number_delta_start, number_delta_start + 1, number_delta_start + 2]
    var letters: Array[int] = [letter_base]
    var numbers: Array[int] = [number_base]
    for i in range(1, length):
        letters.append(letters.back() + letter_deltas[i - 1])
        numbers.append(numbers.back() + number_deltas[i - 1])
    if not _ensure_indices_in_range(letters) or numbers.back() > 100:
        return {}
    var sequence: Array[String] = []
    for i in range(length):
        sequence.append("%s%d" % [_idx_to_char(letters[i]), numbers[i]])
    var missing: int = sequence.size() - 1
    return _build_puzzle(sequence, "L3-2", missing, {"letters": letters, "numbers": numbers, "letter_deltas": letter_deltas, "number_deltas": number_deltas})

func _template_l3_3() -> Dictionary:
    var length: int = 6
    var add_a: int = rng.randi_range(1, 2)
    var add_b: int = rng.randi_range(2, 4)
    if add_a == add_b:
        return {}
    var start_idx: int = rng.randi_range(1, ALPHABET_COUNT - (length - 1) * max(add_a, add_b))
    var sequence: Array[String] = [_idx_to_char(start_idx)]
    var deltas := [add_a, add_b]
    while sequence.size() < length:
        var delta: int = deltas[(sequence.size() - 1) % 2]
        var next_idx: int = _char_to_idx(sequence.back()) + delta
        if next_idx > ALPHABET_COUNT:
            return {}
        sequence.append(_idx_to_char(next_idx))
    var missing: int = _select_missing(sequence.size(), true, [length - 2], 0.6)
    return _build_puzzle(sequence, "L3-3", missing, {"add_a": add_a, "add_b": add_b, "start": start_idx})

func _template_l3_4() -> Dictionary:
    var shift: int = rng.randi_range(1, 5)
    var start_idx: int = rng.randi_range(1, ALPHABET_COUNT - shift - 3)
    var base_letters: Array[String] = []
    var sequence: Array[String] = []
    for i in range(4):
        var base_idx: int = start_idx + i * 2
        var cipher_idx: int = base_idx + shift
        base_letters.append(_idx_to_char(base_idx))
        var cipher_char: String = PLACEHOLDER if i == 3 else _idx_to_char(cipher_idx)
        sequence.append("%s→%s" % [_idx_to_char(base_idx), cipher_char])
    var answer: String = _idx_to_char(_char_to_idx(base_letters.back()) + shift)
    return {
        "template_id": "L3-4",
        "sequence": sequence,
        "display": sequence,
        "missing_index": 3,
        "answer": answer,
        "metadata": {"shift": shift, "base_letters": base_letters}
    }

func _template_l3_5() -> Dictionary:
    var dH: int = rng.randi_range(1, 2)
    var dV: int = rng.randi_range(1, 2)
    var max_start: int = ALPHABET_COUNT - 2 * (dH + dV)
    if max_start < 1:
        return {}
    var start_idx: int = rng.randi_range(1, max_start)
    var cells: Dictionary = {}
    for r in range(3):
        for c in range(3):
            var idx_val: int = start_idx + c * dH + r * dV
            cells["r%sc%s" % [r + 1, c + 1]] = _idx_to_char(idx_val)
    var keys: Array = cells.keys()
    var missing_key: String = keys[rng.randi_range(0, keys.size() - 1)]
    return _build_cells_puzzle(cells, "L3-5", missing_key, {"start": start_idx, "dH": dH, "dV": dV})

func _template_l3_6() -> Dictionary:
    var relation_type: int = rng.randi_range(1, 2)
    var offset: int = 0
    if relation_type == 1:
        offset = rng.randi_range(-3, 3)
        if offset == 0:
            offset = 1
    var length: int = 4
    var start_idx: int = rng.randi_range(1, 10)
    var sequence: Array[String] = []
    for i in range(length):
        var idx_val: int = start_idx + i
        if idx_val > ALPHABET_COUNT:
            return {}
        var number_val: int = 0
        if relation_type == 1:
            number_val = idx_val + offset
        else:
            number_val = idx_val * 2
        if number_val <= 0 or number_val > 100:
            return {}
        var mapping := "%s→%s" % [_idx_to_char(idx_val), str(number_val)]
        sequence.append(mapping)
    var missing: int = sequence.size() - 1
    var answer_number: int = 0
    if relation_type == 1:
        answer_number = start_idx + missing + offset
    else:
        answer_number = (start_idx + missing) * 2
    return _build_puzzle(sequence, "L3-6", missing, {"relation": relation_type, "offset": offset, "start": start_idx}, answer_number)

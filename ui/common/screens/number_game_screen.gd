extends UIScreenBase
class_name NumberGameScreen

signal request_back

const NumberPatternGenerator := preload("res://scripts/gameplay/number_pattern_generator.gd")
const PLACEHOLDER_TEXT := "?"

var _mode: String = "numbers"
var _difficulty: String = "easy"
var _current_puzzle: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _generator: NumberPatternGenerator = NumberPatternGenerator.new()
var _allow_input: bool = true

var _template_hints := {
    "L3-1": "差值也在变大，注意第二层的等差变化",
    "L3-2": "奇数位走等差，偶数位做等比，分开观察",
    "L3-3": "两条等差交错，首项和公差都可能不同",
    "L3-4": "类似斐波那契但加了常数，前两项的和再做修正",
    "L3-5": "像 n² 的二次数列，项与项之间差值在递增",
    "L3-6": "上一项先乘再加减，数字会跳跃变大",
    "L3-7": "加法与乘法交替出现，留意周期",
    "L3-8": "可能是幂次或平方立方交替，先找出底数或指数"
}

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var sequence_label: Label = %SequenceLabel
@onready var hint_label: Label = %HintLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var settings_button: Button = %SettingsButton
@onready var back_button: Button = %BackButton
@onready var refresh_button: Button = %RefreshButton
@onready var next_button: Button = %NextButton
@onready var option_buttons: Array[Button] = [
    %Option1,
    %Option2,
    %Option3,
    %Option4
]

func _ready() -> void:
    super._ready()
    _rng.randomize()
    settings_button.pressed.connect(_on_settings_pressed)
    back_button.pressed.connect(_on_back_pressed)
    refresh_button.pressed.connect(_on_refresh_pressed)
    next_button.pressed.connect(_on_next_pressed)
    for button in option_buttons:
        button.pressed.connect(func() -> void: _on_option_selected(button))
    _update_titles()
    if _current_puzzle.is_empty():
        _load_new_puzzle()

func configure(mode: String, difficulty: String = "easy") -> void:
    _mode = mode
    _difficulty = difficulty
    _update_titles()
    _load_new_puzzle()

func _update_titles() -> void:
    title_label.text = "数字规律闯关"
    var diff_label := _difficulty_label()
    subtitle_label.text = "%s · 根据数列规律填空" % diff_label

func _load_new_puzzle() -> void:
    _allow_input = true
    _current_puzzle = _generator.generate_puzzle(_difficulty)
    if _current_puzzle.is_empty():
        sequence_label.text = "暂时没有生成题目，请重试"
        hint_label.text = ""
        feedback_label.text = ""
        _lock_options(true)
        return
    var display: Array = _current_puzzle.get("display", [])
    var sequence_texts: Array[String] = []
    for value in display:
        sequence_texts.append(str(value))
    sequence_label.text = "  ,  ".join(sequence_texts)
    var template_id: String = _current_puzzle.get("template_id", "")
    var hint_text := "题型 %s · 填写 %s" % [template_id, PLACEHOLDER_TEXT]
    var template_hint := _template_hints.get(template_id, "")
    if template_hint != "":
        hint_text += " ｜提示：%s" % template_hint
    hint_label.text = hint_text
    feedback_label.text = "请选择正确的数字"
    _apply_options(int(_current_puzzle.get("answer", 0)))

func _difficulty_label() -> String:
    match _difficulty:
        "easy":
            return "简单"
        "medium":
            return "中等"
        "hard":
            return "挑战"
        _:
            return _difficulty

func _apply_options(answer: int) -> void:
    var max_value := 120
    var delta_range := 6
    match _difficulty:
        "medium":
            max_value = 220
            delta_range = 12
        "hard":
            max_value = 1100
            delta_range = 24
    var options: Array[int] = [answer]
    while options.size() < option_buttons.size():
        var delta: int = _rng.randi_range(-delta_range, delta_range)
        if delta == 0:
            continue
        var candidate: int = clamp(answer + delta, 0, max_value)
        if options.has(candidate):
            continue
        options.append(candidate)
    options.shuffle()
    for i in range(option_buttons.size()):
        var button := option_buttons[i]
        button.text = str(options[i])
        button.disabled = false
        button.modulate = Color(1, 1, 1)
    next_button.disabled = true

func _on_option_selected(button: Button) -> void:
    if not _allow_input:
        return
    var selected_value: int = int(button.text)
    var answer: int = int(_current_puzzle.get("answer", 0))
    if selected_value == answer:
        _handle_correct(button)
    else:
        _handle_incorrect(button, answer)

func _handle_correct(button: Button) -> void:
    _allow_input = false
    feedback_label.text = "答对啦！正确答案是 %s" % str(_current_puzzle.get("answer", ""))
    feedback_label.modulate = Color(0.18, 0.6, 0.24)
    button.modulate = Color(0.18, 0.6, 0.24)
    _lock_options(true)
    next_button.disabled = false

func _handle_incorrect(button: Button, answer: int) -> void:
    feedback_label.text = "再想想：%s 不是正确答案" % str(button.text)
    feedback_label.modulate = Color(0.85, 0.24, 0.24)
    button.disabled = true
    button.modulate = Color(0.7, 0.7, 0.7)

func _lock_options(state: bool) -> void:
    for btn in option_buttons:
        btn.disabled = state

func _on_refresh_pressed() -> void:
    _load_new_puzzle()

func _on_next_pressed() -> void:
    _load_new_puzzle()

func _on_back_pressed() -> void:
    request_back.emit()

func _on_settings_pressed() -> void:
    request_open_settings.emit()

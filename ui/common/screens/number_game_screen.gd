extends "res://scripts/systems/ui_screen_base.gd"
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
var _font_scale: float = 2.0
var _font_targets: Array[CanvasItem] = []
var _base_font_sizes: Dictionary = {}

var _template_rules := {
        "L1-1": "等差递增：每次加同一个数",
        "L1-2": "等差递减：每次减同一个数",
        "L1-3": "整十跳数：公差固定为 10",
        "L1-4": "等比 ×2：每项都是上一项的 2 倍",
        "L1-5": "等比 ÷2：每次减半，保持整数",
        "L1-6": "差值递增：+1,+2,+3… 台阶式增长",
        "L1-7": "周期加法：按 +a,+a,+b 循环",
        "L1-8": "奇偶分轨：奇数位等差，偶数位常数",
        "L2-1": "变差数列：差值本身成等差 (+3,+5,+7…)",
        "L2-2": "奇偶双等差：奇数位和偶数位各自等差",
        "L2-3": "平方序列：按 n² 递增",
        "L2-4": "平方变形：n² 加或减固定常数",
        "L2-5": "斐波那契：后一项等于前两项之和",
        "L2-6": "交替乘加：乘以 q 再加/减 c 周期出现",
        "L2-7": "平方间隔：等差插入两个平方或立方",
        "L2-8": "偶增奇减：奇偶位相反方向变动",
        "L3-1": "双层等差：差值也在递增",
        "L3-2": "奇偶混合：奇数位等差，偶数位等比",
        "L3-3": "两条等差交错，首项与公差可不同",
        "L3-4": "斐波那契变体：前两项之和再加常数",
        "L3-5": "二次序列：类似 n²，差值递增",
        "L3-6": "乘加跃迁：上一项先乘再加/减",
        "L3-7": "加法与乘法交替，留意周期",
        "L3-8": "幂次/平方交替：底数或指数在变化",
}

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
@onready var rule_button: Button = %RuleButton
@onready var rule_popup: PopupPanel = %RulePopup
@onready var rule_label: Label = %RuleLabel
@onready var settings_button: Button = %SettingsButton
@onready var settings_popup: PopupPanel = %SettingsPopup
@onready var close_settings_button: Button = %CloseSettingsButton
@onready var font_slider: HSlider = %FontSlider
@onready var font_value_label: Label = %FontValueLabel
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
    _wire_button(settings_button, Callable(self, "_on_settings_pressed"))
    _wire_button(back_button, Callable(self, "_on_back_pressed"))
    _wire_button(refresh_button, Callable(self, "_on_refresh_pressed"))
    _wire_button(next_button, Callable(self, "_on_next_pressed"))
    _wire_button(close_settings_button, Callable(settings_popup, "hide"))
    _wire_button(rule_button, Callable(self, "_on_rule_pressed"))
    for button in option_buttons:
        _wire_button(button, Callable(self, "_on_option_selected"), button)
    _init_font_scaling()
    _update_titles()
    if _current_puzzle.is_empty():
        _load_new_puzzle()
func _wire_button(button: Button, callable: Callable, argument = null) -> void:
    if button == null:
        push_warning("Button not found for %s" % callable.get_method())
        return
    if argument == null:
        button.pressed.connect(callable)
    else:
        button.pressed.connect(func() -> void: callable.call(argument))
func configure(mode: String, difficulty: String = "easy") -> void:
    _mode = mode
    _difficulty = difficulty
    # When invoked before the scene is ready, delay UI updates until _ready runs.
    if not is_node_ready():
        return
    _update_titles()
    _load_new_puzzle()

func _update_titles() -> void:
    title_label.text = "数字规律闯关"
    var diff_label := _difficulty_label()
    subtitle_label.text = "%s · 根据数列规律填空" % diff_label

func _init_font_scaling() -> void:
    _font_targets = [
            title_label,
            subtitle_label,
            sequence_label,
            hint_label,
            feedback_label,
            rule_button,
            rule_label,
            settings_button,
            close_settings_button,
            back_button,
            refresh_button,
            next_button,
    ]
    _font_targets.append_array(_valid_option_buttons())
    for node in _font_targets:
            if node == null:
                    continue
            var base_size: int = node.get_theme_font_size("font_size")
            _base_font_sizes[node.get_instance_id()] = base_size
    _set_font_scale(_font_scale)
    if font_slider != null:
            font_slider.min_value = 1.0
            font_slider.max_value = 3.0
            font_slider.step = 0.1
            font_slider.value = _font_scale
            font_slider.value_changed.connect(_on_font_slider_changed)
    _update_font_value_label()

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
    sequence_label.text = _format_display(display)
    var template_id: String = _current_puzzle.get("template_id", "")
    var hint_text := "题型 %s · 填写 %s" % [template_id, PLACEHOLDER_TEXT]
    var template_hint: String = _template_hints.get(template_id, "") as String
    if template_hint != "":
        hint_text += " ｜提示：%s" % template_hint
    hint_label.text = hint_text
    feedback_label.text = "请选择正确的数字"
    _sync_rule_hint(template_id)
    rule_button.visible = false
    if rule_popup != null:
            rule_popup.hide()
    _apply_options(int(_current_puzzle.get("answer", 0)))

func _valid_option_buttons() -> Array[Button]:
    var buttons: Array[Button] = []
    for btn in option_buttons:
        if btn != null:
            buttons.append(btn)
    return buttons

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
        var buttons := _valid_option_buttons()
        while options.size() < buttons.size():
                var delta: int = _rng.randi_range(-delta_range, delta_range)
                if delta == 0:
                        continue
                var candidate: int = clamp(answer + delta, 0, max_value)
                if options.has(candidate):
                        continue
                options.append(candidate)
        options.shuffle()
        for i in range(buttons.size()):
                var button := buttons[i]
                button.text = str(options[i])
                button.disabled = false
                button.modulate = Color(1, 1, 1)
        if next_button != null:
                next_button.disabled = true

func _format_display(values: Array) -> String:
        var sequence_texts: Array[String] = []
        for value in values:
                var text_value := PLACEHOLDER_TEXT
                if value != null:
                        text_value = str(value)
                        if text_value.is_empty():
                                text_value = PLACEHOLDER_TEXT
                sequence_texts.append(text_value)
        if sequence_texts.is_empty():
                return "正在生成题目…"
        return "  ,  ".join(sequence_texts)

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
        _show_rule_button()

func _lock_options(state: bool) -> void:
        for btn in _valid_option_buttons():
                btn.disabled = state

func _on_refresh_pressed() -> void:
    _load_new_puzzle()

func _on_next_pressed() -> void:
    _load_new_puzzle()

func _on_back_pressed() -> void:
    request_back.emit()

func _on_settings_pressed() -> void:
        if settings_popup != null:
                settings_popup.popup_centered()

func _on_rule_pressed() -> void:
        _show_rule_popup()

func _on_font_slider_changed(value: float) -> void:
        _set_font_scale(value)

func _set_font_scale(value: float) -> void:
        _font_scale = value
        for node in _font_targets:
                if node == null:
                        continue
                var base_size: int = _base_font_sizes.get(node.get_instance_id(), node.get_theme_font_size("font_size"))
                var scaled: int = int(round(base_size * _font_scale))
                node.add_theme_font_size_override("font_size", scaled)
        _update_font_value_label()

func _sync_rule_hint(template_id: String) -> void:
        var rule_text: String = _template_rules.get(template_id, "暂无规则说明")
        if rule_label != null:
                rule_label.text = rule_text

func _show_rule_button() -> void:
        if rule_button != null:
                rule_button.visible = true
        _show_rule_popup()

func _show_rule_popup() -> void:
        if rule_popup != null:
                rule_popup.popup_centered()

func _update_font_value_label() -> void:
        if font_value_label != null:
                font_value_label.text = "%.1fx" % _font_scale

extends "res://scripts/systems/ui_screen_base.gd"
class_name NumberGameScreen

signal request_back

const AppLogger := preload("res://scripts/core/logger.gd")
const NumberPatternGenerator := preload("res://scripts/gameplay/number_pattern_generator.gd")
const ShapePatternGenerator := preload("res://scripts/gameplay/shape_pattern_generator.gd")
const LetterPatternGenerator := preload("res://scripts/gameplay/letter_pattern_generator.gd")
const PLACEHOLDER_TEXT := "?"

var _mode: String = "numbers"
var _difficulty: String = "easy"
var _current_puzzle: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _number_generator: NumberPatternGenerator = NumberPatternGenerator.new()
var _shape_generator: ShapePatternGenerator
var _letter_generator: LetterPatternGenerator
var _generator
var _allow_input: bool = true
var _font_scale: float = 2.0
var _font_targets: Array[CanvasItem] = []
var _base_font_sizes: Dictionary = {}

var _template_rules := {
        "numbers": {
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
        },
        "shapes": {
                "L1-1": "横向三格：右格等于左格与中格之和",
                "L1-2": "竖向三格：下方等于上方两格之和",
                "L1-3": "2x2 方阵：右下角是同行两格之和",
                "L1-4": "十字结构：中心等于左右、上下和的平均",
                "L1-5": "三角三点：底边两点之和等于顶点",
                "L1-6": "两行两列：右下角 = (左上+右上) - 左下",
                "L2-1": "9 宫格：每行递增公差一致",
                "L2-2": "三角形：两底角和等于顶角",
                "L2-3": "环形：相邻两点和相等，缺口需补足",
                "L2-4": "对角线：主对角和与副对角和关联",
                "L2-5": "中心辐射：中心为四角之和的一半",
                "L2-6": "十字交叉：水平和竖直的差值相同",
                "L3-1": "魔方阵：行列对角线求和一致",
                "L3-2": "双圆交叉：交点等于相邻两点之和",
                "L3-3": "对角平衡：两条对角线加减关系固定",
                "L3-4": "三角级数：每条边按等差递增",
                "L3-5": "套娃十字：外圈和内圈保持比例",
                "L3-6": "阶梯累加：右下角由左上开始逐步加总",
        },
        "letters": {
                "L1-1": "正向字母表：按顺序递增，缺末尾",
                "L1-2": "逆向字母表：倒序递减，缺末尾",
                "L1-3": "步长递增：每步加固定间隔",
                "L1-4": "交替跳跃：步长在两值间轮换",
                "L1-5": "A=1 映射：索引递增再转字母",
                "L1-6": "字母索引：先看数字，再映射回去",
                "L2-1": "三段等差：步长提升 1 形成阶梯",
                "L2-2": "回文镜像：前半段映射到后半段",
                "L2-3": "和差组合：两前项求和或求差再编码",
                "L2-4": "三元组累加：三个一组做和运算",
                "L2-5": "交叉位移：左右位移的字母序列交错",
                "L2-6": "索引翻倍：数字位翻倍后转成字母",
                "L3-1": "阶梯凯撒：起点提升并向后平移",
                "L3-2": "双向偏移：奇偶位不同偏移量",
                "L3-3": "累加偏移：前项字母索引逐项累加",
                "L3-4": "多步凯撒：每步位移递增",
                "L3-5": "指数偏移：索引成倍增长后取字母",
                "L3-6": "多段映射：字母与数字索引混合递推",
        }
}

var _template_hints := {
        "numbers": {
                "L3-1": "差值也在变大，注意第二层的等差变化",
                "L3-2": "奇数位走等差，偶数位做等比，分开观察",
                "L3-3": "两条等差交错，首项和公差都可能不同",
                "L3-4": "类似斐波那契但加了常数，前两项的和再做修正",
                "L3-5": "像 n² 的二次数列，项与项之间差值在递增",
                "L3-6": "上一项先乘再加减，数字会跳跃变大",
                "L3-7": "加法与乘法交替出现，留意周期",
                "L3-8": "可能是幂次或平方立方交替，先找出底数或指数"
        },
        "shapes": {},
        "letters": {}
}

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var sequence_label: Label = %SequenceLabel
@onready var shape_grid: GridContainer = %ShapeGrid
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

var _shape_cells: Array[Label] = []

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
    _collect_shape_cells()
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
    var diff_label := _difficulty_label()
    match _mode:
            "shapes":
                    title_label.text = "图形数字推理"
                    subtitle_label.text = "%s · 填写缺失的图形数值" % diff_label
            "letters":
                    title_label.text = "字母规律实验室"
                    subtitle_label.text = "%s · 补全字母或编码" % diff_label
            _:
                    title_label.text = "数字规律闯关"
                    subtitle_label.text = "%s · 根据数列规律填空" % diff_label

func _init_font_scaling() -> void:
    _font_targets = [
            title_label,
            subtitle_label,
            sequence_label,
            shape_grid,
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
    _font_targets.append_array(_shape_cells)
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
    _generator = _select_generator()
    if _generator == null:
            sequence_label.text = "暂时没有生成题目，请重试"
            return
    _current_puzzle = _generator.generate_puzzle(_difficulty)
    if _current_puzzle.is_empty():
        sequence_label.text = "暂时没有生成题目，请重试"
        hint_label.text = ""
        feedback_label.text = ""
        _lock_options(true)
        return
    var display = _current_puzzle.get("display", [])
    var structure: String = _current_puzzle.get("metadata", {}).get("structure", "")
    _log_puzzle(display, _current_puzzle.get("template_id", ""), _current_puzzle.get("answer", ""), structure)
    _render_display(display, structure)
    var template_id: String = _current_puzzle.get("template_id", "")
    var hint_text := "题型 %s · 填写 %s" % [template_id, PLACEHOLDER_TEXT]
    var template_hint: String = _template_hint_for(template_id)
    if template_hint != "":
        hint_text += " ｜提示：%s" % template_hint
    hint_label.text = hint_text
    feedback_label.text = "请选择正确的答案"
    _sync_rule_hint(template_id)
    rule_button.visible = false
    if rule_popup != null:
            rule_popup.hide()
    _apply_options(_current_puzzle.get("answer", 0))

func _valid_option_buttons() -> Array[Button]:
    var buttons: Array[Button] = []
    for btn in option_buttons:
        if btn != null:
            buttons.append(btn)
    return buttons

func _collect_shape_cells() -> void:
    _shape_cells.clear()
    if shape_grid == null:
        return
    for child in shape_grid.get_children():
        if child is Label:
            var lbl: Label = child
            _shape_cells.append(lbl)

func _render_display(display, structure: String) -> void:
    var show_shapes := _mode == "shapes"
    if shape_grid != null:
        shape_grid.visible = show_shapes
    sequence_label.visible = not show_shapes
    if show_shapes:
        var drawn := _draw_shape_display(display, structure)
        if drawn:
            return
        sequence_label.visible = true
        if shape_grid != null:
            shape_grid.visible = false
    sequence_label.text = _format_display(display)

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

func _apply_options(answer) -> void:
        var buttons := _valid_option_buttons()
        if buttons.is_empty():
                return
        var options: Array = [answer]
        if answer is String:
                while options.size() < buttons.size():
                        var candidate := _random_letter_option(str(answer))
                        if options.has(candidate):
                                continue
                        options.append(candidate)
        else:
                var numeric_answer: int = int(answer)
                var max_value := 120
                var delta_range := 6
                match _difficulty:
                        "medium":
                                max_value = 220
                                delta_range = 12
                        "hard":
                                max_value = 1100
                                delta_range = 24
                while options.size() < buttons.size():
                        var delta: int = _rng.randi_range(-delta_range, delta_range)
                        if delta == 0:
                                continue
                        var candidate: int = clamp(numeric_answer + delta, 0, max_value)
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

func _format_display(values) -> String:
        if values is Dictionary:
                var keys: Array = values.keys()
                keys.sort()
                var pairs: Array[String] = []
                for key in keys:
                        var val = values.get(key, PLACEHOLDER_TEXT)
                        pairs.append("%s:%s" % [str(key), _format_value(val)])
                if pairs.is_empty():
                        return "正在生成题目…"
                return "  |  ".join(pairs)
        var sequence_texts: Array[String] = []
        if values is Array:
                for value in values:
                        sequence_texts.append(_format_value(value))
        if sequence_texts.is_empty():
                return "正在生成题目…"
        return "  ,  ".join(sequence_texts)

func _format_value(value) -> String:
        var text_value := PLACEHOLDER_TEXT
        if value != null:
                text_value = str(value)
                if text_value.is_empty():
                        text_value = PLACEHOLDER_TEXT
        return text_value

func _draw_shape_display(display, structure: String) -> bool:
        _clear_shape_grid()
        if shape_grid == null:
                return false
        if not (display is Dictionary):
                return false
        var structure_hint := structure.to_lower()
        var placed := 0
        for key in display.keys():
                var base_key := _base_cell_key(str(key))
                var pos: Vector2i = _shape_position_for(base_key, structure_hint, display)
                if pos.x < 0 or pos.y < 0:
                        continue
                var idx: int = pos.y * 3 + pos.x
                if idx < 0 or idx >= _shape_cells.size():
                        continue
                var cell: Label = _shape_cells[idx]
                if cell == null:
                        continue
                cell.visible = true
                cell.text = _format_value(display[key])
                placed += 1
        return placed > 0

func _clear_shape_grid() -> void:
        for cell in _shape_cells:
                if cell == null:
                        continue
                cell.text = ""
                cell.visible = false

func _base_cell_key(key: String) -> String:
        var underscore := key.find("_")
        if underscore != -1 and underscore < key.length() - 1:
                return key.substr(underscore + 1, key.length() - underscore - 1)
        return key

func _shape_position_for(base_key: String, structure_hint: String, display: Dictionary) -> Vector2i:
        if base_key.length() >= 4 and base_key.begins_with("r") and base_key.substr(2, 1) == "c":
                var row := int(base_key.substr(1, 1)) - 1
                var col := int(base_key.substr(3, 1)) - 1
                if row >= 0 and row < 3 and col >= 0 and col < 3:
                        return Vector2i(col, row)
        var triangle_layout := structure_hint.find("triangle") != -1
        if triangle_layout or (display.has("T") and display.has("L") and display.has("R")):
                match base_key:
                        "T":
                                return Vector2i(1, 0)
                        "L":
                                return Vector2i(0, 2)
                        "R":
                                return Vector2i(2, 2)
                        "C", "S", "X":
                                return Vector2i(1, 1)
                        "A":
                                return Vector2i(1, 0)
                        "B":
                                return Vector2i(0, 1)
                        "C":
                                return Vector2i(2, 1)
                        "D":
                                return Vector2i(0, 2)
                        "E":
                                return Vector2i(2, 2)
                        "F":
                                return Vector2i(1, 2)
                return Vector2i(-1, -1)
        if structure_hint.find("square") != -1:
                match base_key:
                        "A":
                                return Vector2i(0, 0)
                        "B":
                                return Vector2i(2, 0)
                        "C":
                                return Vector2i(0, 2)
                        "D":
                                return Vector2i(2, 2)
                        "E", "S":
                                return Vector2i(1, 1)
                # fall through to cross mapping for UDLR keys
        if structure_hint.find("circle") != -1:
                match base_key:
                        "A":
                                return Vector2i(0, 1)
                        "B":
                                return Vector2i(2, 1)
                        "C":
                                return Vector2i(0, 0)
                        "D":
                                return Vector2i(2, 0)
                        "X", "S":
                                return Vector2i(1, 1)
                return Vector2i(-1, -1)
        match base_key:
                "L":
                        return Vector2i(0, 1)
                "R":
                        return Vector2i(2, 1)
                "U", "T":
                        return Vector2i(1, 0)
                "D":
                        return Vector2i(1, 2)
                "C", "S":
                        return Vector2i(1, 1)
        return Vector2i(-1, -1)

func _on_option_selected(button: Button) -> void:
        if not _allow_input:
                return
        var selected_value = button.text
        var answer = _current_puzzle.get("answer", 0)
        if _values_equal(selected_value, answer):
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

func _handle_incorrect(button: Button, answer) -> void:
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
        var rules: Dictionary = _template_rules.get(_mode, {})
        var rule_text: String = rules.get(template_id, "暂无规则说明")
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

func _select_generator():
        match _mode:
                "shapes":
                        if _shape_generator == null:
                                _shape_generator = ShapePatternGenerator.new()
                        return _shape_generator
                "letters":
                        if _letter_generator == null:
                                _letter_generator = LetterPatternGenerator.new()
                        return _letter_generator
                _:
                        if _number_generator == null:
                                _number_generator = NumberPatternGenerator.new()
                        return _number_generator
        return null

func _template_hint_for(template_id: String) -> String:
        var hints: Dictionary = _template_hints.get(_mode, {})
        return hints.get(template_id, "")

func _values_equal(selected_value, answer) -> bool:
        if answer is int or answer is float:
                return int(selected_value) == int(answer)
        return str(selected_value) == str(answer)

func _random_letter_option(answer: String) -> String:
        var alphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var candidate := answer
        while candidate == answer:
                var idx := _rng.randi_range(0, alphabet.length() - 1)
                candidate = alphabet.substr(idx, 1)
        return candidate

func _log_puzzle(display, template_id: String, answer, structure: String) -> void:
        var rendered := _format_display(display)
        var mode_label := "数字" if _mode == "numbers" else ("图形" if _mode == "shapes" else "字母")
        var meta_bits: Array[String] = []
        if not structure.is_empty():
                meta_bits.append("结构:%s" % structure)
        var meta_text := ""
        if not meta_bits.is_empty():
                meta_text = " (%s)" % ", ".join(meta_bits)
        AppLogger.info("生成题目[%s/%s] %s%s -> %s | 答案:%s" % [mode_label, _difficulty, template_id, meta_text, rendered, str(answer)])

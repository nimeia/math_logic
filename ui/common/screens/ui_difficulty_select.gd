extends Control
class_name DifficultySelectScreen

signal difficulty_selected(mode: String, difficulty: String)
signal request_back

var _mode: String = ""
var _mode_data: Dictionary = {}
var _font_scale: float = 2.0
var _font_targets: Array[CanvasItem] = []
var _base_font_sizes: Dictionary = {}

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var unlocked_label: Label = %UnlockedLabel
@onready var tip_label: Label = %TipLabel
@onready var easy_progress: Label = %EasyProgress
@onready var medium_progress: Label = %MediumProgress
@onready var hard_progress: Label = %HardProgress
@onready var auto_font_button: Button = %AutoFontButton
@onready var easy_button: Button = %EasyButton
@onready var medium_button: Button = %MediumButton
@onready var hard_button: Button = %HardButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
    _init_font_scaling()
    auto_font_button.pressed.connect(_on_auto_font_button_pressed)

func set_mode(mode: String, mode_data: Dictionary) -> void:
    _mode = mode
    _mode_data = mode_data
    var title: String = mode_data.get("title", "")
    title_label.text = "选择难度 · %s" % title
    subtitle_label.text = mode_data.get("subtitle", "")
    var unlocked: Dictionary = mode_data.get("unlocked", {}) as Dictionary
    var unlocked_text: String = "已解锁关卡：%s / %s" % [unlocked.get("current", 0), unlocked.get("total", 0)]
    var level: String = mode_data.get("level", "")
    unlocked_label.text = "%s  %s" % [unlocked_text, level]
    tip_label.text = mode_data.get("tip", "今日推荐：保持练习！")
    _apply_difficulty("easy", mode_data.get("difficulty", {}), easy_progress)
    _apply_difficulty("medium", mode_data.get("difficulty", {}), medium_progress)
    _apply_difficulty("hard", mode_data.get("difficulty", {}), hard_progress)

func _apply_difficulty(key: String, difficulties: Dictionary, label: Label) -> void:
    var data: Dictionary = difficulties.get(key, {})
    var completed: int = data.get("completed", 0)
    var total: int = data.get("total", 0)
    var trophies: int = data.get("trophies", 0)
    var diff_label: String = data.get("label", key)
    label.text = "%s：已通关 %s/%s 关 · 奖杯 %s" % [diff_label, completed, total, trophies]

func _on_easy_pressed() -> void:
    difficulty_selected.emit(_mode, "easy")

func _on_medium_pressed() -> void:
    difficulty_selected.emit(_mode, "medium")

func _on_hard_pressed() -> void:
    difficulty_selected.emit(_mode, "hard")

func _on_back_pressed() -> void:
    request_back.emit()

func _init_font_scaling() -> void:
    _font_targets = [
        title_label,
        subtitle_label,
        unlocked_label,
        tip_label,
        easy_progress,
        medium_progress,
        hard_progress,
        easy_button,
        medium_button,
        hard_button,
        back_button,
    ]
    _base_font_sizes.clear()
    for node in _font_targets:
        if node == null:
            continue
        var base_size: int = node.get_theme_font_size("font_size")
        _base_font_sizes[node.get_instance_id()] = base_size
    _apply_font_scale(_font_scale)

func _on_auto_font_button_pressed() -> void:
    var options: Array[float] = [1.5, 2.0, 2.5]
    var next_scale: float = options[0]
    for candidate in options:
        if candidate > _font_scale + 0.01:
            next_scale = candidate
            break
    _apply_font_scale(next_scale)

func _apply_font_scale(value: float) -> void:
    _font_scale = value
    for node in _font_targets:
        if node == null:
            continue
        var base_size: int = _base_font_sizes.get(node.get_instance_id(), node.get_theme_font_size("font_size"))
        var scaled: int = int(round(base_size * _font_scale))
        node.add_theme_font_size_override("font_size", scaled)
    _update_font_button_label()

func _update_font_button_label() -> void:
    if auto_font_button != null:
        auto_font_button.text = "字体大小 %.1fx" % _font_scale

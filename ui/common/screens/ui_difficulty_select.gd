extends Control
class_name DifficultySelectScreen

signal difficulty_selected(mode: String, difficulty: String)
signal request_back

var _mode: String = ""
var _mode_data: Dictionary = {}

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var unlocked_label: Label = %UnlockedLabel
@onready var tip_label: Label = %TipLabel
@onready var easy_progress: Label = %EasyProgress
@onready var medium_progress: Label = %MediumProgress
@onready var hard_progress: Label = %HardProgress

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

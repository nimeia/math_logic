extends UIScreenBase

const MODE_NUMBERS := "numbers"
const MODE_SHAPES := "shapes"
const MODE_LETTERS := "letters"

var _mode_progress: Dictionary = {}

@onready var settings_button: Button = %SettingsButton
@onready var week_progress: ProgressBar = %WeekProgress
@onready var week_progress_label: Label = %WeekProgressLabel
@onready var daily_task_label: Label = %DailyTaskLabel
@onready var user_label: Label = %UserLabel
@onready var home_button: Button = %HomeButton
@onready var report_button: Button = %ReportButton
@onready var parents_button: Button = %ParentsButton

@onready var number_card: PanelContainer = %NumberCard
@onready var shape_card: PanelContainer = %ShapeCard
@onready var letter_card: PanelContainer = %LetterCard
@onready var number_start: Button = %NumberStartButton
@onready var shape_start: Button = %ShapeStartButton
@onready var letter_start: Button = %LetterStartButton
@onready var number_continue: Button = %NumberContinueButton
@onready var shape_continue: Button = %ShapeContinueButton
@onready var letter_continue: Button = %LetterContinueButton

func _ready() -> void:
    super._ready()
    settings_button.pressed.connect(_on_settings_pressed)
    home_button.pressed.connect(func() -> void: request_navigate.emit("home"))
    report_button.pressed.connect(func() -> void: request_navigate.emit("report"))
    parents_button.pressed.connect(func() -> void: request_navigate.emit("parents"))
    _connect_card_signals()

func set_profile_summary(summary: Dictionary) -> void:
    var name: String = summary.get("name", "")
    var grade: String = summary.get("grade", "")
    user_label.text = "%s · %s" % [name, grade]
    var week_done: int = summary.get("week_completed", 0)
    var week_target: int = max(1, summary.get("week_target", 1))
    week_progress.max_value = week_target
    week_progress.value = week_done
    week_progress_label.text = "本周已完成 %s/%s 关" % [week_done, week_target]
    var daily_done: int = summary.get("daily_completed", 0)
    var daily_target: int = summary.get("daily_target", 0)
    daily_task_label.text = "今日任务：完成 %s 关（已完成 %s/%s）" % [daily_target, daily_done, daily_target]

func set_mode_progress(progress: Dictionary) -> void:
    _mode_progress = progress
    _apply_card(MODE_NUMBERS, number_card)
    _apply_card(MODE_SHAPES, shape_card)
    _apply_card(MODE_LETTERS, letter_card)

func _connect_card_signals() -> void:
    number_card.gui_input.connect(func(event: InputEvent) -> void:
        _handle_card_input(event, MODE_NUMBERS))
    shape_card.gui_input.connect(func(event: InputEvent) -> void:
        _handle_card_input(event, MODE_SHAPES))
    letter_card.gui_input.connect(func(event: InputEvent) -> void:
        _handle_card_input(event, MODE_LETTERS))
    number_start.pressed.connect(func() -> void: _on_card_selected(MODE_NUMBERS))
    shape_start.pressed.connect(func() -> void: _on_card_selected(MODE_SHAPES))
    letter_start.pressed.connect(func() -> void: _on_card_selected(MODE_LETTERS))
    number_continue.pressed.connect(func() -> void: _on_continue(MODE_NUMBERS))
    shape_continue.pressed.connect(func() -> void: _on_continue(MODE_SHAPES))
    letter_continue.pressed.connect(func() -> void: _on_continue(MODE_LETTERS))

func _handle_card_input(event: InputEvent, mode: String) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        request_open_difficulty.emit(mode)

func _apply_card(mode: String, card: PanelContainer) -> void:
    var data: Dictionary = _mode_progress.get(mode, {})
    var icon_label := card.get_node("VBox/Header/Icon") as Label
    var title_label := card.get_node("VBox/Header/Title") as Label
    var level_label := card.get_node("VBox/Header/Level") as Label
    var subtitle_label := card.get_node("VBox/Subtitle") as Label
    var progress_label := card.get_node("VBox/Progress") as Label
    var tip_label := card.get_node("VBox/Tip") as Label
    var quick_label := card.get_node("VBox/Footer/QuickLabel") as Label
    icon_label.text = data.get("icon", "")
    title_label.text = data.get("title", "")
    level_label.text = data.get("level", "")
    subtitle_label.text = data.get("subtitle", "")
    var unlocked := data.get("unlocked", {})
    var cleared: int = data.get("cleared", 0)
    progress_label.text = "已通关：%s 关｜已解锁：%s/%s" % [cleared, unlocked.get("current", 0), unlocked.get("total", 0)]
    tip_label.text = data.get("tip", "")
    quick_label.text = "继续上一关：%s" % _difficulty_label(data.get("last_difficulty", "easy"))

func _difficulty_label(key: String) -> String:
    match key:
        "easy":
            return "简单"
        "medium":
            return "中等"
        "hard":
            return "挑战"
        _:
            return key

func _on_settings_pressed() -> void:
    request_open_settings.emit()

func _on_card_selected(mode: String) -> void:
    request_open_difficulty.emit(mode)

func _on_continue(mode: String) -> void:
    request_quick_start.emit(mode)

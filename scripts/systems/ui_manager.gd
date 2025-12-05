extends Node
const AppLogger = preload("res://scripts/core/logger.gd")
const UIScreenBase := preload("res://scripts/systems/ui_screen_base.gd")
const NUMBER_GAME_SCENE_BIG := preload("res://ui/big_screen/screens/ui_number_game_big.tscn")
const NUMBER_GAME_SCENE_HANDHELD := preload("res://ui/handheld/screens/ui_number_game_handheld.tscn")
const MODE_NUMBERS := "numbers"
const MODE_SHAPES := "shapes"
const MODE_LETTERS := "letters"
const NumberPatternGenerator := preload("res://scripts/gameplay/number_pattern_generator.gd")
const ShapePatternGenerator := preload("res://scripts/gameplay/shape_pattern_generator.gd")
const LetterPatternGenerator := preload("res://scripts/gameplay/letter_pattern_generator.gd")

var _ui_layer: CanvasLayer = CanvasLayer.new()
var _screen_root: Control = Control.new()
var _current_screen: Control = Control.new()
var _number_generator: NumberPatternGenerator
var _shape_generator: ShapePatternGenerator
var _letter_generator: LetterPatternGenerator

var _mode_progress_data: Dictionary = {
	MODE_NUMBERS: {
		"title": "数字规律闯关",
		"subtitle": "练习数列、加减乘除找规律",
		"icon": "🔢",
		"unlocked": {"current": 15, "total": 90},
		"level": "Lv.3",
		"tip": "今天推荐题型：等差数列",
		"cleared": 18,
		"last_difficulty": "medium",
		"difficulty": {
			"easy": {"label": "简单", "completed": 8, "total": 30, "trophies": 10},
			"medium": {"label": "中等", "completed": 6, "total": 30, "trophies": 8},
			"hard": {"label": "挑战", "completed": 4, "total": 30, "trophies": 5}
		}
	},
	MODE_SHAPES: {
		"title": "图形数字推理",
		"subtitle": "九宫格、圆圈数阵、三角形阵",
		"icon": "🔶",
		"unlocked": {"current": 10, "total": 60},
		"level": "Lv.2",
		"tip": "最近：圆圈数阵表现很棒！",
		"cleared": 12,
		"last_difficulty": "easy",
		"difficulty": {
			"easy": {"label": "简单", "completed": 6, "total": 20, "trophies": 6},
			"medium": {"label": "中等", "completed": 4, "total": 20, "trophies": 3},
			"hard": {"label": "挑战", "completed": 2, "total": 20, "trophies": 1}
		}
	},
	MODE_LETTERS: {
		"title": "字母规律实验室",
		"subtitle": "A=1 编码、字母跳跃、简单密码",
		"icon": "🔤",
		"unlocked": {"current": 8, "total": 60},
		"level": "Lv.2",
		"tip": "已掌握：A=1 编码",
		"cleared": 9,
		"last_difficulty": "easy",
		"difficulty": {
			"easy": {"label": "简单", "completed": 5, "total": 20, "trophies": 7},
			"medium": {"label": "中等", "completed": 3, "total": 20, "trophies": 2},
			"hard": {"label": "挑战", "completed": 1, "total": 20, "trophies": 0}
		}
	}
}

var _player_summary: Dictionary = {
	"name": "小明",
	"grade": "二年级",
	"week_completed": 12,
	"week_target": 20,
	"daily_completed": 2,
	"daily_target": 5
}

func _ready() -> void:
	if _ui_layer.get_parent() == null:
		add_child(_ui_layer)
	if _screen_root.get_parent() == null:
		_ui_layer.add_child(_screen_root)
	_screen_root.name = "UIScreenRoot"
	_screen_root.anchor_right = 1.0
	_screen_root.anchor_bottom = 1.0
	_screen_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_screen_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if _number_generator == null:
		_number_generator = NumberPatternGenerator.new()
	if _shape_generator == null:
		_shape_generator = ShapePatternGenerator.new()
	if _letter_generator == null:
		_letter_generator = LetterPatternGenerator.new()

func _show_packed_scene(packed: PackedScene, scene_path: String) -> Control:
	if packed == null:
		AppLogger.error("UI screen not found: %s" % scene_path)
		return Control.new()
	var next := packed.instantiate() as Control
	if next == null:
		AppLogger.error("UI scene root must be Control: %s" % scene_path)
		return Control.new()
	if is_instance_valid(_current_screen):
		var old_screen := _current_screen
		_current_screen = Control.new()
		if is_instance_valid(old_screen.get_parent()):
			old_screen.get_parent().remove_child(old_screen)
		old_screen.queue_free()
	_current_screen = next
	_screen_root.add_child(_current_screen)
	return _current_screen

func show_screen(scene_path: String) -> Control:
	var packed := ResourceLoader.load(scene_path) as PackedScene
	return _show_packed_scene(packed, scene_path)

func show_main_menu() -> void:
	var target: String = "res://ui/big_screen/screens/ui_main_menu_big.tscn"
	if DeviceProfile.is_handheld():
		target = "res://ui/handheld/screens/ui_main_menu_handheld.tscn"
	var screen := show_screen(target)
	if screen is UIScreenBase:
		var menu := screen as UIScreenBase
		_connect_common_signals(menu)
		if menu.has_method("set_mode_progress"):
			menu.call("set_mode_progress", _mode_progress_data)
		if menu.has_method("set_profile_summary"):
			menu.call("set_profile_summary", _player_summary)
		menu.request_open_difficulty.connect(_on_request_difficulty)
		menu.request_quick_start.connect(_on_request_quick_start)
		menu.request_navigate.connect(_on_request_navigate)

func show_difficulty_select(mode: String) -> void:
	var target: String = "res://ui/common/screens/ui_difficulty_select.tscn"
	var screen := show_screen(target)
	if screen is Control:
		if screen.has_method("set_mode"):
			var mode_data: Dictionary = _mode_progress_data.get(mode, {})
			screen.call("set_mode", mode, mode_data)
		if screen.has_signal("difficulty_selected"):
			screen.connect("difficulty_selected", Callable(self, "_on_difficulty_selected"))
		if screen.has_signal("request_back"):
			screen.connect("request_back", Callable(self, "show_main_menu"))

func _connect_common_signals(screen: UIScreenBase) -> void:
	screen.request_open_settings.connect(_on_open_settings)
	screen.request_quit.connect(_on_quit_requested)

func _on_request_difficulty(mode: String) -> void:
	show_difficulty_select(mode)

func _on_request_quick_start(mode: String) -> void:
	if mode == MODE_NUMBERS:
		var data: Dictionary = _mode_progress_data.get(mode, {})
		var last_diff: String = data.get("last_difficulty", "easy")
		_start_numbers_game(mode, last_diff)
	elif mode == MODE_SHAPES:
		var shapes_data: Dictionary = _mode_progress_data.get(mode, {})
		var shapes_last_diff: String = shapes_data.get("last_difficulty", "easy")
		_preview_shapes_puzzle(mode, shapes_last_diff, "quick_start")
	elif mode == MODE_LETTERS:
		var letters_data: Dictionary = _mode_progress_data.get(mode, {})
		var letters_last_diff: String = letters_data.get("last_difficulty", "easy")
		_preview_letters_puzzle(mode, letters_last_diff, "quick_start")
	else:
		AppLogger.info("Quick start requested for mode: %s" % mode)

func _on_request_navigate(destination: String) -> void:
	AppLogger.info("Navigate to: %s" % destination)

func _on_open_settings() -> void:
	AppLogger.info("Settings requested")

func _on_quit_requested() -> void:
	AppLogger.info("Quit requested from UI")

func _on_difficulty_selected(mode: String, difficulty: String) -> void:
	if mode == MODE_NUMBERS:
		_mode_progress_data[mode]["last_difficulty"] = difficulty
		_start_numbers_game(mode, difficulty)
	elif mode == MODE_SHAPES:
		_mode_progress_data[mode]["last_difficulty"] = difficulty
		_preview_shapes_puzzle(mode, difficulty, "difficulty_select")
	elif mode == MODE_LETTERS:
		_mode_progress_data[mode]["last_difficulty"] = difficulty
		_preview_letters_puzzle(mode, difficulty, "difficulty_select")
	else:
		AppLogger.info("Difficulty selected: %s - %s" % [mode, difficulty])



func _start_numbers_game(mode: String, difficulty: String) -> void:
	var target: String = "res://ui/big_screen/screens/ui_number_game_big.tscn"
	var packed: PackedScene = NUMBER_GAME_SCENE_BIG
	if DeviceProfile.is_handheld():
		target = "res://ui/handheld/screens/ui_number_game_handheld.tscn"
		packed = NUMBER_GAME_SCENE_HANDHELD
	var screen := _show_packed_scene(packed, target)
	if screen is UIScreenBase:
		var gameplay_screen := screen as UIScreenBase
		_connect_common_signals(gameplay_screen)
	if screen.has_method("configure"):
		screen.call("configure", mode, difficulty)
	if screen.has_signal("request_back"):
		screen.connect("request_back", Callable(self, "show_main_menu"))

func _preview_numbers_puzzle(mode: String, difficulty: String, reason: String) -> void:
	if _number_generator == null:
		_number_generator = NumberPatternGenerator.new()
	var puzzle: Dictionary = _number_generator.generate_puzzle(difficulty)
	if puzzle.is_empty():
		AppLogger.error("Failed to generate puzzle for %s (%s)" % [mode, difficulty])
		return
	var display_array: Array[String] = []
	for value in puzzle.get("display", []):
		display_array.append(str(value))
	var display: String = ", ".join(display_array)
	AppLogger.info("Generated %s puzzle via %s [%s]: %s -> answer %s" % [mode, reason, puzzle.get("template_id", ""), display, str(puzzle.get("answer", "?"))])

func _preview_shapes_puzzle(mode: String, difficulty: String, reason: String) -> void:
	if _shape_generator == null:
		_shape_generator = ShapePatternGenerator.new()
	var puzzle: Dictionary = _shape_generator.generate_puzzle(difficulty)
	if puzzle.is_empty():
		AppLogger.error("Failed to generate puzzle for %s (%s)" % [mode, difficulty])
		return
	var entries: Array[String] = []
	for key in puzzle.get("display", {}).keys():
		entries.append("%s:%s" % [key, str(puzzle.get("display", {}).get(key, ""))])
	entries.sort()
	var display: String = "; ".join(entries)
	AppLogger.info("Generated %s puzzle via %s [%s]: %s -> answer %s" % [mode, reason, puzzle.get("template_id", ""), display, str(puzzle.get("answer", "?"))])

func _preview_letters_puzzle(mode: String, difficulty: String, reason: String) -> void:
	if _letter_generator == null:
		_letter_generator = LetterPatternGenerator.new()
	var puzzle: Dictionary = _letter_generator.generate_puzzle(difficulty)
	if puzzle.is_empty():
		AppLogger.error("Failed to generate puzzle for %s (%s)" % [mode, difficulty])
		return
	var display_entries: Array[String] = []
	var display_data = puzzle.get("display", [])
	if display_data is Array:
		for entry in display_data:
			display_entries.append(str(entry))
	elif display_data is Dictionary:
		for key in display_data.keys():
			display_entries.append("%s:%s" % [key, str(display_data.get(key, ""))])
		display_entries.sort()
	var display: String = ", ".join(display_entries)
	AppLogger.info("Generated %s puzzle via %s [%s]: %s -> answer %s" % [mode, reason, puzzle.get("template_id", ""), display, str(puzzle.get("answer", "?"))])

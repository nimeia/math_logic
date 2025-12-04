extends Node
const AppLogger = preload("res://scripts/core/logger.gd")
class_name GameState

const NumberPatternGenerator := preload("res://scripts/gameplay/number_pattern_generator.gd")
const ShapePatternGenerator := preload("res://scripts/gameplay/shape_pattern_generator.gd")
const LetterPatternGenerator := preload("res://scripts/gameplay/letter_pattern_generator.gd")

var is_running: bool = false
var _number_generator: NumberPatternGenerator = NumberPatternGenerator.new()
var _shape_generator: ShapePatternGenerator = ShapePatternGenerator.new()
var _letter_generator: LetterPatternGenerator = LetterPatternGenerator.new()

func start_game() -> void:
    is_running = true
    AppLogger.info("Game started")

func pause_game() -> void:
    is_running = false
    AppLogger.info("Game paused")

func reset() -> void:
    is_running = false
    AppLogger.info("Game reset")

func generate_number_puzzle(difficulty: String) -> Dictionary:
    return _number_generator.generate_puzzle(difficulty)

func generate_shape_puzzle(difficulty: String) -> Dictionary:
    return _shape_generator.generate_puzzle(difficulty)

func generate_letter_puzzle(difficulty: String) -> Dictionary:
    return _letter_generator.generate_puzzle(difficulty)

extends Control

@export var total_questions := 10
@export var time_per_question := 15.0  # secunde

@onready var punctaj: Label        = $punctaj
@onready var binary_label          = $RichTextLabel
@onready var input_box             = $TextEdit
@onready var timer_label           = $Label
@onready var timer_node            = $Timer

var current_question := 0
var score := 0
var current_binary := ""
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	timer_node.one_shot = true
	timer_node.wait_time = time_per_question
	timer_node.connect("timeout", Callable(self, "_on_time_up"))
	#input_box.connect("text_entered", Callable(self, "_on_submit"))

	# Inițial afișăm punctajul 0
	punctaj.text = "0"
	_start_question()

func _process(delta: float) -> void:
	if not timer_node.is_stopped():
		var t = ceil(timer_node.time_left)
		timer_label.text = "Time: %d" % t

func _start_question() -> void:
	if current_question >= total_questions:
		_end_game()
		return

	# Generăm un număr 0–31 și transformăm în 5 biți
	var n = rng.randi_range(0, 31)
	current_binary = _to_5bit_binary(n)

	# Afișăm în RichTextLabel
	binary_label.bbcode_enabled = true
	binary_label.bbcode_text = "[center][b]%s[/b][/center]" % current_binary

	# Reset input și timer
	input_box.text = ""
	input_box.editable = true
	input_box.grab_focus()
	timer_label.text = "Time: %d" % time_per_question
	timer_node.start()

func _to_5bit_binary(n: int) -> String:
	var s := ""
	for i in range(5):
		s = str((n >> i) & 1) + s
	return s

func _on_submit(text: String) -> void:
	_check_answer(text)

func _on_time_up() -> void:
	_check_answer(input_box.text)

func _check_answer(answer: String) -> void:
	timer_node.stop()
	input_box.editable = false

	var correct = _binary_to_int(current_binary)
	if answer != null and answer.is_valid_int() and int(answer) == correct:
		score += 1
		punctaj.text = str(score)    # actualizăm labelul cu punctajul

	current_question += 1
	# trecem la următoarea întrebare
	call_deferred("_start_question")

func _binary_to_int(bin_str: String) -> int:
	var result := 0
	for c in bin_str:
		result = result * 2 + (1 if c == "1" else 0)
	return result

func _end_game() -> void:
	# Mesaj final în binary_label
	var msg = "Ai trecut" if (score>=5) else "Ai picat"
	binary_label.bbcode_enabled = true
	binary_label.bbcode_text = "[center]%s\nScor: %d/%d[/center]" \
		% [msg, score, total_questions]

	timer_label.text = ""
	input_box.editable = false

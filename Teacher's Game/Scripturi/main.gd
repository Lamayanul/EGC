extends Node2D

@export var FallingItemScene: PackedScene
@export var spawn_interval := 0.5
@onready var inv = get_node("/root/world/Inventar/Inv")
@onready var spawn_timer   := $SpawnTimer
@onready var score_label   := $"../ScoreLabel"
@onready var penalty_label := $"../PenaltyLabel"

var score   := 0
var penalty := 0

var bug_words     = ["bug", "error", "null_ref", "segfault", "overflow", "race_cond"]
var command_words = ["cout", "queue", "push", "pop", "main", "for", "while", "if", "printf"]

func _ready() -> void:
	randomize()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	spawn_timer.start()
	_update_labels()

func _on_spawn_timer_timeout() -> void:
	var item = FallingItemScene.instantiate()

	if randi() % 2 == 0:
		item.get_node("Label").text = bug_words[randi() % bug_words.size()]
		item.is_bug = true
	else:
		item.get_node("Label").text = command_words[randi() % command_words.size()]
		item.is_bug = false

	var vw = get_viewport_rect().size.x
	item.position = Vector2(randi() % int(vw), -20)

	# Conectează semnalul și adaugă la scenă
	item.connect("clicked", Callable(self, "_on_item_clicked"))
	add_child(item)

func _on_item_clicked(is_bug: bool) -> void:
	if is_bug:
		score += 1
	else:
		penalty += 1

	_update_labels()
	_check_end_conditions()

func _update_labels() -> void:
	score_label.text   = "Score: %d"   % score
	penalty_label.text = "Penalty: %d" % penalty

func _check_end_conditions() -> void:
	if score >= 10:
		_end_game("Ai câștigat!")
		inv.drop_item("1",5)
		$"../exit".visible=true
	elif penalty >= 5:
		_end_game("Ai pierdut!")
		$"../exit".visible=true

func _end_game(message: String) -> void:
	# Oprește spawn-ul
	spawn_timer.stop()
	# Distruge toate obiectele căzătoare rămase
	for child in get_children():
		if child is Area2D:
			child.queue_free()
	score_label.text = "%s\nFinal Score: %d\nPenalties: %d" % [message, score, penalty]
	penalty_label.visible = false


func _on_exit_pressed() -> void:
	$"..".visible=false

extends Node2D

@onready var line_edit: LineEdit = %LineEdit
@onready var vbox: VBoxContainer = $CanvasLayer/Panel/VBoxContainer
@onready var panel: Panel = $CanvasLayer/Panel
@onready var cycle_d_n = get_node("/root/world/Cycle_d_n")

var toggle = false

func _ready() -> void:
	line_edit.connect("text_submitted", Callable(self, "cons_edit"))

func get_player():
	return get_tree().get_first_node_in_group("player")

func cons_edit(new_text: String):
	var command = new_text.strip_edges()
	if command == "set_day_5":
		# Setează ziua la 5
		cycle_d_n.day_counter = 5
		# Setează ora la 08:00 AM
		var anim = cycle_d_n.animation_player
		var total_time = anim.current_animation_length
		var new_time = (8 * 60 - 480) / (24.0 * 60.0) * total_time # 480 e start_time din scriptul tău de zi/noapte
		anim.seek(new_time, true)
		# Generează intervale pentru noua zi
		if cycle_d_n.has_method("genereaza_intervale"):
			cycle_d_n.genereaza_intervale()
		# Afișează în consolă
		var new_label = Label.new()
		new_label.text = "Ziua setată la 5, ora la 08:00"
		vbox.add_child(new_label)
		line_edit.text = ""
	else:
		var new_label = Label.new()
		new_label.text = "Comandă necunoscută."
		vbox.add_child(new_label)
		line_edit.text = ""

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("consola"):
		toggle = !toggle
		$CanvasLayer.visible = toggle
		if $CanvasLayer.visible:
			get_player().can_move = false
		else:
			get_player().can_move = true

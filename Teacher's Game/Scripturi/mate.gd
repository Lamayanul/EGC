extends CanvasLayer

@onready var label: Label = $Label
@onready var submit_button: Button = $Button
@onready var label_2: Label = $Label2
@onready var inv = get_node("/root/world/Inventar/Inv")
@onready var text_edit_1: TextEdit = $TextureRect/VBoxContainer/HBoxContainer/TextEdit
@onready var text_edit_2: TextEdit = $TextureRect/VBoxContainer/HBoxContainer2/TextEdit
@onready var text_edit_3: TextEdit = $TextureRect/VBoxContainer/HBoxContainer3/TextEdit
@onready var text_edit_4: TextEdit = $TextureRect/VBoxContainer/HBoxContainer4/TextEdit
@onready var text_edit_5: TextEdit = $TextureRect/VBoxContainer/HBoxContainer5/TextEdit
@onready var text_edit_6: TextEdit = $TextureRect/VBoxContainer/HBoxContainer6/TextEdit
@onready var text_edit_7: TextEdit = $TextureRect/VBoxContainer/HBoxContainer7/TextEdit
@onready var text_edit_8: TextEdit = $TextureRect/VBoxContainer/HBoxContainer8/TextEdit
@onready var text_edit_9: TextEdit = $TextureRect/VBoxContainer/HBoxContainer9/TextEdit
@onready var text_edit_10: TextEdit = $TextureRect/VBoxContainer/HBoxContainer10/TextEdit

var punctaj = 0
var text_edits := []

func _ready() -> void:

	text_edits = [
		text_edit_1, text_edit_2, text_edit_3, text_edit_4, text_edit_5,
		text_edit_6, text_edit_7, text_edit_8, text_edit_9, text_edit_10
	]


	submit_button.disabled = true

	for te in text_edits:
		te.connect("text_changed", Callable(self, "_on_text_changed"))

	_update_submit_button()

func _on_text_changed() -> void:
	_update_submit_button()

func _update_submit_button() -> void:
	for te in text_edits:
		if te.text.strip_edges() == "":
			submit_button.disabled = true
			return
	# dacă am ajuns aici, toate au text
	submit_button.disabled = false

func _on_button_pressed() -> void:
	if text_edit_1.text == "6":
		punctaj += 1
	if text_edit_2.text == "10":
		punctaj += 1
	if text_edit_3.text == "4":
		punctaj += 1
	if text_edit_4.text == "4":
		punctaj += 1
	if text_edit_5.text == "41":
		punctaj += 1
	if text_edit_6.text == "7":
		punctaj += 1
	if text_edit_7.text == "2":
		punctaj += 1
	if text_edit_8.text == "-3":
		punctaj += 1
	if text_edit_9.text == "3":
		punctaj += 1
	if text_edit_10.text == "3":
		punctaj += 1

	label.text = str(punctaj)
	if punctaj>=5:
		label_2.text="Ai trecut"
		inv.drop_item("1",1)
		$exit.visible=true
	else:
		label_2.text="Ai picat"
		$exit.visible=true



func _on_exit_pressed() -> void:
	$".".visible=false

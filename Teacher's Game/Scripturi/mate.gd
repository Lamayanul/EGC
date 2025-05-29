extends CanvasLayer

@onready var label: Label = $Label
@onready var submit_button: Button = $Button
@onready var label_2: Label = $Label2

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
	# 1) Adunăm toate TextEdit-urile într-un array
	text_edits = [
		text_edit_1, text_edit_2, text_edit_3, text_edit_4, text_edit_5,
		text_edit_6, text_edit_7, text_edit_8, text_edit_9, text_edit_10
	]

	# 2) La început, butonul e dezactivat
	submit_button.disabled = true

	# 3) Conectăm semnalul text_changed de la fiecare câmp
	for te in text_edits:
		te.connect("text_changed", Callable(self, "_on_text_changed"))

	# 4) Verificăm o dată (în caz că sunt deja pre-populate)
	_update_submit_button()

func _on_text_changed() -> void:
	_update_submit_button()

func _update_submit_button() -> void:
	# dacă există vreun TextEdit gol, păstrăm butonul disabled
	for te in text_edits:
		if te.text.strip_edges() == "":
			submit_button.disabled = true
			return
	# dacă am ajuns aici, toate au text
	submit_button.disabled = false

func _on_button_pressed() -> void:
	# Procesăm răspunsurile doar dacă butonul e activ
	# (oricum _on_button_pressed nu va fi apelat când e disabled)
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
	else:
		label_2.text="Ai picat"

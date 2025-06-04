extends CanvasLayer

@onready var rich_text_label : RichTextLabel = $RichTextLabel
@onready var text_edit        : TextEdit      = $TextEdit
@onready var text_edit_2      : TextEdit      = $TextEdit2
@onready var text_edit_3      : TextEdit      = $TextEdit3
@onready var submit_button    : Button        = $SubmitButton
@onready var result_label     : Label         = $ResultLabel
@onready var inv = get_node("/root/world/Inventar/Inv")
const FRACTAL_TEXT := """
Fractalii sunt structuri geometrice care se repetă la nesfârșit, 
prezentând un grad de complexitate aparent infinit. Ele au fost 
descrise pentru prima oară de matematicianul Benoît Mandelbrot în anii 1970,
în studiul său privind geometria haotică și auto-similaritatea. 
Un fractal este definit de o formulă recursivă care generează, 
de la o scară foarte mică la una foarte mare, același tipar. 
Cele mai cunoscute exemple sunt mulțimile Mandelbrot și Julia: 
în interiorul fiecăreia, orice porțiune, oricât de mică, ascunde 
o copie mărită a întregului.  
Determinarea dimensiunii fractale (numită și „dimensiune haotică”) 
nu mai este un număr întreg, ci un număr real, care reflectă gradul 
de detaliu al formei.  
"""

const QUESTION := "\nÎntrebare: Introdu trei termeni din text care descriu proprietatea de repetitivitate a fractalilor."

func _ready() -> void:
	rich_text_label.bbcode_enabled = false
	rich_text_label.text = QUESTION

	submit_button.disabled = false
	submit_button.connect("pressed", Callable(self, "_on_submit"))
	# invisiblează label-ul de rezultat la început
	result_label.text = ""

func _on_submit() -> void:
	var content = (FRACTAL_TEXT).to_lower()  # textul în care verificăm
	var answers = [
		text_edit.text.strip_edges(),
		text_edit_2.text.strip_edges(),
		text_edit_3.text.strip_edges()
	]
	var matches = 0
	for a in answers:
		if a != "" and content.find(a.to_lower()) != -1:
			matches += 1

	if matches >= 2:
		result_label.text = "Ai trecut!"
		inv.drop_item("1",3)
		$exit.visible=true
	else:
		result_label.text = "Ai picat!"
		$exit.visible=true


func _on_exit_pressed() -> void:
	$".".visible=false

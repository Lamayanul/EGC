extends Node2D
@onready var final: RichTextLabel = $final

# Structura cu toate testele și răspunsurile
var tests = [
	{ # 1. Proiectarea logică
		"questions": [
			"Care este poarta logică cu ieșirea adevărată doar dacă ambele intrări sunt adevărate?",
			"Cum se numește poarta logică care inversează semnalul de intrare?",
			"Ce poartă logică are ieșirea adevărată dacă cel puțin una dintre intrări este adevărată?",
			"Ce tip de circuit memorează un singur bit?",
			"Ce poartă logică are ieșirea adevărată doar dacă exact una dintre intrări este adevărată?",
			"Cum se numește tabela ce descrie toate combinațiile posibile de intrări și ieșiri pentru o funcție logică?",
			"Cum se numește forma minimizată a unei funcții logice?",
			"Care este poarta logică universală ce poate implementa orice funcție logică?",
			"Ce circuit realizează conversia codului binar în cod zecimal?",
			"Ce reprezintă “hazardul” într-un circuit logic?"
		],
		"answers": [
			"AND", "NOT", "OR", "Latch", "XOR", "Tabel adevăr", "Minimă", "NAND", "Decoder", "Glitch"
		]
	},
	{ # 2. Matematică
		"questions": [
			"Cum se numește rezultatul unei adunări?",
			"Care este derivata lui x²?",
			"Cum se numește linia care împarte un unghi în două unghiuri egale?",
			"Câte grade are un unghi drept?",
			"Care este formula ariei cercului?",
			"Care este cel mai mic număr prim?",
			"Cum se numește triunghiul cu toate laturile egale?",
			"Ce nume poartă rezultatul unei înmulțiri?",
			"Care este rădăcina pătrată a lui 49?",
			"Cum se numește segmentul care unește centrul cercului cu un punct de pe cerc?"
		],
		"answers": [
			"Sumă", "2x", "Bisectoare", "90", "πr²", "2", "Echilateral", "Produs", "7", "Rază"
		]
	},
	{ # 3. Rețele de Calculatoare
		"questions": [
			"Ce protocol este folosit pentru trimiterea emailurilor?",
			"Cum se numește dispozitivul care interconectează două sau mai multe rețele diferite?",
			"Ce prescurtare are adresa de identificare a unei plăci de rețea?",
			"Cum se numește protocolul de bază pentru internet?",
			"Ce tehnologie permite comunicarea fără fir?",
			"Ce port standard folosește HTTP?",
			"Cum se numește rețeaua locală de calculatoare?",
			"Care este protocolul pentru transfer de fișiere?",
			"Ce dispozitiv amplifică semnalul într-o rețea?",
			"Cum se numește sistemul care traduce nume de domenii în adrese IP?"
		],
		"answers": [
			"SMTP", "Router", "MAC", "TCP/IP", "Wi-Fi", "80", "LAN", "FTP", "Repeater", "DNS"
		]
	},
	{ # 4. Grafică pe Calculator
		"questions": [
			"Cum se numește dispozitivul principal de ieșire pentru grafică?",
			"Ce tip de grafică folosește pixeli?",
			"Care este abrevierea pentru “Red Green Blue”?",
			"Cum se numește memoria specială pentru stocarea imaginilor pe placă video?",
			"Ce model matematic reprezintă obiecte 3D ca set de puncte și muchii?",
			"Ce algoritm se folosește pentru umbrire realistă a suprafețelor?",
			"Care este prescurtarea pentru “Graphics Processing Unit”?",
			"Cum se numește conversia coordonatelor 3D în coordonate 2D pe ecran?",
			"Ce format de fișier imagine suportă transparență?",
			"Ce structură de date se folosește pentru a reprezenta culorile pe un pixel?"
		],
		"answers": [
			"Monitor", "Raster", "RGB", "VRAM", "Mesh", "Phong", "GPU", "Proiecție", "PNG", "Paletă"
		]
	},
	{ # 5. Elemente de Grafică pe Calculator
		"questions": [
			"Cum se numește punctul care formează imaginea pe un ecran?",
			"Cum se numește linia dintre două puncte într-o imagine vectorială?",
			"Ce este o succesiune de pixeli orizontali într-o imagine?",
			"Ce tip de obiect geometric are trei vârfuri?",
			"Cum se numește forma geometrică cu patru laturi egale?",
			"Care este sinonimul pentru imagine raster?",
			"Ce element grafic este folosit pentru desenarea cercurilor?",
			"Cum se numește procesul de umplere a unei forme cu culoare?",
			"Ce este o formă închisă cu margini netede în grafică vectorială?",
			"Cum se numește paleta folosită pentru culori pe 8 biți?"
		],
		"answers": [
			"Pixel", "Segment", "Linie", "Triunghi", "Pătrat", "Bitmap", "Arc", "Fill", "Curba Bézier", "Paletă"
		]
	},
	{ # 6. Inteligență Artificială
		"questions": [
			"Ce tip de AI învață din date?",
			"Cum se numește rețeaua folosită la recunoaștere imagini?",
			"Algoritmul popular pentru clasificare binară?",
			"Tip de AI care folosește straturi?",
			"Ce este RL în AI?",
			"Cum se numește procesul de corectare automată a greșelilor?",
			"Ce este NLP?",
			"Care este opusul “supervizat” în ML?",
			"Ce este o decizie bazată pe “if-then-else”?",
			"Cum se numește programul AI care joacă șah?"
		],
		"answers": [
			"Machine Learning", "Convoluțională", "Logistică", "Neurală", "Reinforcement Learning", "Backpropagation", "Procesare limbaj", "Nesupervizat", "Arbore", "Engine"
		]
	}
]

var current_test = 0
var score = 0


@onready var question_labels = [] 
@onready var answer_fields = []   
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var submit_button = $VBoxContainer/SubmitButton

func _ready():
	for i in range(10):
		answer_fields.append($VBoxContainer/GridContainer.get_node("Answer" + str(i)))
		question_labels.append($VBoxContainer/GridContainer.get_node("Question" + str(i)))
	load_test(current_test)
	score_label.text = ""
	submit_button.pressed.connect(_on_submit_pressed)

func load_test(index):
	var test = tests[index]
	for i in range(10):
		question_labels[i].text = str(i+1) + ". " + test["questions"][i]
		answer_fields[i].text = ""
		answer_fields[i].editable = true
		answer_fields[i].modulate = Color(1,1,1)
	score_label.text = "Test " + str(index+1) + "/6"
	submit_button.text = "Submit"

func _on_submit_pressed():
	var test = tests[current_test]
	var test_score = 0
	# Verificăm răspunsurile
	for i in range(10):
		var user_answer = answer_fields[i].text.strip_edges().capitalize()
		var correct_answer = test["answers"][i].capitalize()
		if user_answer == correct_answer:
			test_score += 1
			answer_fields[i].modulate = Color(0.8,1,0.8) # verde pal
		else:
			answer_fields[i].modulate = Color(1,0.8,0.8) # roșu pal
		answer_fields[i].editable = false
	score += test_score
	score_label.text = "Ai punctajul: %d/10 la acest test.\nTotal: %d/%d" % [test_score, score, (current_test+1)*10]
	if current_test < len(tests)-1:
		submit_button.text = "Următorul test"
		submit_button.pressed.disconnect(_on_submit_pressed)
		submit_button.pressed.connect(_on_next_test_pressed)
	else:
		submit_button.text = "Final"
		submit_button.disabled = true

func _on_next_test_pressed():
	current_test += 1
	load_test(current_test)
	submit_button.pressed.disconnect(_on_next_test_pressed)
	submit_button.pressed.connect(_on_submit_pressed)

extends Node2D

const DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
const SALI = ["D001","D002","D003","D004","D005","A004","A005","A007","C001","C002","C003","C004","C005","C006"]

@onready var animation_player = $AnimationPlayer
@onready var Hour: Label = %Hour
@onready var Minute: Label = %Minute
@onready var Day: Label = %Day
@onready var DayOfWeek: Label = %DayOfWeek

var day_counter = 1:
	set(value):
		day_counter = value
		Day.text = "Day " + str(day_counter)
		DayOfWeek.text = DAYS[day_counter % 7]

var intervale_cu_sali = []

var start_time = 8 * 60  

func _ready():
	randomize()
	Day.text = "Day 1"
	DayOfWeek.text = DAYS[day_counter % 7]
	genereaza_intervale()
	animation_player.seek(start_time / (24 * 60) * animation_player.current_animation_length, true)

func next_day():
	day_counter += 1
	genereaza_intervale()
	
func get_intervale_curente():
	return intervale_cu_sali
	
func genereaza_intervale():
	intervale_cu_sali.clear()
	var ore_posibile = [8, 10, 12, 14, 16, 18]
	ore_posibile.shuffle()
	for i in range(2):
		var ora = ore_posibile.pop_front() # ora de început
		var sala = SALI[randi() % SALI.size()]
		intervale_cu_sali.append({
			"ora": ora,
			"durata": 2,
			"sala": sala,
			"done": false
		})



func _physics_process(_delta):
	var current_time = animation_player.current_animation_position
	var total_time = animation_player.current_animation_length
	var minute_passed = (int)((current_time / total_time) * (24 * 60) + 480) % (24 * 60) 

	var hour_24 = int(minute_passed / 60) % 24
	var minute = int(minute_passed) % 60

	var hour_12 = hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12
	var period = "AM" if hour_24 < 12 else "PM"

	Hour.text = str(hour_12).pad_zeros(2) + " " + period
	Minute.text = str(minute).pad_zeros(2)

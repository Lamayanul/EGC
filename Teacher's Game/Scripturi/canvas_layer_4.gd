extends CanvasLayer # sau Control

@onready var start_button: Button = $start_button # sau calea corectă

func _ready():
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = true

	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().paused = false
	self.visible = false

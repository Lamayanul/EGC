extends Area2D

signal clicked(is_bug: bool)

@export var is_bug: bool = false
@export var speed := 150.0

func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 20:
		queue_free()  # scapă şi dispar la baza ecranului

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", is_bug)
		queue_free()

extends Control

func show_menu():
	modulate.a = 0.0
	show()

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.0
	hide()
	show_menu()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Control
@onready var showmenutimer: Timer = $Timer
func show_menu():
	modulate.a = 0.0
	show()

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	showmenutimer.start()
	showmenutimer.timeout.connect(timerout)
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func timerout():
	modulate.a = 0.0

	
	show_menu()

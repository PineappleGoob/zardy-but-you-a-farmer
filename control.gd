extends Control
@onready var showmenutimer: Timer = $Timer
@onready var respawnbutton: Button = $CenterContainer/VBoxContainer/Respawn
@onready var menubutton: Button = $CenterContainer/VBoxContainer/Menu
func show_menu():
	modulate.a = 0.0
	show()

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	showmenutimer.start()
	showmenutimer.timeout.connect(timerout)
	respawnbutton.pressed.connect(_respawn_button_press)
	menubutton.pressed.connect(_quit_button)
	hide()
	pass # Replace with function body.
func _respawn_button_press():
	get_tree().change_scene_to_file("res://RealMain.tscn")
func _quit_button():
	get_tree().quit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func timerout():
	modulate.a = 0.0

	
	show_menu()

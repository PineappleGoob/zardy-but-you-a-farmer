extends Area3D

func _on_body_entered(body):
	if body is CharacterBody3D:
		if body.name == 'player':
			body.plant4 = 1 
			print('test2')
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

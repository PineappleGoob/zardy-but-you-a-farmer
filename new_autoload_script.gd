extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.has_singleton("DialogueManager"):
		Engine.register_singleton("DialogueManager", self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

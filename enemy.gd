extends CharacterBody3D

@export var speed := 3

@onready var player: CharacterBody3D = $"../player"
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	navigation_agent.target_position = player.global_position
	

		
	var next_position = navigation_agent.get_next_path_position()
	var dir = global_position.direction_to(next_position)
	
	velocity.x =dir.x * speed
	velocity.z = dir.z * speed
	
	move_and_slide()

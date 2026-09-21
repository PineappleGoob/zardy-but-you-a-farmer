extends CharacterBody3D


const SPEED = 15.0
const JUMP_VELOCITY = 4.5
var mouse_sensitivity = 0.002
var health = 1
var farmtalk = 0
var farmtalking = 0
var dialogue1 = load("res://test.dialogue")
var ratdialogue = load("res://rat.dialogue")
var rattalk = 0
var rattalking = 0



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DialogueManager.dialogue_ended.connect(_dialogue_end)
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
		
	#print(farmtalking)
	if farmtalk == 1 && farmtalking == 0:
		farmtalk = 0
		farmtalking = 1
		farmchat()
	if rattalk == 1 && rattalking == 0:
		rattalk = 0
		farmtalking = 1
		ratchat()

	if health == 0:
		print('test3')
		get_tree().change_scene_to_file("res://jumpscare.tscn")
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if farmtalking == 0:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()


func farmchat():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	DialogueManager.show_dialogue_balloon(dialogue1, "start")
	
func ratchat():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	DialogueManager.show_dialogue_balloon(ratdialogue, "start")
	
func _dialogue_end(resource):
	if resource == dialogue1 or resource == ratdialogue:
		print('dial')
		farmtalking = 0
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	

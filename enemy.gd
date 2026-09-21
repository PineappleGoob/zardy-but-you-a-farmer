extends CharacterBody3D

enum State { IDLE, CHASING }
var current_state: State = State.IDLE
@export var speed := 3
@export var me_ol_eyes := 15

@onready var player: CharacterBody3D = $"../player"
@onready var nav_ag: NavigationAgent3D = $NavigationAgent3D
@onready var eyeline: RayCast3D = $VisionRay
@onready var welp_lost_them: Timer = $lose_track
@onready var patroltime: Timer = $patrol_timer
@onready var patroltimeout: Timer = $patroltimeout
var patrol_target: Vector3 = Vector3.ZERO
var is_waiting: bool = false
var patrolistimedout: bool = false
func _ready():
	print('enemy init')
	# Wait for the first physics frame so the NavigationServer is ready
	await get_tree().physics_frame
	
	welp_lost_them.timeout.connect(_on_lose_track_timer_timeout)
	patroltime.timeout.connect(_on_patrol_wait_timer_timeout)
	patroltimeout.timeout.connect(_on_patrol_timeout_timer_timeout)
	point_randomizing_commense()

func _physics_process(delta: float):
	check_vision()
	
	# Safety check: if the map isn't ready, do nothing
	if NavigationServer3D.map_get_iteration_id(nav_ag.get_navigation_map()) == 0:
		return

	match current_state:
		State.IDLE:
			if is_waiting:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
				move_and_slide()
				return
			
			nav_ag.target_position = patrol_target
			
			var current_pos = global_position
			var target_pos = patrol_target
			current_pos.y = 0
			target_pos.y = 0
			
			# Check if we are close enough to the target
			if current_pos.distance_to(target_pos) < 5.2 or patrolistimedout == true:
				is_waiting = true
				patrolistimedout = false
				patroltime.start()
				return
				
			move_along_path(delta)
			
		State.CHASING:
			nav_ag.target_position = player.global_position
			move_along_path(delta)

func move_along_path(delta: float):
	if nav_ag.is_navigation_finished():
		return
		
	var next_position = nav_ag.get_next_path_position()
	var dir = global_position.direction_to(next_position)
	dir.y = 0
	dir = dir.normalized()
	
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
		
	move_and_slide()

func check_vision():
	var player_dist = global_position.distance_to(player.global_position)
	
	if player_dist > me_ol_eyes:
		player_be_gone()
		return

	eyeline.global_position = global_position + Vector3(0,1,0)
	var targ_eye_level = player.global_position + Vector3(0,1,0)
	eyeline.target_position = eyeline.to_local(targ_eye_level)
	eyeline.force_raycast_update()
	
	if eyeline.is_colliding():
		var collidor = eyeline.get_collider()
		if collidor == player:
			if current_state == State.IDLE:
				is_waiting = false
				patroltime.stop()
			current_state = State.CHASING
			welp_lost_them.stop()
		else:
			player_be_gone()
	else:
		player_be_gone()

func player_be_gone():
	if current_state == State.CHASING and welp_lost_them.is_stopped():
		welp_lost_them.start()

func _on_patrol_wait_timer_timeout():
	is_waiting = false
	point_randomizing_commense()
	patroltimeout.start()
	
func _on_patrol_timeout_timer_timeout():
	patrolistimedout = true

func _on_lose_track_timer_timeout():
	current_state = State.IDLE
	point_randomizing_commense()

func point_randomizing_commense():
	var map_rid = nav_ag.get_navigation_map()
	var nav_layers = nav_ag.navigation_layers
	
	var valid_point_found = false
	var attempts = 0
	
	# Try 10 times to find a point that actually has a path to it
	while not valid_point_found and attempts < 10:
		attempts += 1
		var random_point = NavigationServer3D.map_get_random_point(map_rid, nav_layers, true)
		
		# We ask the server: "If I stand here, can I walk to that random point?"
		var path = NavigationServer3D.map_get_path(map_rid, global_position, random_point, true)
		
		# If the path has points (size > 0), it's reachable!
		if path.size() > 0:
			patrol_target = random_point
			valid_point_found = true
			
	if not valid_point_found:
		# If we failed 10 times, just stay put to avoid crashing
		patrol_target = global_position

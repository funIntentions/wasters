extends KinematicBody2D

const CLOSED = 0
const OPEN = 1
const OPENING = 2
const CLOSING = 3
const State = {CLOSED = 0, OPEN = 1, OPENING = 2, CLOSING = 3}

const FORCE = 200

export var time_to_open = 0.5

var current_state = State.CLOSED
var current_state_time = 0.0
var state_length = 0.0
var velocity = Vector2()

onready var skull_bottom = get_node("skull_bottom")
var laser_height = 0.0
var laser_length = 0.0
var laser_previous_height = 0.0
var laser_previous_length = 0.0
var laser_max_length = 600.0
var laser_max_height = 50.0

var laser_shape;
onready var laser = get_node("laser")

func _ready():
	set_fixed_process(true)
	set_process(true)
	#print("States: CLOSED = 0, OPEN = 1, OPENING = 2, CLOSING = 3")
	
	laser_length = laser_max_length
	laser_shape = RectangleShape2D.new()

func _process(delta):
	
	# Update the mouth
	if Input.is_action_pressed("fire"):
		if current_state == State.CLOSED:
			set_state(State.OPENING)
	elif current_state == State.OPENING or current_state == State.OPEN:
		set_state(State.CLOSING)
	
	update_state(delta)


func update_state(delta):
	if state_length > 0.0:
		current_state_time += delta
		var percentage_done = clamp(current_state_time / state_length, 0.0, 1.0)
		if percentage_done >= 1.0:
			#print("%:", percentage_done, ", current time:", current_state_time, ", state_length:", state_length)
			#print("laser {length: ", laser_length, ", height: ", laser_height,"}")
			if current_state == State.OPENING:
				set_state(State.OPEN)
			elif current_state == State.CLOSING:
				set_state(State.CLOSED)
		
		if current_state == State.OPENING:
			laser_height = lerp(0.0, laser_max_height, percentage_done)
		elif current_state == State.CLOSING:
			laser_height = lerp(laser_previous_height, 0.0, percentage_done)
		
		laser.set_laser_extents(laser_length, laser_height)

func set_state(state):
	
	if state == State.OPENING:
		state_length = time_to_open
	elif state == State.CLOSING:
		if current_state == State.OPENING:
			state_length = current_state_time
		elif current_state == State.OPEN:
			state_length = time_to_open
	else:
		state_length = 0.0
	
	if state != State.CLOSED:
		laser.set_active(true)
	else:
		laser.set_active(false)
	
	laser_previous_length = laser_length
	laser_previous_height = laser_height
	current_state = state
	current_state_time = 0.0
	
	#print("new state: ", state)
	#print("current time:", current_state_time, ", state_length:", state_length)

func _fixed_process(delta):
	
	var direction = Vector2(0,0)
	if Input.is_action_pressed("move_up"):
		direction.y -= 1;
	if Input.is_action_pressed("move_down"):
		direction.y += 1;
	if Input.is_action_pressed("move_left"):
		direction.x -= 1;
	if Input.is_action_pressed("move_right"):
		direction.x += 1;
	
	velocity += direction * delta * FORCE
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
extends KinematicBody2D

const CLOSED = 0
const OPEN = 1
const OPENING = 2
const CLOSING = 3
const State = {CLOSED = 0, OPEN = 1, OPENING = 2, CLOSING = 3}

const FORCE = 200

export var time_to_open = 0.5
export var brain_juice_max = 100.0

onready var brain_juice = brain_juice_max

var current_state = State.CLOSED
var current_state_time = 0.0
var state_length = 0.0
var velocity = Vector2()

onready var skull_bottom = get_node("skull_bottom")
onready var laser = get_node("laser")

onready var animation_player = get_node("Open Jaw 2")
var prev_anim_time = 0.0

func _ready():
	set_fixed_process(true)
	set_process(true)
	#print("States: CLOSED = 0, OPEN = 1, OPENING = 2, CLOSING = 3")

	animation_player.set_current_animation("Open Jaw")

func _process(delta):
	
	var mouse_pos = get_viewport().get_mouse_pos()
	var position_from = get_pos() + laser.get_laser_offset()
	var angle_to = position_from.angle_to_point(mouse_pos) - PI/2
	
	if abs(angle_to) > PI/2:
		flip_sprites(true)
		set_rot(angle_to)
	else:
		flip_sprites(false)
		set_rot(angle_to)
	
	#set_rot(angle_to)
	
	# Update the mouth
	if Input.is_action_pressed("fire"):
		if current_state == State.CLOSED:
			set_state(State.OPENING)
	elif current_state == State.OPENING or current_state == State.OPEN:
		set_state(State.CLOSING)
	
	update_state(delta)

func flip_sprites(state):
	if state:
		set_scale(Vector2(1, -1))
	else:
		set_scale(Vector2(1, 1))

func get_brain_juice():
	return brain_juice

func update_state(delta):
	var length = animation_player.get_current_animation_length()
	
	if state_length > 0.0:
		current_state_time += delta
		var percentage_done = clamp(current_state_time / state_length, 0.0, 1.0)
			#print("%:", percentage_done, ", current time:", current_state_time, ", state_length:", state_length)
			#print("laser {length: ", laser_length, ", height: ", laser_height,"}")
		if current_state == State.OPENING:
			var anim_time = lerp(0.0, length, percentage_done)
			animation_player.seek(anim_time, true)
			if percentage_done >= 1.0:
				set_state(State.OPEN)
		elif current_state == State.CLOSING:
			var anim_time = lerp(prev_anim_time, 0.0, percentage_done)
			animation_player.seek(anim_time, true)
			if percentage_done >= 1.0:
				set_state(State.CLOSED)
	
	if current_state != State.CLOSED:
		brain_juice -= delta

func set_state(state):
	
	if state == State.OPENING:
		state_length = time_to_open
	elif state == State.CLOSING:
		if current_state == State.OPENING:
			state_length = current_state_time
		elif current_state == State.OPEN:
			state_length = time_to_open
		prev_anim_time = animation_player.get_current_animation_pos()
	else:
		state_length = 0.0
	
	if state != State.CLOSED:
		laser.set_active(true)
	else:
		laser.set_active(false)
	
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
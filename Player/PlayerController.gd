extends KinematicBody2D

const CLOSED = 0
const OPEN = 1
const OPENING = 2
const CLOSING = 3
const State = {CLOSED = 0, OPEN = 1, OPENING = 2, CLOSING = 3}

export var accel = 800

export var time_to_open = 0.5
export var brain_juice_max = 100.0

onready var brain_juice = brain_juice_max

var current_state = State.CLOSED
var current_state_time = 0.0
var state_length = 0.0
var velocity = Vector2()

onready var skull_bottom = get_node("skull_bottom")
onready var laser = get_node("laser")

onready var jaw_animation_player = get_node("Open Jaw 2")
var prev_jaw_anim_time = 0.0
onready var skull_animation_player = get_node("Open Skull")
var prev_skull_anim_time = 0.0
onready var laser_animation_player = get_node("Laser Open")
var prev_laser_anim_time = 0.0
onready var death_animation_player = get_node("Brain Blast 2")

export var max_velocity = 600.0
export var deaccel = 50.0

var is_dead = false

func kill():
	if is_dead:
		return
	is_dead = true
	var brain_blast = get_node("brain_blast")
	brain_blast.show()
	var skull = get_node("skull")
	skull.hide()
	death_animation_player.play("Brain Blast")
	
	if current_state != State.CLOSED:
		set_state(State.CLOSING)

func _ready():
	set_fixed_process(true)
	set_process(true)
	#print("States: CLOSED = 0, OPEN = 1, OPENING = 2, CLOSING = 3")

	jaw_animation_player.set_current_animation("Open Jaw")
	skull_animation_player.set_current_animation("Open Skull")
	laser_animation_player.set_current_animation("LaserOpen")

func _process(delta):
	
	if brain_juice <= 0.0:
		brain_juice = 0.0
		kill()
	
	if is_dead:
		return
	
	var mouse_pos = get_viewport().get_mouse_pos()
	var position_from = get_pos()
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
	var jaw_length = jaw_animation_player.get_current_animation_length()
	var skull_length = skull_animation_player.get_current_animation_length()
	var laser_length = laser_animation_player.get_current_animation_length()
	
	if state_length > 0.0:
		current_state_time += delta
		var percentage_done = clamp(current_state_time / state_length, 0.0, 1.0)
			#print("%:", percentage_done, ", current time:", current_state_time, ", state_length:", state_length)
			#print("laser {length: ", laser_length, ", height: ", laser_height,"}")
		if current_state == State.OPENING:
			var jaw_anim_time = lerp(0.0, jaw_length, percentage_done)
			jaw_animation_player.seek(jaw_anim_time, true)
			var skull_anim_time = lerp(0.0, skull_length, percentage_done)
			skull_animation_player.seek(skull_anim_time, true)
			var laser_anim_time = lerp(0.0, laser_length, percentage_done)
			laser_animation_player.seek(laser_anim_time, true)
			if percentage_done >= 1.0:
				set_state(State.OPEN)
		elif current_state == State.CLOSING:
			var jaw_anim_time = lerp(prev_jaw_anim_time, 0.0, percentage_done)
			jaw_animation_player.seek(jaw_anim_time, true)
			var skull_anim_time = lerp(prev_skull_anim_time, 0.0, percentage_done)
			skull_animation_player.seek(skull_anim_time, true)
			var laser_anim_time = lerp(prev_laser_anim_time, 0.0, percentage_done)
			laser_animation_player.seek(laser_anim_time, true)
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
		prev_jaw_anim_time = jaw_animation_player.get_current_animation_pos()
		prev_skull_anim_time = skull_animation_player.get_current_animation_pos()
		prev_laser_anim_time = laser_animation_player.get_current_animation_pos()
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
	
	var direction = Vector2()
	if current_state == State.OPEN or current_state == State.OPENING:
		direction = get_global_transform().x
	#elif current_state == State.CLOSING:
	#	direction = -get_global_transform().x
	
	velocity += direction * delta * accel
	
	if velocity.length() >= max_velocity:
		velocity = velocity.normalized() * max_velocity
	
	if velocity.length() >= 1:
		velocity -= velocity.normalized()  * delta * deaccel
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
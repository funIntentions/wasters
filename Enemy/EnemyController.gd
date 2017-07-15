extends KinematicBody2D

const SPEED = 200.0
const DECEL = 500.0
var velocity = Vector2()

export var max_health = 100.0
onready var health = max_health

var damage_taken = 0.0
var damage_force = 0.0

func _fixed_process(delta):
	
	var player = get_node("../player")
	var direction_to_player = player.get_pos() - get_pos()
	direction_to_player = direction_to_player.normalized()
	
	if damage_taken > 0.0:
		velocity += -direction_to_player * delta * damage_force
		damage_taken = 0.0
	else:
		velocity += direction_to_player * delta * SPEED
	
	#if velocity.normalized().dot(direction_to_player) < 0:
	#	velocity += -velocity.normalized() * delta * DECEL
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

func take_damage(damage, force):
	health -= damage
	damage_taken = damage
	damage_force = force
	
	if health <= 0.0:
		health = 0.0
		print("dead")

func _ready():
	set_fixed_process(true)
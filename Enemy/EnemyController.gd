extends KinematicBody2D

const SPEED = 200.0
const DECEL = 500.0
var velocity = Vector2()

func _fixed_process(delta):
	
	var player = get_node("../player")
	var direction_to_player = player.get_pos() - get_pos()
	direction_to_player = direction_to_player.normalized()
	
	velocity += direction_to_player * delta * SPEED
	
	if velocity.normalized().dot(direction_to_player) < 0:
		velocity += -velocity.normalized() * delta * DECEL
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

func _ready():
	set_fixed_process(true)
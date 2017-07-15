extends KinematicBody2D

const MAX_SPEED = 50.0
const DECEL = 500.0
var velocity = Vector2()
var prev_velocity = Vector2()

export var max_health = 100.0
onready var health = max_health

export var alignment_distance = 1000.0
export var alignment_weight = 1.0
export var cohesion_weight = 1.0
export var separation_weight = 1.0

var damage_taken = 0.0
var damage_force = 0.0

func get_prev_velocity():
	return prev_velocity

func compute_alignment():
	var desired_vel = Vector2()
	var neighbour_count = 0
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy == self:
			continue
		
		if (enemy.get_pos().distance_to(get_pos()) <= alignment_distance):
			desired_vel += enemy.get_prev_velocity()
			neighbour_count += 1
	
	if neighbour_count == 0:
		return desired_vel
	
	desired_vel.x /= neighbour_count
	desired_vel.y /= neighbour_count
	
	return desired_vel.normalized() * MAX_SPEED

func compute_cohesion():
	var center_of_mass = Vector2()
	var neighbour_count = 0
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy == self:
			continue
		
		if (enemy.get_pos().distance_to(get_pos()) <= alignment_distance):
			center_of_mass += enemy.get_pos()
			neighbour_count += 1
	
	if neighbour_count == 0:
		return center_of_mass
	
	center_of_mass.x /= neighbour_count
	center_of_mass.y /= neighbour_count
	
	var direction_to_center_of_mass = center_of_mass - get_pos()
	
	return direction_to_center_of_mass.normalized() * MAX_SPEED

func compute_separation():
	var desired_vel = Vector2()
	var neighbour_count = 0
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy == self:
			continue
		
		if (enemy.get_pos().distance_to(get_pos()) <= alignment_distance):
			var to_enemy = (enemy.get_pos() - get_pos())
			desired_vel += to_enemy.normalized()
			neighbour_count += 1
	
	if neighbour_count == 0:
		return desired_vel
	
	desired_vel.x /= neighbour_count
	desired_vel.y /= neighbour_count
	desired_vel.x *= -1
	desired_vel.y *= -1
	
	return desired_vel.normalized() * MAX_SPEED

func compute_seek(target_pos):
	var desired_vel = Vector2(0,0)
	
	var to_target = target_pos - get_pos()
	
	desired_vel = to_target.normalized() * MAX_SPEED
	
	return desired_vel

func calculate_target_center_of_mass():
	var center_of_mass = Vector2()
	var neighbour_count = 0
	
	var targets = get_tree().get_nodes_in_group("target")
	for target in targets:
		if target == self:
			continue
		
		if (target.get_pos().distance_to(get_pos()) <= alignment_distance):
			center_of_mass += target.get_pos()
			neighbour_count += 1
	
	if neighbour_count == 0:
		return center_of_mass
	
	center_of_mass.x /= neighbour_count
	center_of_mass.y /= neighbour_count
	
	return center_of_mass

func _fixed_process(delta):
	
	var target_center_of_mass = calculate_target_center_of_mass()
	
	var alignment = compute_alignment()
	var cohesion = compute_cohesion()
	var separation = compute_separation()
	var seek = compute_seek(target_center_of_mass)
	
	velocity += cohesion * cohesion_weight + separation * separation_weight + alignment * alignment_weight
	
	var speed = velocity.length()
	
	if speed > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
	
	# Store the prev_velocity that other enemies will use in movement calculations.
	prev_velocity = velocity
	#screen_size = get_viewport_rect().size
	

func take_damage(damage, force):
	health -= damage
	damage_taken = damage
	damage_force = force
	
	if health <= 0.0:
		health = 0.0
		print("dead")

func _ready():
	set_fixed_process(true)
	#velocity = Vector2(randf(), randf())

func temp(delta):
	var player = get_node("../player")
	var direction_to_player = player.get_pos() - get_pos()
	direction_to_player = direction_to_player.normalized()
	
	if damage_taken > 0.0:
		velocity += -direction_to_player * delta * damage_force
		damage_taken = 0.0
	else:
		velocity += direction_to_player * delta * MAX_SPEED
	
	#if velocity.normalized().dot(direction_to_player) < 0:
	#	velocity += -velocity.normalized() * delta * DECEL
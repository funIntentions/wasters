extends Node2D

var laser_height = 0.0
var laser_length = 0.0
var is_active = false

export var damage_per_second = 100.0
export var damage_force = 500

func _ready():
	set_process(true)

func set_laser_extents(length, height):
	laser_length = length
	laser_height = height

func set_active(state):
	is_active = state

func _draw():
	if not is_active:
		return
	
	var height_offset = 50
	var laser_position = Vector2(-laser_length, height_offset)
	var laser_rect = Rect2(laser_position, Vector2(laser_length, laser_height))
	draw_rect(laser_rect, Color(0.0, 1.0, 0.0, 1.0))

func _process(delta):
	# Update draw method
	update()
	
	if not is_active:
		return
	
	var height_offset = 50
	var laser_position = Vector2(-laser_length, height_offset)
	var laser_rect = Rect2(laser_position + get_global_pos(), Vector2(laser_length, laser_height))
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if laser_rect.has_point(enemy.get_pos()):
			enemy.take_damage(damage_per_second * delta, damage_force)
			#print("hit")


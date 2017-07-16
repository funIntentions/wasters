extends Node2D

var laser_height = 0.0
var is_active = false

export var laser_length = 600.0
export var damage_per_second = 100.0
export var damage_force = 500
export var top_margin = 0
export var bottom_margin = 20
var number_of_rays = 1
var ray_pixel_offset = 20

onready var jaw = get_node("../jaw")

func _ready():
	set_process(true)
	set_fixed_process(true)
	 

func set_active(state):
	is_active = state

func get_laser_offset():
	return Vector2(0.0, laser_height - bottom_margin)

func _draw():
	draw_set_transform_matrix(get_global_transform().affine_inverse())
	
	var up = get_global_transform().y
	var forward = -get_global_transform().x
	var ray_start = up * number_of_rays * ray_pixel_offset
	var ray_end = ray_start + forward * laser_length
	
	for ray in range(number_of_rays):
		draw_circle(get_global_pos() + ray_start, 10, Color(0.0, 1.0, 0.0, 1.0))
		draw_circle(get_global_pos() + ray_end, 10, Color(1.0, 0.0, 0.0, 1.0))
		ray_start -= up * ray_pixel_offset
		ray_end -= up * ray_pixel_offset
	
	if not is_active:
		return
		
	
	#var laser_position = Vector2(-laser_length, top_margin)
	#var laser_rect = Rect2(laser_position, Vector2(laser_length, laser_height - bottom_margin))
	#draw_rect(laser_rect, Color(0.0, 1.0, 0.0, 1.0))

func segment_cast(begin_pos, end_pos):
	var space_state = get_world_2d().get_direct_space_state()
	
	var segment = SegmentShape2D.new()
	segment.set_a(begin_pos)
	segment.set_b(end_pos)
	
	var query = Physics2DShapeQueryParameters.new()
	#query.set_transform(get_global_transform().affine_inverse())
	query.set_shape(segment)
	query.set_exclude([self]) # If you want to exclude the object casting the segment
	#query.set_layer_mask(GROUND_MASK) # Set the collision mask you want, or none if you want to hit anything
	
	var hits = space_state.intersect_shape(query, 32)
	return hits

func _fixed_process(delta):
	var space_state = get_world_2d().get_direct_space_state()
	# use global coordinates, not local to node
	var up = -get_global_transform().y
	var forward = -get_global_transform().x
	#var ray_start = get_global_pos() + (up * number_of_rays * ray_pixel_offset)
	#var ray_end = get_global_pos() + ray_start + (forward * laser_length)
	
	var ray_start = get_global_pos()
	var ray_end = get_global_pos() + forward * laser_length
	var dir = ray_end - ray_start
	
	var hits = segment_cast(ray_start, ray_end)
	
	for hit in hits:
		if (not hit.empty() and hit.collider.is_in_group("enemy")):
			hit.collider.take_damage(damage_per_second * delta, damage_force, dir)
	
	return
	for ray in range(number_of_rays):
		ray_start -= up * ray_pixel_offset
		ray_end -= up * ray_pixel_offset
		
		var hits = segment_cast(ray_start, ray_end)
		
		for hit in hits:
			if (not hit.empty() and hit.collider.is_in_group("enemy")):
				print("hit")

func _process(delta):
	# Update draw method
	update()
	
	return
	
	laser_height = jaw.get_pos().y - get_pos().y
	
	var laser_position = Vector2(-laser_length, top_margin)
	var laser_rect = Rect2(laser_position + get_global_pos(), Vector2(laser_length, laser_height - bottom_margin))
	var laser_direction = Vector2(-1,0).rotated(get_global_transform().get_rotation())
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if laser_rect.has_point(enemy.get_pos()):
			enemy.take_damage(damage_per_second * delta, damage_force, laser_direction)
			print("hit")


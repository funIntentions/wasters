extends Node2D

var laser_height = 0.0
var laser_length = 0.0

func _ready():
	set_process(true)

func set_laser_extents(length, height):
	laser_length = length
	laser_height = height

func _draw():
	var height_offset = 50
	var laser_position = Vector2(-laser_length, height_offset)
	var laser_rect = Rect2(laser_position, Vector2(laser_length, laser_height))
	draw_rect(laser_rect, Color(0.0, 1.0, 0.0, 1.0))

func _process(delta):
	
	var height_offset = 50
	var laser_position = Vector2(-laser_length, height_offset)
	var laser_rect = Rect2(laser_position + get_global_pos(), Vector2(laser_length, laser_height))
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if laser_rect.has_point(enemy.get_pos()):
			print("hit")
	
	update()

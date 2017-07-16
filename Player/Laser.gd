extends Node2D

var laser_height = 0.0
var is_active = false

export var laser_length = 600.0
export var damage_per_second = 100.0
export var damage_force = 500
export var top_margin = 100
export var bottom_margin = 20


onready var jaw = get_node("../jaw")

func _ready():
	set_process(true)

func set_active(state):
	is_active = state

func _draw():
	if not is_active:
		return
	
	var laser_position = Vector2(-laser_length, top_margin)
	var laser_rect = Rect2(laser_position, Vector2(laser_length, laser_height - bottom_margin))
	draw_rect(laser_rect, Color(0.0, 1.0, 0.0, 1.0))

func _process(delta):
	# Update draw method
	update()
	
	if not is_active:
		return
	
	laser_height = jaw.get_pos().y - get_pos().y
	
	var laser_position = Vector2(-laser_length, top_margin)
	var laser_rect = Rect2(laser_position + get_global_pos(), Vector2(laser_length, laser_height - bottom_margin))
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if laser_rect.has_point(enemy.get_pos()):
			enemy.take_damage(damage_per_second * delta, damage_force)
			#print("hit")


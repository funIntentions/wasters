extends Label

export(NodePath) var player_path
var player
var juice

func _ready():
	set_process(true)
	player = get_node(player_path)
	juice = get_node("juice_value")

func _process(delta):
	assert(player != null and juice != null)
	var brain_juice = player.get_brain_juice()
	juice.set_text(String(brain_juice))
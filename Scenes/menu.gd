extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func button_pressed():
	get_node("/root/Global").goto_scene("res://Scenes/Level 1.tscn")

func _ready():
	get_node("Button").connect("pressed", self, "button_pressed")


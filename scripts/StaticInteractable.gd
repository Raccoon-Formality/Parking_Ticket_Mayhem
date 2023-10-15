extends StaticBody
class_name StaticInteractable


onready var player = get_tree().get_nodes_in_group("player")[0]
#onready var player = get_tree().get_nodes_in_group("player")[0]
#onready var world = get_tree().root.get_node("world")
var random_generator = RandomNumberGenerator.new()

func interact(pos, normal, force, gun):
	pass

func continuos_interact():
	pass

func not_interact():
	pass

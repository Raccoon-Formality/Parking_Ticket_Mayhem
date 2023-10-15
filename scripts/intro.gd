extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://scenes/world.tscn")

func _on_introAnimation_animation_finished(anim_name):
	get_tree().change_scene("res://scenes/world.tscn")

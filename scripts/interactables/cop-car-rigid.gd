extends RigidInteractable

onready var thingInstance = preload("res://scenes/particles/hitParts.tscn")
var overlay_alpha = 0.0
var explode = false

func _ready():
	$Car5_Police.material_overlay = $Car5_Police.material_overlay.duplicate()
	random_generator.randomize()

func _process(delta):
	if global_translation.y < -10 and not explode:
		get_parent().queue_free()

func interact(pos, normal, force, gun):
	if overlay_alpha != 1.0 and not explode:
		var impusle_pos = pos - global_translation
		impusle_pos.y -= 2.0
		apply_impulse(impusle_pos, normal * -20.0 * force)
		var myObject = thingInstance.instance()
		myObject.transform.origin = pos
		myObject.emitting = true
		myObject.money = random_generator.randi_range(100,13120) * force
		Global.score += myObject.money
		myObject.direction = normal
		myObject.scale.x = force
		myObject.scale.y = force
		myObject.scale.z = force
		get_tree().root.add_child(myObject)
		overlay_alpha += 0.2 * force
		overlay_alpha = clamp(overlay_alpha, 0.0, 1.0)
		$Car5_Police.material_overlay.set_shader_param("alpha", overlay_alpha)
	elif overlay_alpha == 1.0 and not explode:
		remove_from_group("Interactable")
		var myObject = thingInstance.instance()
		myObject.transform.origin = pos
		myObject.emitting = true
		myObject.money = 69420
		myObject.direction = normal
		myObject.scale.x = 3
		myObject.scale.y = 3
		myObject.scale.z = 3
		get_tree().root.add_child(myObject)
		explode = true
		$fire1.show()
		$explodeSound.play()
		apply_central_impulse(Vector3(0,25,0))
		Global.score += 69420
		yield(get_tree().create_timer(2.0), "timeout")
		$CollisionShape.queue_free()
		yield(get_tree().create_timer(10.0), "timeout")
		get_parent().queue_free()
	

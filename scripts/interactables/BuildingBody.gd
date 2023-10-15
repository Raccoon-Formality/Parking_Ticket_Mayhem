extends StaticInteractable


onready var thingInstance = preload("res://scenes/particles/hitParts.tscn")
var overlay_alpha = 0.0
var explode = false

func _ready():
	$buidlingModel/IndustrialBuilding/IndustrialBuildingFront.material_overlay = $buidlingModel/IndustrialBuilding/IndustrialBuildingFront.material_overlay.duplicate()
	$buidlingModel/IndustrialBuilding2/IndustrialBuildingFront.material_overlay = $buidlingModel/IndustrialBuilding/IndustrialBuildingFront.material_overlay
	$buidlingModel/IndustrialBuilding3/IndustrialBuildingFront.material_overlay = $buidlingModel/IndustrialBuilding/IndustrialBuildingFront.material_overlay
	$buidlingModel/IndustrialBuilding4/IndustrialBuildingFront.material_overlay = $buidlingModel/IndustrialBuilding/IndustrialBuildingFront.material_overlay
	random_generator.randomize()

var shakeAmount = 0.25
var shakeLength = 5
var shaking = shakeLength

func _process(delta):
	if not explode:
		$buidlingModel.translation = lerp($buidlingModel.translation,Vector3.ZERO,0.25)
		shaking += 1
		if shaking < shakeLength:
			$buidlingModel.translation = Vector3(rand_range(-shakeAmount,shakeAmount),rand_range(-shakeAmount,shakeAmount),rand_range(-shakeAmount,shakeAmount))
	else:
		global_translation.y = lerp(global_translation.y,-25,0.01)

func interact(pos, normal, force, gun):
	if overlay_alpha != 1.0 and not explode:
		shaking = 5 + (-5 * force)
		var myObject = thingInstance.instance()
		myObject.transform.origin = pos
		myObject.emitting = true
		myObject.money = random_generator.randi_range(3000,16000) * force
		Global.score += myObject.money
		myObject.direction = normal
		myObject.scale.x = force
		myObject.scale.y = force
		myObject.scale.z = force
		get_tree().root.add_child(myObject)
		overlay_alpha += 0.1 * force
		overlay_alpha = clamp(overlay_alpha, 0.0, 1.0)
		$buidlingModel/IndustrialBuilding/IndustrialBuildingFront.material_overlay.set_shader_param("alpha", overlay_alpha)
	elif overlay_alpha >= 1.0 and not explode:
		remove_from_group("Interactable")
		var myObject = thingInstance.instance()
		myObject.transform.origin = pos
		myObject.emitting = true
		myObject.money = 6942000
		myObject.direction = normal
		myObject.scale.x = 3
		myObject.scale.y = 3
		myObject.scale.z = 3
		get_tree().root.add_child(myObject)
		shaking = 5 + (-5 * force)
		explode = true
		get_parent().get_node("BuildingParts").emitting = true
		$fire1.show()
		$explodeSound.play()
		#apply_central_impulse(Vector3(0,25,0))
		Global.score += 6942000
		yield(get_tree().create_timer(2.0), "timeout")
		#$CollisionShape.queue_free()
		yield(get_tree().create_timer(10.0), "timeout")
		get_parent().queue_free()



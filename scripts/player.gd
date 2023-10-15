extends KinematicBody

onready var camera = $Pivot/Camera
onready var raycast = $Pivot/RayCast

var gravity = -40
var max_speed = 15
var mouse_sensitivity = 0.004 #0.01  # radians/pixel
var jump_force = 10

var velocity = Vector3()
var lerp_velocity = Vector3.ZERO

var specialReady = false
var holdTime = 0


func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	
	if Input.is_action_pressed("ui_up"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("ui_down"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("ui_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("ui_right"):
		input_dir += global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir

var baseballBat = true
var gun = false

func _unhandled_input(event):
	if get_parent().player_active and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation_degrees.x = clamp($Pivot.rotation_degrees.x, -90, 90)
	if get_parent().player_active and event is InputEventMouseButton:
		if event.is_action_pressed("mouse_wheel"):
			change_weapon()

func change_weapon():
	if get_parent().ended == false:
		if baseballBat:
			baseballBat = false
			$ui/Baseballbat.hide()
			gun = true
			$ui/Gun.show()
			$Pivot/RayCast.cast_to = Vector3(0,0,-1000)
		elif gun:
			gun = false
			$ui/Gun.hide()
			baseballBat = true
			$ui/Baseballbat.show()
			$Pivot/RayCast.cast_to = Vector3(0,0,-8)

var gunCount = 0

func _physics_process(delta):
	if get_parent().player_active:
		velocity.y += gravity * delta

		var desired_velocity = get_input() * max_speed

		velocity.x = desired_velocity.x
		velocity.z = desired_velocity.z
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y += jump_force
		
		var goal_velocity = velocity
		lerp_velocity.y = goal_velocity.y
		lerp_velocity.x = lerp(lerp_velocity.x,goal_velocity.x,0.1)
		lerp_velocity.z = lerp(lerp_velocity.z,goal_velocity.z,0.1)
		velocity = move_and_slide(lerp_velocity, Vector3.UP, false, 4, 0.0, false)
		
		$ui/moneyLabel.text = "$" + str(format_number(Global.score))
		
		if Input.is_action_pressed("mouse_click"):
			holdTime += 1
		
		if holdTime > 15 and not specialReady:
			$ui/AnimationPlayer.play("hold")
		
		if not specialReady and holdTime > 30:
			specialReady = true
			$ui/AnimationPlayer.play("holdSpecial")
		
		if baseballBat:
			if Input.is_action_just_released("mouse_click"):
				var rayforce = 0
				if holdTime > 30:
					rayforce = 2.0
				else:
					rayforce = 1.0
				holdTime = 0
				specialReady = false
				$ui/AnimationPlayer.play("swing")
				var raycast_got = raycast.get_collider()
				if raycast.is_colliding() and (raycast_got is RigidInteractable or raycast_got is StaticInteractable):
					var rayPoint = raycast.get_collision_point()
					var rayNormal = raycast.get_collision_normal()
					raycast_got.interact(rayPoint, rayNormal, rayforce, false)
					if rayforce == 1.0:
						$hitSound.play()
					else:
						$hardhitSound.play()
		elif gun:
			if Input.is_action_pressed("mouse_click"):
				gunCount += 1
				if gunCount%5 == 0:
					$hitSound.play()
					var rayforce = 1.0
					var raycast_got = raycast.get_collider()
					if raycast.is_colliding() and (raycast_got is RigidInteractable or raycast_got is StaticInteractable):
						var rayPoint = raycast.get_collision_point()
						var rayNormal = raycast.get_collision_normal()
						raycast_got.interact(rayPoint, rayNormal, rayforce, true)
		elif get_parent().ended:
			if Input.is_action_just_pressed("mouse_click"):
				var raycast_got = raycast.get_collider()
				if raycast.is_colliding() and raycast_got.is_in_group("playerCar"):
					get_parent().player_active = false
					get_parent().started = false
					get_node("../endLayer/end/fadeOutEnd").play("fadeOut")
	
	if global_transform.origin.y < -25.0:
		get_tree().reload_current_scene()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		

func format_number(number: int) -> String:
	# Handle negative numbers by adding the "minus" sign in advance, as we discard it
	# when looping over the number.
	var formatted_number := "-" if sign(number) == -1 else ""
	var index := 0
	var number_string := str(abs(number))
	
	for digit in number_string:
		formatted_number += digit
		
		var counter := number_string.length() - index
		
		# Don't add a comma at the end of the number, but add a comma every 3 digits
		# (taking into account the number's length).
		if counter >= 2 and counter % 3 == 1:
			formatted_number += ","
			
		index += 1
	
	return formatted_number

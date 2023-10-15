extends Spatial


# Declare member variables here. Examples:
# var a = 2
var started = false
var player_active = false
var onMainMenu = true

onready var copCar = preload("res://scenes/things/cop_car.tscn")
var counter = 0
var random_generator = RandomNumberGenerator.new()
var copSpawnRange = 30.0
var copCount = 0

var pass1 = false
var pass2 = false

var copDonuts = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.score = 0
	random_generator.randomize()

var timeSaver = false

func _unhandled_input(event):
	if started and event.is_action_pressed("mouse_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if started and not player_active:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if started and event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

onready var main_menu_camera = $main_menu_camera
onready var player_cam = $player/Pivot/Camera
# Called every frame. 'delta' is the elapsed time since the previous frame.

var ended = false

func _process(delta):
	if started and not player_active:
		main_menu_camera.transform.origin = lerp(main_menu_camera.transform.origin,player_cam.global_transform.origin,0.15)
		main_menu_camera.rotation_degrees = lerp(main_menu_camera.rotation_degrees,player_cam.rotation_degrees,0.15)
	if not player_active:
		if is_equal_approx(main_menu_camera.transform.origin.x, player_cam.global_transform.origin.x):
			player_active = true
			player_cam.current = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$player/ui.show()
	"""
	if Input.is_action_just_pressed("ui_cancel") and onMainMenu:
		started = true
		onMainMenu = false
		player_active = true
		player_cam.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#$music.play()
		$player/ui.show()
		$main_menu_camera/main_menu.queue_free()
	"""
		
	if (get_tree().get_nodes_in_group("Interactable").size() == 0) and not ended and player_active:
		ended = true
		$player/ui/Baseballbat.hide()
		$player/ui/Gun.hide()
		$player.gun = false
		$player.baseballBat = false
		$player/Pivot/RayCast.cast_to = Vector3(0,0,-8)
		$pivot.queue_free()
		$nature.play()
		$my_car/static_my_car/Label3D.show()
	
	if ended:
		$music.volume_db = linear2db(lerp(db2linear($music.volume_db),0.0,0.01))
		
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	counter += 1 
	if get_tree().get_nodes_in_group("fence").size() == 0 and not timeSaver:
		pass1 = true
		pass2 = true
	
	if pass1 and counter%2 == 0 and copCount < 100:
		var myObject = copCar.instance()
		myObject.transform.origin = $copSpawner.global_translation
		myObject.transform.origin.x += random_generator.randi_range(-copSpawnRange,copSpawnRange)
		myObject.transform.origin.z += random_generator.randi_range(-copSpawnRange,copSpawnRange)
		myObject.rotation_degrees.x = random_generator.randi_range(-360,360)
		myObject.rotation_degrees.y = random_generator.randi_range(-360,360)
		myObject.rotation_degrees.z = random_generator.randi_range(-360,360)
		add_child(myObject)
		copCount += 1
	
	if pass2 and not copDonuts:
		copDonuts = true
		$subs2/main_men_anim.play("pigsRaining")
		$pivot/AnimationPlayer.play("New Anim")
	

#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _on_start_button_pressed():
	onMainMenu = false
	$main_menu_camera/main_menu.queue_free()
	$main_menu_camera/subs/main_men_anim.play("start")


func _on_main_men_anim_animation_finished(anim_name):
	started = true
	$music.play()


func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))


func _on_AnimationPlayer_animation_finished(anim_name):
	print(anim_name)
	if anim_name == "New Anim":
		$pivot/AnimationPlayer.play("donuts")


func _on_fadeOutEnd_animation_finished(anim_name):
	get_tree().reload_current_scene()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_HSlider2_value_changed(value):
	$player.mouse_sensitivity = value


func _on_CheckBox_toggled(button_pressed):
	timeSaver = button_pressed

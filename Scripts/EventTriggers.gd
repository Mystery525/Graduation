extends Node3D

@onready var lights = $"../House/Lights"
@onready var LightsOut_Event = false
@export var Music_Controller : Array[AudioStreamMP3]
@onready var no_music = true
@onready var LightsOut_Music = false
@onready var event_triggers = $"."
@onready var flashlight_static = $"../House/Flashlight_Static"
@onready var world_environment = $"../WorldEnvironment"
@onready var door_trigger = $door_trigger
@onready var ray_cast_fov = $"../Player/Head/Eyes/Camera3D/RayCast_FOV"
@onready var check_collision = false
@onready var player = $"../Player"
@onready var obj_marking = $"../House/Obj_Marking"
@onready var cutscene = $"../Cutscenes"
@onready var SpiderMove = false
@onready var CaveSpiderMove = false
@onready var MineCartMove = false

func _ready():
	cutscene.ObjTextFade("Tip: Press 'C' to crouch",5.0)

func PlayMusic():
	var audio_player = $Music_Player
	var array_size = Music_Controller.size()
	
	if LightsOut_Music == true:
		audio_player.stream = Music_Controller[array_size-1]
		audio_player.volume_db = -20.0
	audio_player.play()
	if no_music == true:
		audio_player.stop()

#Interacting with Dryer
func LightsOut():
	if LightsOut_Event == false:
		LightsOut_Event = true
		LightsOut_Music = true
		no_music = false
		$lights_off_sn.play()
		obj_marking.get_node("DryerObj").queue_free()
		lights.queue_free()
		PlayMusic()
		$"../House/Hallway/Flashlight/Lp/StaticBody3D".add_to_group("flashlight")
		$"../House/Hallway/Flashlight/Lp/StaticBody3D".collision_layer = 2
		$"../WorldEnvironment/FogVolume".show()
		$"../House/Hallway/Door_Close_event/AnimationPlayer".play("door_open_loop")
		$"../House/Room/Furniture/PC Area/PC_Screen/Email_Screen".queue_free()
		Flashlight_Intro()

func Flashlight_Intro():
	check_collision = true
	$flashlight_sn.play()
	flashlight_static.show()
	$"../House/Hallway/Hall_Stop".collision_layer = 1

func Flashlight_Grab():
	flashlight_static.queue_free()
	$"../House/Hallway/Flashlight".queue_free()
	$"../House/Loop_SFX/AC".queue_free()
	$tv_trigger/CollisionShape3D.disabled = false
	obj_marking.get_node_or_null("FlashlightObj").queue_free()
	$"../House/Hallway/Hall_Stop".queue_free()

func _on_tv_trigger_body_entered(_body):
	TV_Event()
	$tv_trigger.queue_free()

func TV_Event():
	player.PlayPlayerSound(player,2,0)
	$"../House/Living Room/Furniture/TV/TV_Video".show()
	$"../House/Living Room/Furniture/TV/TV_Audio".play()
	$"../House/Living Room/Furniture/TV/televisionModern/StaticBody3D".collision_layer = 2
	obj_marking.get_node("TVObj").show()

func TV_Off():
	obj_marking.get_node("TVObj").queue_free()
	$"../House/Living Room/Furniture/TV/TV_Video".queue_free()
	$"../House/Living Room/Furniture/TV/TV_Audio".stop()
	$"../House/Living Room/Furniture/TV/televisionModern/StaticBody3D".collision_layer = 1
	player.PlayPlayerSound(player,3,0)
	LightsOut_Music = false
	no_music = true
	PlayMusic()
	await get_tree().create_timer(2.0,false).timeout
	cutscene.ObjTextFade("To Do: Turn on the lights",4.0)
	PhoneRing()

func PhoneRing():
	await get_tree().create_timer(15.0,false).timeout
	$"../House/Kitchen/Furniture/Phone/phone_ring".play()
	$"../House/Kitchen/Furniture/Phone/PhoneMesh/StaticBody3D".collision_layer = 2
	await get_tree().create_timer(2.0,false).timeout
	cutscene.ObjTextFade("Answer the phone.",4.0)

func PhoneAnswer():
	$"../House/Room/Architect/Door_Open".hide()
	$"../House/Room/Architect/Door_Open/door 3/StaticBody3D/CollisionShape3D".disabled = true
	$"../House/Room/Architect/Door".show()
	$"../House/Room/Architect/Door/door 3/StaticBody3D/CollisionShape3D".disabled = false
	$"../House/Kitchen/Furniture/Phone/phone_ring".stop()
	$"../House/Kitchen/Furniture/Phone/phone_call".play()
	await get_tree().create_timer(16.0,false).timeout
	$"../House/Living Room/Ring_Motion".play()
	await get_tree().create_timer(4.0,false).timeout
	cutscene.ObjTextFade("The itsy bitsy spider..",4.0)
	no_music = false
	LightsOut_Music = true
	PlayMusic()
	await get_tree().create_timer(8.0,false).timeout
	cutscene.ObjTextFade("Crawled up the water spout.",4.0)
	await get_tree().create_timer(2.0,false).timeout
	$"../Player/Vent_Crawl".play()
	$"../Player/Vent_Crawl".finished.connect(func destroy(): $"../Player/Vent_Crawl".queue_free())
	await get_tree().create_timer(8.0,false).timeout
	cutscene.ObjTextFade("Down came the rain..",4.0)
	await get_tree().create_timer(2.0,false).timeout
	player.PlayPlayerSound(player,4,-6.0)
	get_tree().call_group("rain","play")
	await get_tree().create_timer(8.0,false).timeout
	cutscene.ObjTextFade("And washed the spider out.",5.0)
	await get_tree().create_timer(3.0,false).timeout
	VentOpen()

func VentOpen():
	$"../House/Room/Furniture/Back/VentDoor".queue_free()
	$"../House/Room/Furniture/Back/VentDoor_Open".show()
	$"../House/Room/Furniture/Back/Vent_Open".play()
	$"../House/Room/Architect/Door_Open".show()
	$"../House/Room/Architect/Door_Open/door 3/StaticBody3D/CollisionShape3D".disabled = false
	$"../House/Room/Architect/Door".hide()
	$"../House/Room/Architect/Door/door 3/StaticBody3D/CollisionShape3D".disabled = true
	$"../House/Room/Key".show()
	$"../House/Room/Key/StaticBody3D/CollisionShape3D".disabled = false
	$"../House/Obj_Marking/KeyObj".show()
	await get_tree().create_timer(6.0,false).timeout
	cutscene.ObjTextFade("To Do: Investigate your office.",4.0)

func KeyGrab():
	obj_marking.get_node_or_null("KeyObj").queue_free()
	cutscene.ObjTextFade("Collected: Basement Key",2.0)

#Sewer Section

func LeverPull():
	$"../ControlRoom/Lever/AnimationPlayer".play("Lever_Pull")
	await get_tree().create_timer(2.0,false).timeout
	$"../DrainRoom/AudioStreamPlayer3D".play()
	$"../DrainRoom/WaterShader".queue_free()
	$"../DrainRoom/StairBox".queue_free()
	await get_tree().create_timer(6.0,false).timeout
	$"../ControlRoom/Wall_Lamp".PlayGreen()
	await get_tree().create_timer(2.0,false).timeout
	$"../ControlRoom/ShutterDoor5".PlayOpen()
	$WaterDrained/CollisionShape3D.disabled = false

func _process(_delta):
	#Check if player looks at door
	if check_collision == true:
		var fov_collider = ray_cast_fov.get_collider()
		if ray_cast_fov.is_colliding():
			if fov_collider.is_in_group("door_trigger"):
				$"../House/Hallway/Door_Close_event/AnimationPlayer".play("door_close")
				check_collision = false
				door_trigger.queue_free()
				await get_tree().create_timer(2.0,false).timeout
				if obj_marking.has_node("FlashlightObj"): obj_marking.get_node_or_null("FlashlightObj").show()

func _physics_process(delta):
	const IntroSpiderSpeed := 7.0
	if SpiderMove == true:
		$"../Path3D/PathFollow3D".progress += IntroSpiderSpeed * delta
		
	const CaveSpiderSpeed := 5.4
	if CaveSpiderMove == true:
		$"../Path3D2/PathFollow3D".progress += CaveSpiderSpeed * delta
		
	const MineCartSpeed := 5.7
	if MineCartMove == true:
		$"../Chase/Path3D/PathFollow3D".progress += MineCartSpeed * delta
		if $"../Chase/Path3D/PathFollow3D".progress_ratio >= 1:
			MineCartMove = false
			$"../Chase/Path3D".queue_free()

func _on_area_3d_body_entered(_body):
	Transit.change_scene_to_file("res://Scenes/main_menu.tscn",1.5,0)

func _on_first_door_close_body_entered(_body):
	$"../DrainRoom/ShutterDoor".PlayClosed()
	player.PlayPlayerSound(player,6,-7)
	$FirstDoorClose.queue_free()
	$"../Intro".queue_free()
	await get_tree().create_timer(12.0,false).timeout
	cutscene.ObjTextFade("To Do: Drain the water",5.0)
	await get_tree().create_timer(9.0,false).timeout
	$"../DrainRoom/Wall_Lamp".PlayGreen()
	await get_tree().create_timer(2.0,false).timeout
	$"../DrainRoom/ShutterDoor4".PlayOpen()

func _on_water_drained_body_entered(_body):
	$"../DrainRoom/ShutterDoor4".PlayClosed()
	$WaterDrained.queue_free()
	$"../ControlRoom".queue_free()
	await get_tree().create_timer(3.0,false).timeout
	$"../DrainRoom/Wall_Lamp2".PlayGreen()
	await get_tree().create_timer(2.0,false).timeout
	$"../Maze/Intro/ShutterDoor2".PlayOpen()

func _on_vent_noise_body_entered(_body):
	$VentNoise.queue_free()
	$"../ControlRoom/SpiderVent".play()

func _on_control_enter_body_entered(_body):
	$ControlEnter.queue_free()
	player.PlayPlayerSound(player,7,-7)

func _on_second_door_close_body_entered(_body):
	$SecondDoorClose.queue_free()
	$"../DrainRoom".queue_free()
	$"../Maze/Intro/ShutterDoor2".PlayClosed()

func _on_third_door_close_body_entered(_body):
	$"../Maze/ShutterDoor5".PlayClosed()
	$ThirdDoorClose.queue_free()
	$"../Maze/Intro".queue_free()
	LightsOut_Music = true
	no_music = false
	PlayMusic()
	await get_tree().create_timer(4.0,false).timeout
	$"../Maze/Wall_Lamp4".PlayGreen()
	await get_tree().create_timer(2.0,false).timeout
	$"../Maze/ShutterDoor7".PlayOpen()
	$"../Maze/ShutterDoor6".PlayOpen()

func _on_maze_open_2_body_entered(_body):
	$"../Maze/ShutterDoor7".PlayClosed()
	$"../Maze/ShutterDoor6".PlayClosed()
	$MazeOpen2.queue_free()
	await get_tree().create_timer(5.0,false).timeout
	$"../Maze/Wall_Lamp5".PlayGreen()
	await get_tree().create_timer(2.0,false).timeout
	$"../Maze/ShutterDoor8".PlayOpen()


func _on_spider_door_close_body_entered(_body):
	$"../Maze/ShutterDoor11/AnimationPlayer".play("door_closed")
	$SpiderDoorClose.queue_free()
	await get_tree().create_timer(5.0,false).timeout
	$"../Maze/Wall_Lamp6".PlayGreen()
	await get_tree().create_timer(2.0,false).timeout
	$"../Maze/ShutterDoor9".PlayLongOpen()
	await get_tree().create_timer(2.0,false).timeout
	$"../Maze/SpiderBang".play()
	LightsOut_Music = false
	no_music = true
	PlayMusic()
	await get_tree().create_timer(2.7,false).timeout
	player.PlayPlayerSound(player,8,-7)
	await get_tree().create_timer(2.6,false).timeout
	$"../Maze/Wall_Lamp7".PlayRed()
	await get_tree().create_timer(2.0,false).timeout
	
	$"../Maze/ShutterDoor10".PlayOpenSpider()
	await get_tree().create_timer(2.0,false).timeout
	$"../Path3D/PathFollow3D/RootNode/AnimationPlayer".play("Spider_Run")
	$"../Path3D/PathFollow3D/RootNode/SpiderWalk".play()
	SpiderMove = true


func _on_wood_break_body_entered(_body):
	$"../Chase/WoodBreak".play()
	$WoodBreak.queue_free()
	await get_tree().create_timer(0.8,false).timeout
	$"../Maze".queue_free()
	SpiderMove = false
	$"../Path3D".queue_free()
	$"../Path3D2/PathFollow3D/RootNode/AnimationPlayer".play("Spider_Scream")
	await get_tree().create_timer(1.1,false).timeout
	CaveSpiderMove = true
	$"../Path3D2/PathFollow3D/RootNode/AnimationPlayer".play("Spider_Run")
	$"../Path3D2/PathFollow3D/RootNode/SpiderWalk".play()
	$"../Chase/Mines/Architect/RailRoad".play()




func _on_mine_cart_start_body_entered(_body):
	$"../Chase/Mines/Architect/MineCartStart".queue_free()
	$"../Chase/Path3D/PathFollow3D/Minecart/AnimationPlayer".play("Alarm")
	MineCartMove = true
	#$"../Chase2/Wall_Lamp8".PlayRed()


func _on_chase_door_close_body_entered(_body):
	$"../Chase2/ChaseDoorClose".queue_free()
	$"../Chase2/Wall_Lamp9".PlayRed()
	$"../Chase2/ShutterDoor".PlayOpen()
	$"../Chase2/ShutterDoor2".PlayClosed()


func _on_chase_door_close_2_body_entered(_body):
	$"../Chase".queue_free()
	$"../Chase2/ChaseDoorClose2".queue_free()
	$"../Chase2/ShutterDoor3".PlayClosed()
	$"../Chase2/ShutterDoor4".PlayOpen()

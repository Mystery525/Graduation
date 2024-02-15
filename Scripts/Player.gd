extends CharacterBody3D
#PlayerNodes
@onready var cutscene_active = false
@onready var head = $Head
@onready var hand = $Head/Hand
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var standing_collision_shape = $standing_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var eyes = $Head/Eyes
@onready var player_camera = $Head/Eyes/Camera3D
@onready var raycast_floor = $RayCast_Floor
@onready var raycast_interact = $Head/Eyes/Camera3D/RayCast_Interact
@onready var event_triggers = $"../EventTriggers"
@onready var flashlight_toggle = false
var flashlight_equipped = false
@onready var flashlight_strength = $Head/Hand/Flashlight.light_energy
@export var player_sounds_bank : Array[AudioStreamMP3]
@onready var cutscenes = $"../Cutscenes"
@onready var tool_tip = true
@onready var has_key = false



#Camera Vars
const head_bopping_sprinting_speed = 22.0 
const head_bopping_walking_speed = 12.0 
const head_bopping_crouching_speed = 10.0

const head_bopping_sprinting_intensity = 0.2 
const head_bopping_walking_intensity = 0.07
const head_bopping_crouching_intensity = 0.05 

var head_bopping_current_intensity = 0.0

var head_bopping_vector = Vector2.ZERO
var head_bopping_index = 0.0

#Footstep Sound Vars
signal step
var can_play = false

#Speed Vars
var current_speed = 5.0
const walking_speed = 4.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
var lerp_speed = 10.0

#Input Vars
var mouse_sens = 0.12
var direction = Vector3.ZERO
var crouching_depth = -0.5

#States
var walking = false
var sprinting = false
var crouching = false
var can_sprint = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Hide Cursor in Window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if get_tree().current_scene.name == "Sewer":
		hand.show()
		$Head/Eyes/Camera3D/Crosshair.hide()
		flashlight_equipped = true
		flashlight_toggle = true
		flashlight_strength = 8.0
		#Load Heavy things
		load("res://Scenes/sewer/wall_lamp.tscn")
		load("res://Scenes/sewer/shutter_door.tscn")
		load("res://Scenes/Spider.tscn")
		if Transit.Death == true:
			self.global_position = $"../DeathSpawn".global_position
			$"../Intro".queue_free()
			$"../DrainRoom".queue_free()
			$"../ControlRoom".queue_free()


func _input(event):
	#Mouse Code
	if cutscene_active == false:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-79),deg_to_rad(79))

func _process(_delta):
	#Interacting with objects
	if raycast_interact.is_colliding():
		$Head/Eyes/Camera3D/Crosshair/Sprite2D/AnimationPlayer.play("interactable")
		if Input.is_action_just_pressed("interact"):
			var group_check_interact = raycast_interact.get_collider()
			print("pressed E")
			print(group_check_interact.get_groups())
			#DoorOpens
			if group_check_interact.is_in_group("door"):
				group_check_interact.door_interact()
			elif group_check_interact.is_in_group("closed_door"):
				group_check_interact.DoorLocked()
			elif group_check_interact.is_in_group("key_door"):
				if has_key == false:
					group_check_interact.DoorLocked()
				else:
					group_check_interact.DoorKeyOpen()
			#Lights go out
			elif group_check_interact.is_in_group("dryer"):
				event_triggers.LightsOut()
				group_check_interact.collision_layer = 1
				await get_tree().create_timer(0.8,false).timeout
				PlayPlayerSound(self,1,-3)
				
			elif group_check_interact.is_in_group("radio"):
				group_check_interact.Play_Radio()
			elif group_check_interact.is_in_group("flashlight"):
				event_triggers.Flashlight_Grab()
				hand.show()
				FlashlightFlicker()
			elif group_check_interact.is_in_group("tv"):
				event_triggers.TV_Off()
				await get_tree().create_timer(6.0,false).timeout
				FlashlightFlicker()
			elif group_check_interact.is_in_group("phone"):
				event_triggers.PhoneAnswer()
				group_check_interact.collision_layer = 1
			elif group_check_interact.is_in_group("key"):
				event_triggers.KeyGrab()
				group_check_interact.collision_layer = 1
				$"../House/Room/Key".queue_free()
				PlayPlayerSound(self,5,-3)
				has_key = true
			elif group_check_interact.is_in_group("Lever"):
				group_check_interact.collision_layer = 0
				event_triggers.LeverPull()
			elif group_check_interact.is_in_group("diploma"):
				event_triggers.DiplomaGrab()
	else:
		$Head/Eyes/Camera3D/Crosshair/Sprite2D/AnimationPlayer.play("RESET")
	#Flashlight
	if cutscene_active == false:
		if Input.is_action_just_pressed("flashlight"):
			if flashlight_equipped == true:
				PlayPlayerSound(self,0,-3)
				flashlight_toggle = !flashlight_toggle
				if flashlight_toggle == false:
					hand.hide()
					$Head/Eyes/Camera3D/Crosshair.show()
				elif flashlight_toggle == true:
					$Head/Eyes/Camera3D/Crosshair.hide()
					hand.show()


func _physics_process(delta):
	#Movement Code
	#Movement Input
	if cutscene_active == false:
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		#Crouching
		if (Input.is_action_pressed("crouch")) and is_on_floor():
			current_speed = lerp(current_speed,crouching_speed,delta*lerp_speed)
			head.position.y = lerp(head.position.y,1.8 + crouching_depth,delta*lerp_speed)
			
			standing_collision_shape.disabled = true
			crouching_collision_shape.disabled = false
			
			walking = false
			sprinting = false
			crouching = true
		elif !ray_cast_3d.is_colliding():
		#Standing
			standing_collision_shape.disabled = false
			crouching_collision_shape.disabled = true
			head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
			
			if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				#Walking
				current_speed = lerp(current_speed,walking_speed,delta*lerp_speed)
				walking = true
				sprinting = false
				crouching = false
				if can_sprint == true:
					if Input.is_action_pressed("sprint") and !Input.is_action_pressed("backward"):
						#Sprinting
						current_speed = lerp(current_speed,sprinting_speed,delta*lerp_speed)
						walking = false
						sprinting = true
						crouching = false
		#Handle Head bob
		if sprinting:
			head_bopping_current_intensity = head_bopping_sprinting_intensity
			head_bopping_index += head_bopping_sprinting_speed * delta
			
		elif walking:
			head_bopping_current_intensity = head_bopping_walking_intensity
			head_bopping_index += head_bopping_walking_speed * delta
			
		elif crouching:
			head_bopping_current_intensity = head_bopping_crouching_intensity
			head_bopping_index += head_bopping_crouching_speed * delta

		if is_on_floor() and input_dir != Vector2.ZERO:
			head_bopping_vector.y = sin(head_bopping_index)
			head_bopping_vector.x = sin(head_bopping_index/2)+0.5
			
			eyes.position.y = lerp(eyes.position.y, head_bopping_vector.y * (head_bopping_current_intensity/2.0), delta*lerp_speed)
			eyes.position.x = lerp(eyes.position.x, head_bopping_vector.x * (head_bopping_current_intensity/1.5), delta*lerp_speed)
			#Emit signal for footstep sound
			if raycast_floor.is_colliding():
				if head_bopping_vector.y > 0.8:
					can_play = true
				
				if head_bopping_vector.y < -0.8 and can_play:
					can_play = false
					emit_signal("step")

		else:
			eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
			eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Get the input direction and handle the movement/deceleration.
		if is_on_floor():
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed

		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
		move_and_slide()

func FlashlightFlicker():
	flashlight_equipped = false
	hand.show()
	$Head/Eyes/Camera3D/Crosshair.hide()
	await get_tree().create_timer(0.5,false).timeout
	$Head/Hand/Flashlight/AnimationPlayer.play("flicker")
	await get_tree().create_timer(1.0,false).timeout
	$Head/Hand/Flashlight/AnimationPlayer.play("RESET")
	flashlight_equipped = true
	flashlight_toggle = true
	$Head/Eyes/Camera3D/Crosshair.hide()

func PlayPlayerSound(PlayerVar,SoundInList : int,Volume : int):
	var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = PlayerVar.player_sounds_bank[SoundInList]
	self.add_child(audio_player)
	audio_player.volume_db = Volume
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())

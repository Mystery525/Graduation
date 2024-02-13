extends StaticBody3D

@export var animationplayer: AnimationPlayer
@onready var player = $"../../../../../Player"
@onready var audio_player = $door_locked
@export var locked_door_sn : AudioStreamMP3
var interact = true

func DoorKeyOpen():
	if player.has_key == true:
		player.has_key = false
		animationplayer.play("door_open")

func DoorLocked():
	if interact == true && player.has_key == false:
		interact = false
		audio_player.stream = locked_door_sn
		audio_player.pitch_scale = randf_range(0.8,5)
		audio_player.play()
		await get_tree().create_timer(0.7,false).timeout
		interact = true

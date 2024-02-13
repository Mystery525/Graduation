extends StaticBody3D
@onready var audio_player = $"../../Door_lock"
@export var locked_door_sn : AudioStreamMP3
var interact = true
func DoorLocked():
	if interact == true:
		interact = false
		audio_player.stream = locked_door_sn
		audio_player.pitch_scale = randf_range(0.8,5)
		$"../../Door_lock".play()
		await get_tree().create_timer(0.7,false).timeout
		interact = true
pass

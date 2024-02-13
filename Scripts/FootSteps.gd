extends Node3D

@export var footstep_sounds : Array[AudioStreamMP3]
@export var ground_pos : Marker3D
@onready var player = $".."
@onready var raycast_floor = $"../RayCast_Floor"
# Called when the node enters the scene tree for the first time.
func _ready():
	player.step.connect(play_sound)
	pass 
	
func play_sound():
	var audio_player : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	var group_check = raycast_floor.get_collider()
	if group_check.is_in_group('Carpet'):
		audio_player.stream = footstep_sounds[0]
	elif group_check.is_in_group('Tile'):
		audio_player.stream = footstep_sounds[1]
	elif group_check.is_in_group('Metal'):
		audio_player.stream = footstep_sounds[2]
	elif group_check.is_in_group('Wet'):
		audio_player.stream = footstep_sounds[3]
	elif group_check.is_in_group('Vent'):
		audio_player.stream = footstep_sounds[4]
	elif group_check.is_in_group('Dirt'):
		audio_player.stream = footstep_sounds[5]
	if player.crouching && !group_check.is_in_group('Vent'):
		audio_player.volume_db = -25.0
	else:
		audio_player.volume_db = -15.0
	if audio_player.stream == footstep_sounds[5]:
		audio_player.pitch_scale = randf_range(0.5,0.7)
	else:
		audio_player.pitch_scale = randf_range(0.8,1.2)
	ground_pos.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())

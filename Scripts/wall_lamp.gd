extends Node3D

@onready var anim_player = $AnimationPlayer

func PlayGreen():
	anim_player.play("Green_Light")

func PlayRed():
	anim_player.play("Red_Light")
	
func Stop():
	anim_player.play("RESET")

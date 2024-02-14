extends Node3D

@onready var anim_player = $AnimationPlayer


func PlayOpen():
	anim_player.play("door_open")
	
func PlayClosed():
	anim_player.play("door_closed")

func PlayLongOpen():
	anim_player.play("door_open_long")
	
func PlayOpenSpider():
	anim_player.play("door_open_spider")

func PlayLongClosed():
	anim_player.play("door_closed_long")

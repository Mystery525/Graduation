extends Control

@onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("play_credits")
	SwitchScenes()
func SwitchScenes():
	await anim_player.animation_finished
	Transit.change_scene_to_file("res://Scenes/main_menu.tscn",2.0,0)
	Transit.SceneChoose = 0

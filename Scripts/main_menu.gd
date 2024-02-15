extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Music.play()

func _on_play_pressed():
	Transit.change_scene_to_file("res://Scenes/loading_screen.tscn",2.0,0)
	$AnimationPlayer.play("Music_Fade_Out")
	Transit.SceneChoose = 1

func _on_quit_pressed():
	get_tree().quit()

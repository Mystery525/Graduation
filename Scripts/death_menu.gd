extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Transit.Death = true


func _on_retry_pressed():
	Transit.SceneChoose = 2
	Transit.change_scene_to_file("res://Scenes/loading_screen.tscn",1.0,0)

extends Node3D

@onready var player = $"../Player"
@onready var player_camera = $"../Player/Head/Eyes/Camera3D"
@onready var event_triggers = $"../EventTriggers"
@onready var intro_cutscene : bool
@onready var objective = $"../Player/Head/Eyes/Camera3D/Objective_UI/CanvasLayer/VBoxContainer/Label"
@onready var obj_anim_player = $"../Player/Head/Eyes/Camera3D/Objective_UI/CanvasLayer/VBoxContainer/AnimationPlayer"
@onready var obj_ui_node = $"../Player/Head/Eyes/Camera3D/Objective_UI"
@onready var pause_menu = $"../Player/Head/Eyes/Camera3D/PauseMenu"

func _ready():
	if get_tree().current_scene.name == "Sewer":
		intro_cutscene = false
		ObjTextFade("Tip: Press 'C' to crouch",6.0)
	else:
		
		intro_cutscene = true

func CutscenePlay(Cutscene):
	$"../Player/Head/Eyes/Camera3D/Crosshair".hide()
	player.cutscene_active = true
	player_camera.current = false
	$AnimationPlayer.play(Cutscene)
	await $AnimationPlayer.animation_finished
	player_camera.current = true
	player.cutscene_active = false
	$"../Player/Head/Eyes/Camera3D/Crosshair".show()
	pass

func _process(_delta):
	if intro_cutscene == true:
		pause_menu.can_pause = false
		CutscenePlay("Cutscene1")
		intro_cutscene = false
		await get_tree().create_timer(15.0,false).timeout
		$Cutscene1/MeshInstance3D.queue_free()
		await $AnimationPlayer.animation_finished
		pause_menu.can_pause = true
		ObjTextFade("To Do: Search for dryer.\n Explore.",4.0)
		await get_tree().create_timer(8.0,false).timeout
		ObjTextFade("Tip: Press 'E' or Left Click\nto interact with objects.",4.0)


func ObjTextFade(Text,TimerTime: float):
	var text_active = true
	objective.text = Text
	obj_ui_node.show()
	while(text_active):
		obj_anim_player.play("fade_in")
		await obj_anim_player.animation_finished
		await get_tree().create_timer(TimerTime,false).timeout
		obj_anim_player.play("fade_out")
		await obj_anim_player.animation_finished
		obj_ui_node.hide()
		text_active = false

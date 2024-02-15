extends Node3D

@onready var SpiderAnim = $RootNode/AnimationPlayer

func PlayerDeath():
	SpiderAnim.play("Spider_Scare")
	$AnimationPlayer.play("jumpscare")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://Scenes/death_menu.tscn")

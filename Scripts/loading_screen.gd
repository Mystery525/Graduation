extends Control

var progress = []
@onready var RoomScene = "res://Scenes/main.tscn"
@onready var SewerScene = "res://Scenes/sewer.tscn"
var scene_load_status = 0

func _ready():
	if Transit.SceneChoose == 1:
		ResourceLoader.load_threaded_request(RoomScene)
	elif Transit.SceneChoose == 2:
		ResourceLoader.load_threaded_request(SewerScene)
		preload("res://Scenes/sewer/wall_lamp.tscn")
		preload("res://Scenes/sewer/shutter_door.tscn")
		preload("res://Scenes/sewer_water.gdshader")

func _process(_delta):
	if Transit.SceneChoose == 1:
		scene_load_status = ResourceLoader.load_threaded_get_status(RoomScene,progress)
		$MarginContainer/Label.text = "Loading: " + str(floor(progress[0]*100)) + "%"
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var newRoomScene = ResourceLoader.load_threaded_get(RoomScene)
			get_tree().change_scene_to_packed(newRoomScene)
	elif Transit.SceneChoose == 2:
		scene_load_status = ResourceLoader.load_threaded_get_status(SewerScene,progress)
		$MarginContainer/Label.text = "Loading: " + str(floor(progress[0]*100)) + "%"
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var newSewerScene = ResourceLoader.load_threaded_get(SewerScene)
			get_tree().change_scene_to_packed(newSewerScene)

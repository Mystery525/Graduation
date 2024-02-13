extends StaticBody3D

var toggle = false
var interactable = true
@onready var autoclose_timer = $"../../Timer"
@export var animationplayer: AnimationPlayer

func door_interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animationplayer.play("door_close")
			autoclose_timer.stop()
		if toggle == true:
			animationplayer.play("door_open")
			autoclose_timer.start()
		#Timer to be able to interact again.
		await get_tree().create_timer(0.85, false).timeout
		interactable = true

func _on_timer_timeout():
	interactable = false
	animationplayer.play("door_close")
	toggle = false
	await get_tree().create_timer(0.85, false).timeout
	interactable = true

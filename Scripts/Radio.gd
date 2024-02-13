extends StaticBody3D

var can_interact = true
@export var anim_name = ["Song_1","Song_2","Song_3","Song_4","Song_5"]
@export var animationplayer: AnimationPlayer
var anim_next = 0
func Play_Radio():
	if can_interact == true:
		Radio_Station()

func Radio_Station():
	var array_size = anim_name.size()
	if anim_next >= array_size:
		can_interact = false
		pass
	else:
		can_interact = false
		animationplayer.play(anim_name[array_size-array_size+anim_next])
		await animationplayer.animation_finished
		anim_next += 1
		can_interact = true

extends Control
@onready var paused = false
@onready var pause_screen = $PauseScreen
@onready var can_pause = true
@export var bus_name : String
var bus_index : int
@onready var master = $"PauseScreen/Options Buttons/Master"
@onready var player = $"../../../.."
@onready var mouse = $"PauseScreen/Options Buttons/Mouse"
var in_options = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus_index = AudioServer.get_bus_index(bus_name)
	master.value_changed.connect(_on_value_changed)
	master.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	mouse.value_changed.connect(mouse_sense_value)
	mouse.value = player.mouse_sens
	
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if can_pause == true:
			if in_options == true:
				OptionsMenu()
			else:
				PauseMenu()

func PauseMenu():
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_screen.hide()
		get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_screen.show()
		get_tree().paused = true
	paused = !paused

func OptionsMenu():
	if in_options == false:
		$"PauseScreen/Pause Buttons".hide()
		$"PauseScreen/Options Buttons".show()
		in_options = true
	else:
		$"PauseScreen/Pause Buttons".show()
		$"PauseScreen/Options Buttons".hide()
		in_options = false

func _on_resume_pressed():
	PauseMenu()

func _on_options_pressed():
	OptionsMenu()

func _on_back_pressed():
	OptionsMenu()

func _on_value_changed(value: float):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func mouse_sense_value(value: float):
	player.mouse_sens = mouse.value

func _on_quit_pressed():
	get_tree().quit()




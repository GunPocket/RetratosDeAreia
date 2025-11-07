extends Node2D

@onready var button: Button = $Button
@onready var button_2: Button = $Button2

func _ready() -> void:
	EventController.connect("save_photos_signal", Callable(self, "_update_butttons"))

func _update_butttons() -> void:
	EventController._update_photos()

	var todos_preenchidos := true
	for f in EventController.saved_photos:
		if f == null:
			todos_preenchidos = false
			break
			
	EventController._update_photos()
	
	print(EventController.average_score)


	if todos_preenchidos:
		button_2.visible = true


func _on_button_pressed() -> void:
	if EventController.day < 4:
		EventController._next_day()
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/praia_scene.tscn")

func _on_button_2_pressed() -> void:	
	get_tree().change_scene_to_file("res:/print/Assets/Scenes/Game Scenes/win_scene.tscn")
	

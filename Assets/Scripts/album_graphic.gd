extends Node2D

@onready var button: Button = $Button
@onready var button_2: Button = $Button2

func _ready() -> void:
	EventController.connect("save_photos_signal", Callable(self, "_update_butttons"))

func _update_butttons() -> void:
	EventController._update_photos()
	print("Average Score: {score}".format({"score": EventController.average_score}))
	print("Photo count: {count}".format({"count": EventController.saved_photos.size()}))
	if EventController.average_score == 3 && EventController.saved_photos.size() == 4:
		button_2.visible = true

func _on_button_pressed() -> void:
	if EventController.day < 4:
		EventController._next_day()
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/praia_scene.tscn")

func _on_button_2_pressed() -> void:	
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/win_scene.tscn")
	

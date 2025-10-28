extends Node2D

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/praia_scene.tscn")
	if EventController.day < 4:
		EventController._next_day()

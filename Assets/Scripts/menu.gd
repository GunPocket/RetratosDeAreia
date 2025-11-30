extends Control

func _ready() -> void:
	EventController.day = 0

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/tutorial_scene.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_créditos_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/creditos_scene.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/menu_scene.tscn")

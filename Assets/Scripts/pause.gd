extends Control

func resume():
	get_tree().paused = false
	
func pause():
	get_tree().paused = true

func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().pause == true:
		resume ()

func _on_retomar_pressed() -> void:
	resume()


func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/menu.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()

extends Node2D

func _ready() -> void:
	var offset = Vector2(10, 10)

	for tex in EventController.fotos_salvas:
		var photo = preload("res://Assets/Scenes/photo.tscn").instantiate()
		photo.set_texture(tex)
		photo.position = offset
		add_child(photo)

		offset.x += 120  # espaçamento horizontal entre fotos

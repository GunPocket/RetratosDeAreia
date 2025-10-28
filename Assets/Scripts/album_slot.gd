extends Node2D

func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			child.add_to_group("slot")

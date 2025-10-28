extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $"../Control/CanvasGroup/Label"
@onready var foto_barra: Node2D = $"../CanvasLayer/FotoBarra"


@export var max_fotos: int = 3
var fotos_tiradas: int = 0

const FOTO_SCENE = preload("res://Assets/Scenes/photo.tscn")

func _ready() -> void:	
	label.text = "Fotos tiradas: %d/%d" % [0, max_fotos]

func _atualizar_label(qtd: int) -> void:
	label.text = "Fotos tiradas: %d/%d" % [qtd, max_fotos]

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _tirar_foto() -> void:
	if fotos_tiradas >= max_fotos:
		return
	_registrar_foto()

func _registrar_foto() -> void:
	fotos_tiradas += 1
	label.text = "Fotos tiradas: %d/%d" % [fotos_tiradas, max_fotos]
	_mostrar_foto()

func _mostrar_foto() -> void:
	var img: Image = get_viewport().get_texture().get_image()

	if collision_shape_2d.shape is RectangleShape2D:
		var rect_size = collision_shape_2d.shape.extents * 2.0
		var rect_pos = collision_shape_2d.global_position - rect_size / 2.0

		var viewport_xform = get_viewport().get_canvas_transform()
		var top_left = viewport_xform * rect_pos
		var rect = Rect2(top_left, rect_size)

		var recorte = img.get_region(rect)
		var tex := ImageTexture.create_from_image(recorte)

		var foto_instance = FOTO_SCENE.instantiate()
		var sprite: Sprite2D = foto_instance.get_node("Sprite2D")
		sprite.texture = tex
		sprite.scale = Vector2(0.2, 0.2)

		var shape = RectangleShape2D.new()
		shape.extents = (tex.get_size() * sprite.scale) / 2
		foto_instance.get_node("CollisionShape2D").shape = shape

		var screen_h = get_viewport_rect().size.y
		var margin_bottom = 10
		foto_instance.position = Vector2(
			100 + (fotos_tiradas - 1) * (rect_size.x * sprite.scale.x + 10),
			screen_h - rect_size.y * sprite.scale.y - margin_bottom
		)

		foto_barra.add_child(foto_instance)

		EventController._save_photo(tex, Vector2.ZERO, false)

		if fotos_tiradas == max_fotos:
			get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/album_scene.tscn")

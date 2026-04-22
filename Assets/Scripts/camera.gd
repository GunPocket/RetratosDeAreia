extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $"../Control/CanvasGroup/Label"
@onready var foto_barra: Node2D = $"../CanvasLayer/FotoBarra"

@export var max_fotos: int = 4
@export var textureSizeMultiplier: float
var fotos_tiradas: int = 0

const FOTO_SCENE = preload("res://Assets/Scenes/photo.tscn")

func _ready() -> void:
	_atualizar_label(0)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _tirar_foto() -> void:
	if fotos_tiradas >= max_fotos:
		return
	_registrar_foto()

func _registrar_foto() -> void:
	fotos_tiradas += 1
	_atualizar_label(fotos_tiradas)
	_mostrar_foto()

func _atualizar_label(qtd: int) -> void:
	label.text = "Fotos tiradas: %d/%d" % [qtd, max_fotos]

func _mostrar_foto() -> void:
	var tex: = await _capturar_imagem()
	var foto_instance = _criar_foto_instance(tex)

	var resultados = _detectar_objetos_na_area()
	var resultado = _extrair_animais(resultados)
	var animais_detectados  = resultado[0]

	foto_instance.set_animals(animais_detectados)

	EventController._save_photo(tex, Vector2.ZERO, false, 0, animais_detectados)

	if fotos_tiradas == max_fotos:
		get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/album_scene.tscn")

func _capturar_imagem() -> ImageTexture:
	var fotos: Array = get_tree().get_nodes_in_group("foto")
	for foto in fotos:
		if foto != self:
			var shape = foto.get_node_or_null("CollisionShape2D")
			if shape:
				shape.disabled = true
	visible = false
	await RenderingServer.frame_post_draw

	var img: Image = get_viewport().get_texture().get_image()
	var imgScale = Vector2( img.get_size() )/get_viewport_rect().size
	var screen_pos: Vector2i = collision_shape_2d.get_global_transform_with_canvas().origin
	var normalized_pos = Vector2( screen_pos ) / get_viewport_rect().size
	var rect_size: Vector2 = (collision_shape_2d.shape.extents * textureSizeMultiplier) * imgScale
	var rect_pos: Vector2 = (Vector2( img.get_size() ) * normalized_pos) - (rect_size/2)
	var rect: Rect2 = Rect2(rect_pos, rect_size)
	if (rect.position.x + rect.size.x) > img.get_size().x: rect.position.x -= (rect.position.x + rect.size.x) - img.get_size().x
	if rect.position.x < 0: rect.position.x = 0
	if (rect.position.y + rect.size.y) > img.get_size().y: rect.position.y -= (rect.position.y + rect.size.y) - img.get_size().y
	if rect.position.y < 0: rect.position.y = 0
	var recorte: Image = img.get_region(rect)
	var tex = ImageTexture.create_from_image(recorte)
	visible = true

	for foto in fotos:
		if foto != self:
			var shape = foto.get_node_or_null("CollisionShape2D")
			if shape:
				shape.disabled = false

	return tex

func _criar_foto_instance(tex: ImageTexture) -> Area2D:
	var foto_instance = FOTO_SCENE.instantiate()
	var sprite: Sprite2D = foto_instance.get_node("Sprite2D")
	sprite.texture = tex
	sprite.scale = Vector2(0.2, 0.2)

	var shape = RectangleShape2D.new()
	shape.extents = (tex.get_size() * sprite.scale) / 2
	foto_instance.get_node("CollisionShape2D").shape = shape

	var margin_top: float = 80.0
	var spacing: float = 40.0
	foto_instance.position = Vector2(
		margin_top + (fotos_tiradas - 1) * (shape.extents.x * 2 + spacing),
		margin_top + shape.extents.y
	)

	foto_barra.add_child(foto_instance)
	return foto_instance

func _detectar_objetos_na_area() -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape_2d.shape
	query.transform = collision_shape_2d.global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = true
	return get_world_2d().direct_space_state.intersect_shape(query, 64)

func _extrair_animais(results: Array) -> Array:
	var animais_detectados: Array[EventController.Animal] = []

	for r in results:
		var obj = r.get("collider")
		if obj == null or obj == self:
			continue

		animais_detectados.append(_obter_animal_do_objeto(obj))

	return [animais_detectados, []]

func _obter_animal_do_objeto(obj) -> EventController.Animal:
	if obj.has_meta("animal_type"):
		return obj.get_meta("animal_type")
	elif "animal_type" in obj:
		return obj.animal_type
	return EventController.Animal.NONE

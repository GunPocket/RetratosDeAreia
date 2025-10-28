extends Node2D

var selected_photo: Area2D = null
var offset: Vector2 = Vector2.ZERO

const PILHA_SIZE := 5
var pilha_slots := [
	Vector2(100, 100),
	Vector2(100, 150),
	Vector2(100, 200),
	Vector2(100, 250),
	Vector2(100, 300)
]
var pilha_index := 0

var slot_indices := {
	Vector2(384, 167.5): 0,  # (0,0)
	Vector2(756, 167.5): 1,  # (1,0)
	Vector2(384, 404.5): 2,  # (0,1)
	Vector2(756, 404.5): 3   # (1,1)
}

func _ready() -> void:
	_add_taken_photos()
	EventController.connect("save_photos_signal", Callable(self, "_salvar_fotos"))

func _add_taken_photos() -> void:
	var temp_photos = EventController._get_temp_photos()
	for f in temp_photos:
		var tex: ImageTexture = f.get("tex")
		var score: int = f.get("score", 0)
		var pos: Vector2 = f.get("pos", Vector2.ZERO)

		var photo = preload("res://Assets/Scenes/photo.tscn").instantiate()
		photo.set_texture(tex)
		photo.set_score(score)
		photo.set_fixed(false)
		photo.set_pos(pos if pos != Vector2.ZERO else pilha_slots[pilha_index])
		if pos == Vector2.ZERO:
			pilha_index = (pilha_index + 1) % PILHA_SIZE
		add_child(photo)

	var saved_photos = EventController._get_photos()
	for f in saved_photos:
		var tex: ImageTexture = f.get("tex")
		var score: int = f.get("score", 0)
		var pos: Vector2 = f.get("pos", Vector2.ZERO)

		var photo = preload("res://Assets/Scenes/photo.tscn").instantiate()
		photo.set_texture(tex)
		photo.set_score(score)
		photo.set_fixed(true)
		photo.set_pos(pos)
		add_child(photo)


func _process(_delta: float) -> void:
	if selected_photo:
		selected_photo.global_position = get_global_mouse_position() + offset

func _mover_foto() -> void:
	var mouse_pos = get_global_mouse_position()
	if selected_photo == null:
		_tentar_selecionar(mouse_pos)
	else:
		_tentar_soltar()

func _tentar_selecionar(mouse_pos: Vector2) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collision_mask = 0xFFFFFFFF

	for result in space_state.intersect_point(query, 32):
		var area = result.collider
		if area is Area2D and area.is_in_group("foto"):
			selected_photo = area
			offset = selected_photo.global_position - mouse_pos
			return

func _tentar_soltar() -> void:
	if selected_photo == null:
		return

	var slot = _get_slot_under_photo(selected_photo)
	if slot:
		var fotos_no_slot = _get_fotos_overlapping(slot)
		for f in fotos_no_slot:
			if f != selected_photo:
				_enviar_para_pilha_ciclica(f)

	selected_photo.set_pos(slot.global_position if slot else selected_photo.get_pos())
	selected_photo.set_fixed(slot != null)

	if slot != null:
		var sprite = selected_photo.get_node_or_null("Sprite2D")
		if sprite and sprite.texture:
			var index = slot_indices.get(slot.global_position, -1)
			if index != -1:
				EventController.saved_photos[index] = {
					"img_data": sprite.texture.get_image().save_png_to_buffer(),
					"pos": slot.global_position,
					"fixed": true,
					"score": selected_photo.get_score()
				}
				EventController.emit_signal("save_photos_signal")

				
	elif selected_photo.get_fixed() == false:
		var sprite = selected_photo.get_node_or_null("Sprite2D")
		if sprite and sprite.texture:
			EventController._save_photo(sprite.texture, selected_photo.get_pos(), false, selected_photo.get_score())

	selected_photo = null

func _get_slot_under_photo(photo: Area2D) -> Node2D:
	for slot in get_tree().get_nodes_in_group("slot"):
		if _esta_sobre_slot(photo, slot):
			return slot
	return null

func _get_fotos_overlapping(target: Node2D) -> Array:
	var fotos: Array = []
	for f in get_tree().get_nodes_in_group("foto"):
		if f == selected_photo:
			continue
		if _esta_sobre_slot(f, target):
			fotos.append(f)
	return fotos

func _enviar_para_pilha_ciclica(foto: Area2D) -> void:
	var nova_pos = pilha_slots[pilha_index]
	foto.set_pos(nova_pos)
	foto.set_fixed(false)
	pilha_index = (pilha_index + 1) % pilha_slots.size()

	var sp = foto.get_node_or_null("Sprite2D")
	if sp and sp.texture:
		EventController._save_photo(sp.texture, nova_pos, false, foto.get_score())

func _esta_sobre_slot(foto: Area2D, slot: Node2D) -> bool:
	var foto_shape = foto.get_node_or_null("CollisionShape2D")
	var slot_shape = slot.get_node_or_null("CollisionShape2D")
	if foto_shape == null or slot_shape == null:
		return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = foto_shape.shape
	query.transform = foto.global_transform
	query.collide_with_areas = true
	var results = space_state.intersect_shape(query, 32)
	for r in results:
		if r.collider == slot:
			return true
	return false

func _adicionar_na_pilha(foto: Area2D) -> void:
	var slot_pos: Vector2 = pilha_slots[pilha_index]
	foto.set_pos(slot_pos)
	foto.set_fixed(false)
	pilha_index = (pilha_index + 1) % PILHA_SIZE

func _salvar_fotos() -> void:
	for foto in get_tree().get_nodes_in_group("foto"):
		var sp = foto.get_node_or_null("Sprite2D")
		if sp and sp.texture:
			EventController._save_photo(sp.texture, foto.get_pos(), foto.get_fixed(), foto.get_score())

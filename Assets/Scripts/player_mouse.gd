extends Node2D

@onready var camera: Node2D = get_node_or_null("../Camera")
@onready var album: Node2D = get_node_or_null("../Album")

func _ready() -> void:
	# Conecta sinais de diálogo
	check_state()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _input(event):
	if event.is_action_pressed("mouse_clicks"):
		match EventController.current_state:
			EventController.State.TRASH:
				var mouse_pos = get_global_mouse_position()
				_check_click_collision(mouse_pos)
			EventController.State.CAMERA:
				if camera != null and camera.is_inside_tree():
					camera._tirar_foto()
			EventController.State.ALBUM:
				if album != null and album.is_inside_tree():
					album._mover_foto()


func _check_click_collision(click_position: Vector2) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = click_position
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_point(query, 10)
	if result.size() == 0:
		return

	for collision in result:
		var area = collision.collider
		if area is CollisionObject2D:
			var layer = area.collision_layer

			if layer & (1 << 3):  # Layer 4: Lixo
				if area.has_method("_destroi_lixo"):
					area._destroi_lixo()
				return

			elif layer & (1 << 4):  # Layer 5: NPC
				if area.has_method("action"):
					EventController.current_state = EventController.State.DIALOGUE
					area.action()
				return

# --- DIALOGUE HANDLERS ---
func _on_dialogue_started(_dialogue: DialogueResource) -> void:
	#get_tree().paused = true
	pass

func _on_dialogue_finished(_dialogue: DialogueResource) -> void:
	if not is_inside_tree():
		return
	get_tree().paused = false
	check_state()
	
func check_state():
	# Restaura estado
	if camera != null:
		EventController.current_state = EventController.State.CAMERA
	elif album != null:
		EventController.current_state = EventController.State.ALBUM
	else:
		EventController.current_state = EventController.State.TRASH

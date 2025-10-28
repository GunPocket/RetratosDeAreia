extends Node

@onready var h_slider: HSlider = $"../Control/CanvasGroup/HSlider"
@onready var label: Label = $"../Control/CanvasGroup/Label"
@onready var spawn_area_polygon: Polygon2D = $"Spawn area"

@export var min_distance := 32.0
@export var max_lixos := 10
@export var tempo_total := 15.0


@export var dialogo_inicial = preload("uid://btkmbrxhqgiyx")
@export var dialogo_final = preload("uid://xqvjuwenxr2")

var current_lixos: Array = []
var countdown_timer := 0.0
var lixos_ativos := false
var can_spawn : bool = true

const TRASH_PAPER: TrashData = preload("res://Assets/Resorces/trash_papel.tres")
const TRASH_CIGARRO: TrashData = preload("res://Assets/Resorces/trash_cigarro.tres")
const TRASH_GARRAFA: TrashData = preload("res://Assets/Resorces/trash_garrafa.tres")
const TRASH_SACO: TrashData = preload("res://Assets/Resorces/trash_saco.tres")
const TRASH_REDE: TrashData = preload("res://Assets/Resorces/trash_rede.tres")

var lixos_por_dia: Dictionary = {
	1: [TRASH_PAPER, TRASH_CIGARRO],
	2: [TRASH_PAPER, TRASH_CIGARRO, TRASH_GARRAFA],
	3: [TRASH_PAPER, TRASH_CIGARRO, TRASH_GARRAFA, TRASH_SACO],
	4: [TRASH_PAPER, TRASH_CIGARRO, TRASH_GARRAFA, TRASH_SACO, TRASH_REDE]
}

func _ready() -> void:
	DialogueManager.dialogue_started.connect(self._on_dialogue_started)
	DialogueManager.dialogue_ended.connect(self._on_dialogue_ended)
	if h_slider:
		h_slider.max_value = 50
		h_slider.value = EventController._get_total_trash()
	if label:
		label.text = "Preparando diálogo..."

	EventController.connect("trash_collected", Callable(self, "_on_trash_collected"))

	if EventController.day == 1:
		DialogueManager.show_dialogue_balloon(dialogo_inicial, "start")
	else:
		iniciar_spawn_lixos()
		iniciar_contagem_regressiva()

func _on_dialogue_started(_resource: DialogueResource) -> void:
	EventController.current_state = EventController.State.DIALOGUE

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == dialogo_inicial:		
		EventController.current_state = EventController.State.TRASH
		iniciar_spawn_lixos()
		iniciar_contagem_regressiva()
	elif resource == dialogo_final:
		get_tree().change_scene_to_file("res://Assets/Scenes/Game Scenes/mar_scene.tscn")

func iniciar_spawn_lixos() -> void:
	lixos_ativos = true
	_atualizar_lixos()

func iniciar_contagem_regressiva() -> void:
	countdown_timer = tempo_total
	lixos_ativos = true

func _process(delta: float) -> void:
	if lixos_ativos and countdown_timer > 0:
		countdown_timer -= delta
		if label:
			label.text = "Tempo restante: %.1f s" % countdown_timer
		if countdown_timer <= 0:
			lixos_ativos = false
			DialogueManager.show_dialogue_balloon(dialogo_final, "start")

func _atualizar_lixos():
	if EventController.current_state == 0:
		return

	var lixos_disponiveis = lixos_por_dia.get(EventController.day)
	while current_lixos.size() < max_lixos:
		_spawn_lixo_random(lixos_disponiveis)

func _spawn_lixo_random(lixos_disponiveis: Array):
	
	if EventController.current_state == 0:
		return
	
	var pos = get_random_spawn_position()
	var lixo = lixos_disponiveis[randi() % lixos_disponiveis.size()]
	spawn_lixo(lixo, pos)

func spawn_lixo(trash_data: TrashData, position: Vector2):
	var instance = trash_data.scene.instantiate()
	add_child(instance)
	instance.global_position = position

	var sprite = instance.get_node_or_null(trash_data.sprite_path)
	if sprite:
		if trash_data.texture and sprite.has_method("set_texture"):
			sprite.texture = trash_data.texture
		sprite.scale = Vector2(trash_data.sprite_scale, trash_data.sprite_scale)

	instance.set("trash_data", trash_data)
	current_lixos.append(instance)

	var lifetime = trash_data.lifetime * randf_range(1.0, 3.0)
	despawn_lixo(instance, lifetime)

func despawn_lixo(instance: Node2D, lifetime: float) -> void:
	while EventController.current_state == 0:
		await get_tree().process_frame

	await get_tree().create_timer(lifetime).timeout
	if not is_instance_valid(instance):
		return

	if instance in current_lixos:
		current_lixos.erase(instance)
		instance.queue_free()
		_atualizar_lixos()

func _on_trash_collected():
	if h_slider:
		h_slider.value = float(EventController._get_total_trash())
	_atualizar_lixos()

func get_random_spawn_position() -> Vector2:
	if not spawn_area_polygon or spawn_area_polygon.polygon.size() < 3:
		push_error("Spawn polygon não configurado ou inválido!")
		return Vector2.ZERO

	var poly := spawn_area_polygon.polygon
	var rect := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		rect = rect.expand(p)

	for i in range(50):
		var local_pos = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		if Geometry2D.is_point_in_polygon(local_pos, poly):
			var global_pos = spawn_area_polygon.to_global(local_pos)
			if _posicao_valida(global_pos):
				return global_pos
	return spawn_area_polygon.global_position

func _posicao_valida(pos: Vector2) -> bool:
	if EventController.current_state == 0:
		return true
	for lixo in current_lixos:
		if not is_instance_valid(lixo):
			current_lixos.erase(lixo)
			continue
		if lixo.global_position.distance_to(pos) < min_distance:
			return false
	return true

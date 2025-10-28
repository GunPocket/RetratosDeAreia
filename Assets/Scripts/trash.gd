extends Area2D

var was_collected: bool = false
var trash_data: TrashData = null  # Referência ao TrashData do lixo
var spawner: Node = null          # Referência ao TrashSpawner

func _ready():
	# Caso o TrashSpawner não tenha setado a referência
	if not trash_data and has_meta("trash_data"):
		trash_data = get_meta("trash_data")

	# Tenta encontrar o spawner na hierarquia
	if not spawner:
		spawner = get_parent()  # Assumindo que TrashSpawner é pai
		if not spawner:
			push_error("TrashSpawner não encontrado para este lixo!")

func _destroi_lixo():
	_collect()

func _collect() -> void:
	if was_collected:
		return
	was_collected = true

	# Adiciona ao total de lixo
	EventController.add_trash()

	# Notifica o spawner para atualizar lixos
	if spawner and spawner.has_method("_atualizar_lixos"):
		spawner._atualizar_lixos()

	queue_free()

extends Area2D


@export var move_speed: float = 100.0
@export var change_dir_time: float = 2.0
var direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # ajuste o caminho se necessário

func _ready() -> void:
	_mudar_direcao()
	_mover_loop()

func _mudar_direcao() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if direction.x != 0:
		sprite.flip_h = direction.x < 0 

func _mover_loop() -> void:
	while true:
		_mudar_direcao()
		await get_tree().create_timer(change_dir_time).timeout

func _process(delta: float) -> void:
	position += direction * move_speed * delta

	if position.y < -100:
		position.y = -100
		if direction.y < 0:
			direction.y = abs(direction.y)

func _foto_peixe() -> void:
	EventController.emit_signal("fish_collected")

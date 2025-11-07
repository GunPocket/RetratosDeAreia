extends Area2D

@export var move_speed: float = 100.0
@export var change_dir_time_min: float = 1.5
@export var change_dir_time_max: float = 3.0
@export var sprite_scale: float = 1.0
@export var animal_type: EventController.Animal

var start_pos: Vector2
var target_pos: Vector2
var move_timer: float = 0.0
var move_duration: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if global_position.y < -150:
		global_position.y = -150
	start_pos = global_position
	_iniciar_novo_movimento()


func _process(delta: float) -> void:
	if move_timer < move_duration:
		move_timer += delta
		var t = move_timer / move_duration
		t = t * t * (3 - 2 * t)
		global_position = start_pos.lerp(target_pos, t)
	else:
		_iniciar_novo_movimento()

func _iniciar_novo_movimento() -> void:
	move_timer = 0.0
	start_pos = global_position
	move_duration = randf_range(change_dir_time_min, change_dir_time_max)
	var rand_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5))
	if rand_dir.length() == 0:
		rand_dir = Vector2(1, 0)
	rand_dir = rand_dir.normalized()
	var distance = move_speed * move_duration
	target_pos = start_pos + rand_dir * distance
	if target_pos.y < -150:
		target_pos.y = -150
	sprite.flip_h = rand_dir.x < 0

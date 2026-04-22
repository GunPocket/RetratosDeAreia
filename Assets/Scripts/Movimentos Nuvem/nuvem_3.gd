extends Sprite2D

@export var speed := 15.0

var texture_width

func _ready():
	texture_width = texture.get_width() * scale.x

func _process(delta):
	position.x += speed * delta
	if position.x > get_viewport_rect().size.x + texture_width / 2:
		position.x = -texture_width / 2

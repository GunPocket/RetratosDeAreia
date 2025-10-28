extends Node

signal trash_collected
@warning_ignore("unused_signal")
signal save_photos_signal

enum State {DIALOGUE, TRASH, CAMERA, ALBUM}
var current_state: State = State.TRASH
var average_score
var total_trash: int = 0

var temp_photos: Array = []        # Fotos tiradas, ficam na pilha
var saved_photos: Array = [null, null, null, null]  # Grid 2x2 do álbum
var day: int = 1

func _update_photos() -> void:
	var total_score := 0
	var count : float = 0
	for f in saved_photos:
		if f != null:
			total_score += f.get("score", 0)
			count += 1
	if count > 0:
		average_score = total_score / count

func _save_photo(tex: ImageTexture, pos: Vector2, fixed: bool = false, score: int = -1) -> void:
	if tex == null:
		return

	if score == -1:
		score = calcular_score()

	var img: Image = tex.get_image()
	var img_data: PackedByteArray = img.save_png_to_buffer()

	var photo_data = {
		"img_data": img_data,
		"pos": pos,
		"fixed": fixed,
		"score": score
	}

	if fixed:
		var index = _pos_to_index(pos)
		if index >= 0 and index < 4:
			saved_photos[index] = photo_data
	else:
		temp_photos.append(photo_data)

func _pos_to_index(pos: Vector2) -> int:
	return int(pos.y) * 2 + int(pos.x)

func calcular_score() -> int:
	if total_trash >= 25:
		return 3
	elif total_trash >= 20:
		return 2
	elif total_trash >= 10:
		return 1
	return 0
	
func _next_day() -> void:
	day += 1
	temp_photos.clear()

func add_trash() -> void:
	total_trash += 1
	emit_signal("trash_collected")
	
func _get_total_trash() -> int:
	return total_trash

func _get_photos() -> Array:
	var result: Array = []
	for f in saved_photos:
		if f == null:
			continue
		var tex := ImageTexture.new()
		var img := Image.new()
		img.load_png_from_buffer(f.get("img_data"))
		tex.set_image(img)

		result.append({
			"tex": tex,
			"pos": f.get("pos"),
			"fixed": f.get("fixed"),
			"score": f.get("score")
		})
	return result
	

func _get_temp_photos() -> Array:
	var result: Array = []
	for f in temp_photos:
		var tex := ImageTexture.new()
		var img := Image.new()
		img.load_png_from_buffer(f.get("img_data"))
		tex.set_image(img)

		result.append({
			"tex": tex,
			"pos": f.get("pos"),
			"fixed": false,
			"score": f.get("score")
		})
	return result

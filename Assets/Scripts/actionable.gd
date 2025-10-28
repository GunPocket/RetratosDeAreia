extends Area2D

@export var dialogue_resourse: DialogueResource
@export var dialogue_start: String = "start"

var dialogue_finished: bool = false

func _ready() -> void:
	DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))

func action() -> void:
	dialogue_finished = false
	DialogueManager.show_dialogue_balloon(dialogue_resourse, dialogue_start)

func is_finished() -> bool:
	return dialogue_finished

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	dialogue_finished = true

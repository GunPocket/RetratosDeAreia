class_name AudioSource extends Node

@export var stream: AudioStream

func Play() -> void: AudioManager.PlayOneShot( stream )

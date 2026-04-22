class_name AudioManager extends Node

static var _instance: AudioManager

@export var streamPlayer: AudioStreamPlayer

func _ready() -> void: 
	_instance = self
	streamPlayer.play();

static  func PlayOneShot( stream: AudioStream ) -> void:
	var playback:= _instance.streamPlayer.get_stream_playback() as AudioStreamPlaybackPolyphonic
	playback.play_stream( stream )

extends Node

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func rand_sound_pitch(audio : AudioStreamPlayer2D, lower : float, upper : float) -> void:
	audio.pitch_scale = rng.randf_range(lower, upper)

extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var ding: AudioStreamPlayer2D = $ding
@onready var bump: AudioStreamPlayer2D = $bump

@export var bounciness : float = 5

func bounce() -> void:
	Global.rand_sound_pitch(ding, .9, 1.1)
	Global.rand_sound_pitch(bump, .9, 1.1)
	anim.stop()
	anim.play("bounce")

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

func bounce_obj(obj : RigidBody2D) -> void:
	obj.apply_central_impulse(global_position.direction_to(obj.global_position).normalized() * 400)

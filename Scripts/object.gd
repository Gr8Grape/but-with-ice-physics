extends RigidBody2D

@export var bounciness : float

func _on_body_entered(body: Node) -> void:
	physics_material_override.bounce = bounciness
	if body.is_in_group("bouncer"):
		body.bounce()
		body.bounce_obj(self)

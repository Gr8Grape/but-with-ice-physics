extends CharacterBody2D

@export var SPEED := 100.0
@export var strength := 5.0

var dir : Vector2
var force_push : float

#get direction for x and y based on whether up/down, left/right is pressed.
func calc_dir() -> void:
	dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

#this val is calculated based on speed.
#divided by 5 as to not have too much force, kind of a magical number
func calc_force_push() -> void:
	force_push = strength + velocity.length() / 5

func _physics_process(_delta: float) -> void:
	calc_force_push()
	calc_dir()
	if dir:
		velocity = dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
	
	#Gets all the collisions and checks if its a moveable body (rigidbody2d)
	#then applies a force to move it (force_push)
	#force_push is calculated based on speed
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * force_push)

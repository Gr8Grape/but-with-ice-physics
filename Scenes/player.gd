extends CharacterBody2D

@export var speed := 100.0
@export var strength := 50.0
@export var accel := 5.0
@export var bounciness := .7
@export var dash_mult := 2

var dir : Vector2
var force_push : float

#get direction for x and y based on whether up/down, left/right is pressed.
func calc_dir() -> void:
	dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

#this val is calculated based on speed.
#strength is the base value that the player can push
func calc_force_push() -> void:
	force_push = strength + velocity.length() 

func handle_input() -> void:
	if Input.is_action_just_pressed("eject"):
		velocity = speed * dash_mult * global_position.direction_to(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	calc_force_push()
	calc_dir()
	handle_input()
	
	if dir:
		velocity = lerp(velocity, dir * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.y = lerp(velocity.y, 0.0, accel * delta)
	
	#bounce
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * bounciness
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_impulse(-collision.get_normal() * force_push)

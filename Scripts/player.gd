extends CharacterBody2D

@export var speed := 100.0
@export var strength := 50.0
@export var accel := 5.0
@export var bounciness := .7
@export var dash_mult := 2
@export var chain_str := 1000.0

@onready var grapple: Node2D = $Grapple

var dir : Vector2
var force_push : float
var reel_amt : int = 0
var reel_strength : float = 1
var chain_velocity := Vector2.ZERO

#get direction for x and y based on whether up/down, left/right is pressed.
func calc_dir() -> void:
	dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

#this val is calculated based on speed.
#strength is the base value that the player can push
func calc_force_push() -> void:
	force_push = strength + velocity.length() 

func mouse_dir() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

func handle_input() -> void:
	if Input.is_action_just_pressed("eject"):
		velocity = speed * dash_mult * mouse_dir()
	
	if Input.is_action_just_pressed("grapple"):
		grapple.shoot(get_local_mouse_position(), velocity.length())
	elif Input.is_action_just_released("grapple"):
		grapple.release()

func _physics_process(delta: float) -> void:
	calc_force_push()
	calc_dir()
	handle_input()
	
	#moving
	if dir:
		velocity = lerp(velocity, dir * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.y = lerp(velocity.y, 0.0, accel * delta)
	
	# Hook physics
	if grapple.hooked:
		chain_velocity = to_local(grapple.glob_head).normalized() * chain_str * reel_strength
	else:
		reel_amt = 0
		reel_strength = 1
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity * delta
	
	#bounce
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * bounciness
		if collision.get_collider() is RigidBody2D:
			if grapple.hooked:
				grapple.release()
			collision.get_collider().apply_impulse(-collision.get_normal() * force_push)

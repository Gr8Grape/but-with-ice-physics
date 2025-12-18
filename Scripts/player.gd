extends CharacterBody2D

#by the way chat, "calc" is short for "calculation"
#dw im just using slang

#region variables
@export var speed := 150.0
@export var strength := 50.0
@export var accel := 600.0
@export var bounciness := .4
@export var dash_mult := 2.0
@export var chain_str := 1500.0
@export var sprint_mult := 1.2
@export var slow_mult := .75
@export var friction := 500.0

@onready var grapple: Node2D = $Grapple

var dir : Vector2
var force_push : float
var reel_amt : int = 0
var reel_strength : float = 1
var chain_velocity := Vector2.ZERO
var speed_mult : float
#endregion

#region calc functions

#get direction for x and y based on whether up/down, left/right is pressed.
func calc_dir() -> void:
	dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

#calc the force used to push objects
func calc_force_push() -> void:
	#this val is calculated based on speed.
	#strength is the base value that the player can push
	#if player is more bouncy, not a lot of force is transfered
	force_push = strength + (velocity.length() * (1 - bounciness))

func mouse_dir() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

#endregion

func handle_input() -> void:
	#only dash while not coasting
	if Input.is_action_just_pressed("dash") and not Input.is_action_pressed("coast"):
		velocity = speed * speed_mult * dash_mult * mouse_dir()
	
	#grapplingw
	if Input.is_action_just_pressed("grapple"):
		grapple.shoot(get_local_mouse_position())
	elif Input.is_action_just_released("grapple"):
		grapple.release()
	
	#using elifs because slowing his priority over sprinting
	if Input.is_action_pressed("slow"):
		speed_mult = slow_mult
	elif Input.is_action_pressed("sprint"):
		speed_mult = sprint_mult
	else:
		speed_mult = 1

func _physics_process(delta: float) -> void:
	calc_force_push()
	calc_dir()
	handle_input()
	
	#moving
	if dir:
		velocity = velocity.move_toward(dir * speed * speed_mult, accel * delta)
	else:
		#physics get kinda wonky while hooked, this makes it feel better
		#ill be honest not sure why/how this works
		if not grapple.hooked:
			#let the ball roll while player coasts
			if Input.is_action_pressed("coast"):
				velocity = velocity.move_toward(Vector2.ZERO, friction / 3 * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	#hook stuff
	if grapple.hooked:
		chain_velocity = to_local(grapple.glob_head).normalized() * chain_str
	else:
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity * delta
	
	#speed cap
	if velocity.length() > 500:
		velocity = velocity.normalized() * 500
	
	#bounce
	var collision = move_and_collide(velocity * delta)
	if collision:
		if grapple.hooked:
			grapple.release()
		velocity = velocity.bounce(collision.get_normal()) * bounciness
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_impulse(-collision.get_normal() * force_push)

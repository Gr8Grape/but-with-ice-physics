extends CharacterBody2D

#by the way chat, "calc" is short for "calculation"
#dw im just using slang

#region variables
@export var speed := 150.0
@export var strength := 50.0
@export var accel := 600.0
@export var bounciness := 0.5
@export var dash_mult := 2.0
@export var chain_str := 1500.0
@export var sprint_mult := 1.2
@export var slow_mult := .75
@export var friction := 500.0

@onready var grapple: Node2D = $Grapple
@onready var obstacles = get_tree().get_nodes_in_group("TileMap")[0]

#region sfx nodes
@onready var dash: AudioStreamPlayer2D = $sfx/dash
@onready var collide: AudioStreamPlayer2D = $sfx/collide
@onready var noise: AudioStreamPlayer2D = $sfx/noise
@onready var swallow: AudioStreamPlayer2D = $sfx/swallow
#endregion

var dir : Vector2
var force_push : float
var reel_amt : int = 0
var reel_strength : float = 1
var chain_velocity := Vector2.ZERO
var speed_mult : float
var obj_bounce := 0.4
#endregion

#region calc functions

#get direction for x and y based on whether up/down, left/right is pressed.
func calc_dir() -> void:
	dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()

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
	if Input.is_action_just_pressed("dash"):
		dash.play()
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
	var data
	if collision:
		if obj_bounce != 0:
			obj_bounce = 0
		var collider := collision.get_collider()
		# Convert collision position to be local to $TileMap
		var local_pos = obstacles.to_local(collision.get_position())
		# Convert the local $TileMap position to coordinates
		var coords = obstacles.local_to_map(local_pos)
		# Get tile data with coords
		data = obstacles.get_cell_tile_data(coords)
		# Get custom data
		if data:
			#uses data from tilemap to get its bounciness
			obj_bounce = data.get_custom_data("bounciness")
		
		if grapple.hooked:
			grapple.release()
		
		if collider is RigidBody2D:
			collider.apply_impulse(-collision.get_normal() * force_push)
		elif collider.is_in_group("bouncer"):
			collider.bounce()
			obj_bounce = collider.bounciness
		
		#sfx
		if velocity.length() >= speed and !collider.is_in_group("bouncer"):
			Global.rand_sound_pitch(collide, .9, 1.1)
			collide.play()
		
		velocity = velocity.bounce(collision.get_normal()) * (bounciness + obj_bounce) #bounciness

#for now this just makes sfx when eating
func eat() -> void:
	Global.rand_sound_pitch(swallow, .95, 1.05)
	Global.rand_sound_pitch(noise, .95, 1.05)
	swallow.play()
	noise.play()

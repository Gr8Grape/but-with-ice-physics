extends Node2D

@onready var head: CharacterBody2D = $Head
@onready var line: Sprite2D = $Line

var direction := Vector2(0,0)
#global position the head is in
var glob_head := Vector2(0,0)
var def_speed := 300.0
var speed : float
var flying := false
var hooked := false
var obj_hooked

func shoot(dir: Vector2, init: float) -> void:
	obj_hooked = null
	speed = def_speed + init
	#Normalize the direction and save it
	direction = dir.normalized()
	flying = true
	#reset position
	glob_head = global_position

func release() -> void:
	obj_hooked = null
	flying = false
	hooked = false

func _process(_delta: float) -> void:
	#Only visible if flying or attached to something
	self.visible = flying or hooked
	if not self.visible:
		return
	var head_pos = to_local(glob_head)
	#rotate the line and head to fit on the line between ourself and the head
	line.rotation = position.angle_to_point(head_pos) + deg_to_rad(90)
	head.rotation = position.angle_to_point(head_pos) + deg_to_rad(90)
	line.position = head_pos
	line.region_rect.size.y = head_pos.length()

func _physics_process(delta: float) -> void:
	#reset heads position
	head.global_position = glob_head
	if flying:
		#if collision
		var collision := head.move_and_collide(direction * speed * delta)
		if collision:
			hooked = true
			flying = false
			if collision.get_collider() is RigidBody2D:
				obj_hooked = collision.get_collider()
	
	if obj_hooked:
		glob_head = obj_hooked.global_position
	else:
		glob_head = head.global_position

extends Node2D

@onready var head: CharacterBody2D = $Head
@onready var line: Sprite2D = $Line

#speed can change so we need a reference point
@export var def_speed := 1000

var direction := Vector2(0,0)
#global position the head is in
var glob_head := Vector2(0,0)
#def_speed is the default speed
var speed : float
var flying := false
var hooked := false
var obj_hooked : Node2D

func shoot(dir : Vector2) -> void:
	speed = def_speed
	obj_hooked = null
	#ensure the place we need the direction of is a normal vector
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
	if not visible:
		#dont bother with the rest of the code, we aren't in use
		return
	var head_pos = to_local(glob_head)
	#rotate the line and head to fit on the line between ourself and the head
	line.rotation = position.angle_to_point(head_pos) + deg_to_rad(90)
	head.rotation = position.angle_to_point(head_pos) + deg_to_rad(90)
	line.position = head_pos
	line.region_rect.size.y = head_pos.length()
	
	#release when slow enough
	if speed <= 50:
		release()

#Stands of (p)oint (o)f (c)ontact
#this is where the hook head touches the object relative to the object
var poc : Vector2
func _physics_process(delta: float) -> void:
	#reset heads position
	head.global_position = glob_head
	if flying:
		speed = move_toward(speed, 0, speed * 4 * delta)
		var collision := head.move_and_collide(direction * speed * delta)
		if collision:
			hooked = true
			flying = false
			if collision.get_collider() is RigidBody2D:
				obj_hooked = collision.get_collider()
				poc = obj_hooked.to_local(head.global_position)
	
	if obj_hooked:
		#we want the hook head to "stick" to the object
		#so we must set the head to the position of the object
		#we want to add the poc to global position so that it offsets
		#the object can rotate, however, so account for that
		glob_head = obj_hooked.global_position + poc.rotated(obj_hooked.rotation)
	else:
		glob_head = head.global_position

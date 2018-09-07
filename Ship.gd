extends KinematicBody2D

var speed = 200
var rotation_speed = 80
var max_speed = 150
var velocity = Vector2()

slave var slave_position = Vector2()
slave var slave_rotation = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
#	if Input.is_action_pressed('forward'):
#		add_force(Vector2(0,0), Vector2(cos(rotation), sin(rotation))*delta*speed)
##limit the velocity to max_speed
#	if get_linear_velocity().length() > max_speed:
#		set_linear_velocity(get_linear_velocity().normalized() * max_speed)
#
#	if Input.is_action_pressed('turn_left'):
#		set_angular_velocity(-rotation_speed * delta)
#
#	if Input.is_action_pressed('turn_right'):
#		set_angular_velocity(rotation_speed * delta)
	if is_network_master():
		control(delta)
		move_and_slide(velocity)
	else:
		position = slave_position
		rotation = slave_rotation



func control(delta):
	look_at(get_global_mouse_position())
#	var rot_dir = 0
#	if Input.is_action_pressed('turn_right'):
#		rot_dir += 1
#	if Input.is_action_pressed('turn_left'):
#		rot_dir -= 1
#	rotation += rotation_speed * rot_dir * delta
	velocity = Vector2()
	if Input.is_action_pressed('forward'):
		velocity += Vector2(max_speed, 0).rotated(rotation)
#	if Input.is_action_pressed('back'):
#		velocity += Vector2(-max_speed, 0).rotated(rotation)
#		velocity /= 2.0
#	if Input.is_action_just_pressed('click'):
#		shoot(gun_shots, gun_spread)
	position.x = clamp(position.x, $Camera2D.limit_left, $Camera2D.limit_right)
	position.y = clamp(position.y, $Camera2D.limit_top, $Camera2D.limit_bottom)
	rset_unreliable("slave_position", position)
	rset_unreliable("slave_rotation", rotation)
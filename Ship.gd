extends RigidBody2D

var speed = 200
var rotation_speed = 80
var max_speed = 150

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if Input.is_action_pressed('forward'):
		add_force(Vector2(0,0), Vector2(cos(rotation), sin(rotation))*delta*speed)
#limit the velocity to max_speed
	if get_linear_velocity().length() > max_speed:
		set_linear_velocity(get_linear_velocity().normalized() * max_speed)
	
	if Input.is_action_pressed('turn_left'):
		set_angular_velocity(-rotation_speed * delta)
		
	if Input.is_action_pressed('turn_right'):
		set_angular_velocity(rotation_speed * delta)
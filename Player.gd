extends "res://Tanks/Tank.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func control(delta):
	$Turret.look_at(get_global_mouse_position())
	var rot_dir = 0
	if Input.is_action_pressed('turn_right'):
		$anim.play('forward')
		rot_dir += 1
	if Input.is_action_pressed('turn_left'):
#		$anim.play_backwards('forward')
		rot_dir -= 1
	rotation += rotation_speed * rot_dir * delta
	velocity = Vector2()
	if Input.is_action_pressed('forward'):
		$anim.play('forward')
		velocity += Vector2(max_speed, 0).rotated(rotation)
	if Input.is_action_pressed('backward'):
#		$anim.play_backwards('forward')
		velocity += Vector2(-max_speed, 0).rotated(rotation)
		velocity /= 2.0
	if Input.is_action_just_released('turn_right') or Input.is_action_just_released('turn_left') or Input.is_action_just_released('forward') or Input.is_action_just_released('backward'):
		$anim.play('idle')
		pass
		
#	if Input.is_action_pressed('shoot'):
#		rpc("master_shoot", gun_shots, gun_spread)
#		shoot(gun_shots, gun_spread)

	position.x = clamp(position.x, $Camera2D.limit_left, $Camera2D.limit_right)
	position.y = clamp(position.y, $Camera2D.limit_top, $Camera2D.limit_bottom)
	rset_unreliable("slave_position", position)
	rset_unreliable("slave_rotation", rotation)
	rset_unreliable("slave_turret_rotation", $Turret.rotation)
extends KinematicBody2D

signal shoot
signal health_changed
signal dead

export (int) var speed = 200
export (int) var rotation_speed = 5
export (int) var max_speed = 150
export (float) var max_health = 500
export (Vector2) var velocity = Vector2()
#export (PackedScene) var Bullet
export (float) var gun_cooldown = 0.2

slave var slave_position = Vector2()
slave var slave_rotation = 0
slave var slave_turret_rotation = 0

var can_shoot = true
var alive = true
var health


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if is_network_master():
		control(delta)
		move_and_slide(velocity)
	else:
		position = slave_position
		rotation = slave_rotation
		$Turret.rotation = slave_turret_rotation



func control(delta):
	$Turret.look_at(get_global_mouse_position())
	var rot_dir = 0
	if Input.is_action_pressed('turn_right'):
		rot_dir += 1
	if Input.is_action_pressed('turn_left'):
		rot_dir -= 1
	rotation += rotation_speed * rot_dir * delta
	velocity = Vector2()
	if Input.is_action_pressed('forward'):
		velocity += Vector2(max_speed, 0).rotated(rotation)
	if Input.is_action_pressed('backward'):
		velocity += Vector2(-max_speed, 0).rotated(rotation)
		velocity /= 2.0
#	if Input.is_action_just_pressed('click'):
#		shoot(gun_shots, gun_spread)
	position.x = clamp(position.x, $Camera2D.limit_left, $Camera2D.limit_right)
	position.y = clamp(position.y, $Camera2D.limit_top, $Camera2D.limit_bottom)
	rset_unreliable("slave_position", position)
	rset_unreliable("slave_rotation", rotation)
	rset_unreliable("slave_turret_rotation", $Turret.rotation)
	
#func shoot(num, spread, target=null):
#	if can_shoot:
#		can_shoot = false
#		$GunTimer.start()
#		var dir = Vector2(1, 0).rotated($Turret.global_rotation)
#		if num > 1:
#			for i in range(num):
#				var a = -spread + i * (2*spread)/(num-1)
#				emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir.rotated(a), target)
#		else:
#			emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir, target)
#		$AnimationPlayer.play('muzzle_flash')
#
#
#
#func take_damage(amount):
#	health -= amount
#	emit_signal('health_changed', health * 100/max_health)
#	if health <= 0:
#		explode()
#
#func heal(amount):
#	health += amount
#	health = clamp(health, 0, max_health)
#	emit_signal('health_changed', health * 100/max_health)
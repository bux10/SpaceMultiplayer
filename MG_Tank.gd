extends KinematicBody2D

signal shoot
signal health_changed
signal dead

export (PackedScene) var Bullet
export (int) var speed
export (int) var rotation_speed
export (int) var max_speed
export (int) var max_health
export (Vector2) var velocity = Vector2()
export (float) var gun_cooldown = 0.2
export (int) var gun_shots = 1
export (float) var gun_spread = 0

slave var slave_position = Vector2()
slave var slave_rotation = 0
slave var slave_turret_rotation = 0
slave var slave_health

var can_shoot = true
var alive = true
onready var health = max_health

func _ready():
	if is_network_master():
		$Camera2D.make_current()
	max_speed = max_speed
	set_camera_limits()
	$GunTimer.wait_time = gun_cooldown
	pass

func _process(delta):
	if is_network_master():
		control(delta)
		move_and_slide(velocity)

	else:
		position = slave_position
		rotation = slave_rotation
		$Turret.rotation = slave_turret_rotation

func set_camera_limits():
	var ground = get_node('/root/Map/Ground')
	var map_limits = ground.get_used_rect()
	var map_cellsize = ground.cell_size
	$Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func control(delta):
	$Turret.look_at(get_global_mouse_position())
	var rot_dir = 0
	if Input.is_action_pressed('turn_right'):
		$Body.play('Forward')
		rot_dir += 1
	 
	if Input.is_action_pressed('turn_left'):
		$Body.play('Backward')
		
		rot_dir -= 1
	rotation += rotation_speed * rot_dir * delta
	velocity = Vector2()
	if Input.is_action_pressed('forward'):
		$Body.play('Forward')
		velocity += Vector2(max_speed, 0).rotated(rotation)
	if Input.is_action_pressed('backward'):
		$Body.play('Backward')
		velocity += Vector2(-max_speed, 0).rotated(rotation)
		velocity /= 2.0
	if Input.is_action_just_released('turn_right') or Input.is_action_just_released('turn_left') or Input.is_action_just_released('forward') or Input.is_action_just_released('backward'):
		$Body.play('Idle')
		
	if Input.is_action_pressed('shoot'):
		rpc("master_shoot", gun_shots, gun_spread)
#		shoot(gun_shots, gun_spread)

	position.x = clamp(position.x, $Camera2D.limit_left, $Camera2D.limit_right)
	position.y = clamp(position.y, $Camera2D.limit_top, $Camera2D.limit_bottom)
	rset_unreliable("slave_position", position)
	rset_unreliable("slave_rotation", rotation)
	rset_unreliable("slave_turret_rotation", $Turret.rotation)
	
master func master_shoot(num, spread, target=null):
	if can_shoot:
		can_shoot = false
		$GunTimer.start()
		var dir = Vector2(1, 0).rotated($Turret.global_rotation)
#		if num > 1:
#			for i in range(num):
#				var a = -spread + i * (2*spread)/(num-1)
#				emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir.rotated(a), target)
#		else:
		emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir, target)
		rpc("sync_shoot",  Bullet, $Turret/Muzzle.global_position, dir, target)
#		$AnimationPlayer.play('muzzle_flash')

slave func sync_shoot(_bullet, _pos, _dir, _target):
	emit_signal('shoot', _bullet, _pos, _dir, _target)

sync func explode():
	$Body.hide()
	$Explosion.show()
	$Explosion.play('fire')


master func take_damage(amount):
	health -= amount
#	print(health * 100/max_health)
	rpc('update_health', health * 100/max_health)
	if health <= 0:
		rpc("explode")


master func update_health(health):
	rset_unreliable('slave_health', health)
	emit_signal('health_changed', health)
	rpc('update_enemy_ui', health)
	pass

slave func update_enemy_ui(value):
	$UnitDisplay.update_healthbar(value)
	pass
	
	
	
#func heal(amount):
#	health += amount
#	health = clamp(health, 0, max_health)
#	emit_signal('health_changed', health * 100/max_health)

func _on_GunTimer_timeout():
	can_shoot = true
	pass # replace with function body


func _on_Explosion_animation_finished():
	queue_free()
	pass # replace with function body

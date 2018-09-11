extends KinematicBody2D

signal shoot
signal health_changed
signal dead

export (PackedScene) var Bullet
#export (int) var speed
export (int) var rotation_speed
export (int) var max_speed
export (int) var max_health
export (Vector2) var velocity = Vector2()
#export (float) var gun_cooldown = 0.2
#export (int) var gun_shots = 1
#export (float) var gun_spread = 0

slave var slave_position = Vector2()
slave var slave_rotation = 0
slave var slave_turret_rotation = 0
slave var slave_health

#var can_shoot = true
var alive = true
onready var health = max_health

func _ready():
	if is_network_master():
		$Camera2D.make_current()
		$UnitDisplay/Label.text = str(get_tree().get_network_unique_id())
	max_speed = max_speed
	set_camera_limits()
	pass
	
func _process(delta):
	if is_network_master():
		control(delta)
		shoot()
		move_and_slide(velocity)
	else:
		position = slave_position
		rotation = slave_rotation
		$Turret.rotation = slave_turret_rotation
	pass

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

#	if Input.is_action_pressed('turn_right') or Input.is_action_pressed('turn_left') or Input.is_action_pressed('forward'):
#		pass
#	if Input.is_action_just_pressed('backward'):
#		$Body/anim.play_backwards('forward')
#	if Input.is_action_just_released('turn_right') or Input.is_action_just_released('turn_left') or Input.is_action_just_released('forward') or Input.is_action_just_released('backward'):
#		$Body/anim.play('idle')
	
	position.x = clamp(position.x, $Camera2D.limit_left, $Camera2D.limit_right)
	position.y = clamp(position.y, $Camera2D.limit_top, $Camera2D.limit_bottom)
	rset_unreliable("slave_position", position)
	rset_unreliable("slave_rotation", rotation)
	rset_unreliable("slave_turret_rotation", $Turret.rotation)
	pass


func set_camera_limits():
	var ground = get_node('/root/Map/Ground')
	var map_limits = ground.get_used_rect()
	var map_cellsize = ground.cell_size
	$Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y
	pass
	
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

func _on_Explosion_animation_finished():
	queue_free()
	pass # replace with function body
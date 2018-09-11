extends "res://tanks/scripts/Base_Tank.gd"

export (float) var gun_cooldown = 0.2
export (int) var gun_shots = 1
export (float) var gun_spread = 0

var can_shoot = true

func _ready():
	$GunTimer.wait_time = gun_cooldown
	pass

func shoot():
	if Input.is_action_pressed('shoot'):
#		rpc("master_shoot", gun_shots, gun_spread)
#		$Turret/anim.play('shooting')
		pass
	pass

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
#		emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir, target)
#		rpc("sync_shoot",  Bullet, $Turret/Muzzle.global_position, dir, target)

slave func sync_shoot(_bullet, _pos, _dir, _target):
#	emit_signal('shoot', _bullet, _pos, _dir, _target)
	pass
	
func _on_GunTimer_timeout():
	can_shoot = true
	pass # replace with function body
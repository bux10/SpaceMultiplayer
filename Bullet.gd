extends Area2D

export (int) var speed
export (int) var damage
export (float) var steer_force = 0

var velocity = Vector2()
var acceleration = Vector2()
var target = null

#slave var slave_bullet_position
#slave var slave_bullet_rotation

func start(_position, _direction, _target=null):
#	if is_network_master():
		$Lifetime.start()
		position = _position
		rotation = _direction.angle()
		velocity = _direction * speed
		target = _target
#	else:
#		position = slave_bullet_position
#		rotation = slave_bullet_rotation

#func seek():
#	var desired = (target.position - position).normalized() * speed
#	var steer = (desired - velocity).normalized() * steer_force
#	return steer

func _process(delta):
	if target:
		acceleration += seek()
		velocity += acceleration * delta
		velocity = velocity.clamped(speed)
		rotation = velocity.angle()
	position += velocity * delta
#	rset_unreliable("slave_bullet_position", position)
#	rset_unreliable("slave_bullet_rotation", rotation)

func explode():
	set_process(false)
	velocity = Vector2()
	$Sprite.hide()
	queue_free()
#	$Explosion.show()
#	$Explosion.play("smoke")
#
func _on_Bullet_body_entered(body):
	pass
#	if body.is_network_master():
#	rpc("sync_hit", body)
		
#sync func sync_hit(body):
#	if body.has_method("take_damage"):
#		body.take_damage(damage)
#		print(body.health)
	

func _on_Lifetime_timeout():
	explode()
#
#func _on_Explosion_animation_finished():
#	queue_free()
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func _on_Tank_shoot(bullet, _position, _direction, _target=null):
	print("shoot")
	var b = bullet.instance()
	add_child(b)
#	b.set_network_master(1)
	b.start(_position, _direction, _target)
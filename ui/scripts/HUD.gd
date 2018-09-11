extends CanvasLayer

var bar_red = preload("res://assets/UI/barHorizontal_red_mid 200.png")
var bar_green = preload("res://assets/UI/barHorizontal_green_mid 200.png")
var bar_yellow = preload("res://assets/UI/barHorizontal_yellow_mid 200.png")
onready var bar_texture = bar_green

onready var HealthBarTween = $Margin/Container/HealthBar/Tween
slave var slave_health

func update_healthbar(value):
	print(value)
#	if is_network_master():
	bar_texture = bar_green
	if value < 60:
		bar_texture = bar_yellow
	if value < 25:
		bar_texture = bar_red
	$Margin/Container/HealthBar.texture_progress = bar_texture
	HealthBarTween.interpolate_property($Margin/Container/HealthBar,
			'value', $Margin/Container/HealthBar.value, value,
			0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	HealthBarTween.start()
	$AnimationPlayer.play("healthbar_flash")




func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'healthbar_flash':
		$Margin/Container/HealthBar.texture_progress = bar_texture

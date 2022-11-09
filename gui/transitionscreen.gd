extends CanvasLayer

signal transitioned

#func _ready():
#	transition()

func transition():
	$AnimationPlayer.play("fade_to_black")



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("transitioned")
		$AnimationPlayer.play("fade_to_normal")
	if anim_name == "fade_to_black_2x":
		emit_signal("transitioned")
		$AnimationPlayer.play("fade_to_normal_2x")
	if anim_name == "fade_to_black_0.5x":
		emit_signal("transitioned")
		$AnimationPlayer.play("fade_to_normal_0.5x")
